"""
Yul2Venom Optimization Module

This module contains pattern-based optimizations that are applied during
Yul→Venom IR translation. Each optimizer follows the Single Responsibility
Principle and implements a common interface.

Architecture:
- YulOptimizer: Base class with can_optimize/optimize interface
- OptimizationContext: Dataclass providing generator access
- OptimizationPipeline: Orchestrates all optimizers
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import Optional, List, Dict, Any, Callable

# Import IR types
try:
    from yul2venom.ir.basicblock import IRBasicBlock, IRInstruction, IRLabel, IRVariable, IRLiteral
except ImportError:
    from ir.basicblock import IRBasicBlock, IRInstruction, IRLabel, IRVariable, IRLiteral


@dataclass
class OptimizationContext:
    """Context passed to optimizers providing access to generator state."""
    current_bb: IRBasicBlock
    current_fn: Any  # IRFunction
    var_map: Dict[str, Any]
    functions_ast: Dict[str, Any]
    visit_expr: Callable  # (expr) -> IROperand
    append_instruction: Callable  # (opcode, *args) -> IRVariable


class YulOptimizer(ABC):
    """Base class for Yul→Venom optimization patterns.
    
    Each optimizer detects a specific pattern in Yul AST and emits
    optimized Venom IR instructions instead of the default translation.
    """
    
    @property
    @abstractmethod
    def name(self) -> str:
        """Human-readable name for logging."""
        pass
    
    @abstractmethod
    def can_optimize(self, stmt, ctx: OptimizationContext) -> bool:
        """Check if this optimizer can handle the given statement."""
        pass
    
    @abstractmethod
    def optimize(self, stmt, ctx: OptimizationContext) -> bool:
        """Apply optimization. Returns True if handled, False otherwise."""
        pass


# =============================================================================
# Assert Optimization
# =============================================================================

class AssertOptimizer(YulOptimizer):
    """Convert revert patterns to assert instructions.
    
    Patterns:
    - `if iszero(cond) { revert(0,0) }` → `assert cond`
    - `if cond { revert(0,0) }` → `assert iszero(cond)`
    
    Saves ~6 bytes per check by avoiding jnz + separate block overhead.
    """
    
    @property
    def name(self) -> str:
        return "assert"
    
    def can_optimize(self, stmt, ctx: OptimizationContext) -> bool:
        """Check if statement is YulIf with simple revert body."""
        if type(stmt).__name__ != "YulIf":
            return False
        return self._is_simple_revert_body(stmt.body)
    
    def optimize(self, stmt, ctx: OptimizationContext) -> bool:
        """Emit assert instruction instead of jnz+revert block."""
        cond = stmt.condition
        
        if (type(cond).__name__ == "YulCall" and 
            cond.function == "iszero" and 
            len(cond.args) == 1):
            # Pattern: if iszero(x) { revert } → assert x
            inner_cond_var = ctx.visit_expr(cond.args[0])
            ctx.append_instruction("assert", inner_cond_var)
        else:
            # Pattern: if cond { revert } → assert iszero(cond)
            cond_var = ctx.visit_expr(cond)
            negated = ctx.append_instruction("iszero", cond_var)
            ctx.append_instruction("assert", negated)
        
        return True
    
    def _is_simple_revert_body(self, stmt) -> bool:
        """Check if statement is (or contains only) revert(0, 0) or revert_*()."""
        stmt_type = type(stmt).__name__
        
        if stmt_type == "YulBlock":
            if len(stmt.statements) != 1:
                return False
            return self._is_simple_revert_body(stmt.statements[0])
        
        elif stmt_type == "YulExpressionStmt":
            return self._is_simple_revert_body(stmt.expr)
        
        elif stmt_type == "YulCall":
            if stmt.function == "revert":
                if len(stmt.args) == 2:
                    arg0, arg1 = stmt.args[0], stmt.args[1]
                    if (type(arg0).__name__ == "YulLiteral" and 
                        type(arg1).__name__ == "YulLiteral"):
                        try:
                            val0 = int(arg0.value, 16) if arg0.value.startswith("0x") else int(arg0.value)
                            val1 = int(arg1.value, 16) if arg1.value.startswith("0x") else int(arg1.value)
                            return val0 == 0 and val1 == 0
                        except ValueError:
                            pass
            elif stmt.function.startswith("revert_error_"):
                return True
        
        return False


# =============================================================================
# SHA3_64 Optimization for Mapping Access
# =============================================================================

class Sha3Optimizer(YulOptimizer):
    """Convert keccak256 on 64-byte memory to sha3_64 instruction.
    
    Pattern (mapping slot computation):
    ```yul
    mstore(0x00, key)
    mstore(0x20, slot)
    result := keccak256(0x00, 0x40)
    ```
    
    Optimized:
    ```venom
    %result = sha3_64 %slot, %key
    ```
    
    Note: This is a call-site optimization, not a statement optimization.
    It's applied in _handle_intrinsic when processing keccak256.
    """
    
    @property
    def name(self) -> str:
        return "sha3_64"
    
    def can_optimize(self, stmt, ctx: OptimizationContext) -> bool:
        """This optimizer works on expressions, not statements."""
        return False
    
    def optimize(self, stmt, ctx: OptimizationContext) -> bool:
        return False
    
    def can_optimize_keccak(self, offset_arg, size_arg, recent_mstores: List) -> bool:
        """Check if keccak256 call can use sha3_64.
        
        Args:
            offset_arg: The offset argument (should be 0)
            size_arg: The size argument (should be 64/0x40)
            recent_mstores: Recent mstore operations [(offset, value), ...]
        
        Returns:
            True if pattern matches sha3_64 requirements
        """
        # Check size is 64 (0x40)
        if not self._is_literal_value(size_arg, 64):
            return False
        
        # Check offset is 0
        if not self._is_literal_value(offset_arg, 0):
            return False
        
        # Need exactly 2 mstores to 0x00 and 0x20
        if len(recent_mstores) < 2:
            return False
        
        # Check for mstore(0x00, key) and mstore(0x20, slot)
        has_key_at_0 = any(self._is_literal_value(m[0], 0) for m in recent_mstores[-2:])
        has_slot_at_32 = any(self._is_literal_value(m[0], 32) for m in recent_mstores[-2:])
        
        return has_key_at_0 and has_slot_at_32
    
    def get_sha3_64_operands(self, recent_mstores: List) -> tuple:
        """Extract slot and key from recent mstores for sha3_64.
        
        Returns:
            (slot_operand, key_operand) for sha3_64 instruction
        """
        key = None
        slot = None
        
        for offset, value in recent_mstores[-2:]:
            if self._is_literal_value(offset, 0):
                key = value
            elif self._is_literal_value(offset, 32):
                slot = value
        
        return (slot, key)
    
    def _is_literal_value(self, operand, expected: int) -> bool:
        """Check if operand is a literal with expected value."""
        if isinstance(operand, IRLiteral):
            return operand.value == expected
        if type(operand).__name__ == "YulLiteral":
            try:
                val = operand.value
                if isinstance(val, str):
                    val = int(val, 16) if val.startswith("0x") else int(val)
                return val == expected
            except ValueError:
                pass
        return False


# =============================================================================
# Function Inlining Optimization
# =============================================================================

class InliningOptimizer(YulOptimizer):
    """Inline small/leaf functions instead of using invoke/ret.
    
    Inlining criteria (all configurable):
    1. Function is "small" (< max_statements instructions estimated)
    2. Function is a "leaf" (no calls to other user functions)
    3. Function is not recursive
    4. Function is called fewer than max_call_count times (to avoid code bloat)
    
    Variables are prefixed with %inl{N}_ to avoid conflicts.
    """
    
    # Default thresholds
    DEFAULT_MAX_STATEMENTS = 15
    DEFAULT_MAX_CALL_COUNT = 2
    
    def __init__(self, max_statements: int = None, max_call_count: int = None):
        """Initialize with configurable inlining thresholds.
        
        Args:
            max_statements: Max stmt count for inlining (default: 15)
            max_call_count: Max call count for inlining (default: 2)
        """
        self.inline_counter = 0
        self.inlinable_functions: set = set()
        self.call_counts: Dict[str, int] = {}
        
        # Configurable thresholds
        self.max_statements = max_statements or self.DEFAULT_MAX_STATEMENTS
        self.max_call_count = max_call_count or self.DEFAULT_MAX_CALL_COUNT
    
    @property
    def name(self) -> str:
        return "inlining"
    
    def can_optimize(self, stmt, ctx: OptimizationContext) -> bool:
        """Statement-level optimization not used; this works at call sites."""
        return False
    
    def optimize(self, stmt, ctx: OptimizationContext) -> bool:
        return False
    
    def analyze_functions(self, functions_ast: Dict, recursive_funcs: set):
        """Analyze which functions should be inlined.
        
        Args:
            functions_ast: Dict of function_name -> YulFunctionDef
            recursive_funcs: Set of function names that are recursive
        """
        self.call_counts.clear()
        self.inlinable_functions.clear()
        
        # Count calls to each function
        for fname, fdef in functions_ast.items():
            self._count_calls(fdef.body, functions_ast)
        
        for fname, fdef in functions_ast.items():
            if self._should_inline(fname, fdef, functions_ast, recursive_funcs):
                self.inlinable_functions.add(fname)
    
    def should_inline(self, func_name: str) -> bool:
        """Check if a function call should be inlined."""
        return func_name in self.inlinable_functions
    
    def get_inline_prefix(self) -> str:
        """Get unique prefix for inlined variables."""
        self.inline_counter += 1
        return f"inl{self.inline_counter}_"
    
    def _should_inline(self, fname: str, fdef, functions_ast: Dict, recursive_funcs: set) -> bool:
        """Determine if a function should be inlined."""
        # Never inline recursive functions
        if fname in recursive_funcs:
            return False
        
        # Never inline halting functions (return/revert/stop)
        if self._is_halting(fdef):
            return False
        
        # Check if it's a leaf function (no user function calls)
        if not self._is_leaf(fdef.body, functions_ast):
            return False
        
        # Check size (rough estimate: count statements)
        stmt_count = self._count_statements(fdef.body)
        if stmt_count > self.max_statements:
            return False
        
        # Check call count (inline if called within threshold only)
        if self.call_counts.get(fname, 0) > self.max_call_count:
            return False
        
        return True
    
    def _is_halting(self, fdef) -> bool:
        """Check if function contains EVM halt instructions."""
        return self._contains_halt(fdef.body)
    
    def _contains_halt(self, stmt) -> bool:
        """Recursively check for halt instructions."""
        stmt_type = type(stmt).__name__
        
        if stmt_type == "YulBlock":
            return any(self._contains_halt(s) for s in stmt.statements)
        elif stmt_type == "YulExpressionStmt":
            return self._contains_halt(stmt.expr)
        elif stmt_type == "YulCall":
            return stmt.function in ("return", "revert", "stop", "selfdestruct", "invalid")
        elif stmt_type == "YulIf":
            return self._contains_halt(stmt.body)
        elif stmt_type == "YulSwitch":
            return any(self._contains_halt(c.body) for c in stmt.cases)
        elif stmt_type == "YulForLoop":
            return (self._contains_halt(stmt.body) or 
                    self._contains_halt(stmt.post) if stmt.post else False)
        
        return False
    
    def _is_leaf(self, stmt, functions_ast: Dict) -> bool:
        """Check if statement only calls built-in functions."""
        stmt_type = type(stmt).__name__
        
        if stmt_type == "YulBlock":
            return all(self._is_leaf(s, functions_ast) for s in stmt.statements)
        elif stmt_type == "YulExpressionStmt":
            return self._is_leaf(stmt.expr, functions_ast)
        elif stmt_type == "YulCall":
            # If it calls a user function, not a leaf
            if stmt.function in functions_ast:
                return False
            return all(self._is_leaf(a, functions_ast) for a in stmt.args)
        elif stmt_type == "YulVariableDeclaration":
            if stmt.value:
                return self._is_leaf(stmt.value, functions_ast)
            return True
        elif stmt_type == "YulAssignment":
            return self._is_leaf(stmt.value, functions_ast)
        elif stmt_type == "YulIf":
            return self._is_leaf(stmt.condition, functions_ast) and self._is_leaf(stmt.body, functions_ast)
        elif stmt_type == "YulSwitch":
            return all(self._is_leaf(c.body, functions_ast) for c in stmt.cases)
        elif stmt_type == "YulForLoop":
            return (self._is_leaf(stmt.init, functions_ast) and
                    self._is_leaf(stmt.condition, functions_ast) and
                    self._is_leaf(stmt.body, functions_ast) and
                    self._is_leaf(stmt.post, functions_ast))
        
        return True
    
    def _count_statements(self, stmt) -> int:
        """Count statements for size estimation."""
        stmt_type = type(stmt).__name__
        
        if stmt_type == "YulBlock":
            return sum(self._count_statements(s) for s in stmt.statements)
        elif stmt_type in ("YulExpressionStmt", "YulVariableDeclaration", "YulAssignment"):
            return 1
        elif stmt_type == "YulIf":
            return 1 + self._count_statements(stmt.body)
        elif stmt_type == "YulSwitch":
            return 1 + sum(self._count_statements(c.body) for c in stmt.cases)
        elif stmt_type == "YulForLoop":
            return 3 + self._count_statements(stmt.body)
        
        return 1
    
    def _count_calls(self, stmt, functions_ast: Dict):
        """Count function calls for inlining threshold."""
        stmt_type = type(stmt).__name__
        
        if stmt_type == "YulBlock":
            for s in stmt.statements:
                self._count_calls(s, functions_ast)
        elif stmt_type == "YulExpressionStmt":
            self._count_calls(stmt.expr, functions_ast)
        elif stmt_type == "YulCall":
            if stmt.function in functions_ast:
                self.call_counts[stmt.function] = self.call_counts.get(stmt.function, 0) + 1
            for a in stmt.args:
                self._count_calls(a, functions_ast)
        elif stmt_type == "YulVariableDeclaration":
            if stmt.value:
                self._count_calls(stmt.value, functions_ast)
        elif stmt_type == "YulAssignment":
            self._count_calls(stmt.value, functions_ast)
        elif stmt_type == "YulIf":
            self._count_calls(stmt.condition, functions_ast)
            self._count_calls(stmt.body, functions_ast)
        elif stmt_type == "YulSwitch":
            self._count_calls(stmt.condition, functions_ast)
            for c in stmt.cases:
                self._count_calls(c.body, functions_ast)
        elif stmt_type == "YulForLoop":
            self._count_calls(stmt.init, functions_ast)
            self._count_calls(stmt.condition, functions_ast)
            self._count_calls(stmt.body, functions_ast)
            self._count_calls(stmt.post, functions_ast)


# =============================================================================
# Selector Dispatch Optimization (djmp)
# =============================================================================

class SelectorDispatchOptimizer(YulOptimizer):
    """Convert linear selector dispatch to hash-bucket djmp.
    
    Current pattern (O(n) linear search):
    ```venom
    %sel = shr 224, (calldataload 0)
    %m1 = eq %sel, 0xABC...
    jnz %m1, @case1, @next1
    next1:
    %m2 = eq %sel, 0xDEF...
    jnz %m2, @case2, @fallback
    ```
    
    Optimized pattern (O(1) hash lookup):
    ```venom
    %sel = shr 224, (calldataload 0)
    %bucket = mod %sel, N
    djmp %bucket, @bucket_0, @bucket_1, ..., @fallback
    ```
    
    Note: This requires data section support in Venom.
    Currently we emit an optimized version if there are few selectors,
    using a small modulo-based dispatch table.
    """
    
    @property
    def name(self) -> str:
        return "djmp_dispatch"
    
    def can_optimize(self, stmt, ctx: OptimizationContext) -> bool:
        """Check if statement is a switch on selector."""
        if type(stmt).__name__ != "YulSwitch":
            return False
        
        # Check if switching on shr(224, calldataload(0))
        expr = stmt.condition
        if type(expr).__name__ != "YulCall":
            return False
        
        return self._is_selector_expression(expr)
    
    def optimize(self, stmt, ctx: OptimizationContext) -> bool:
        """Emit optimized selector dispatch."""
        # For now, we emit the existing linear dispatch
        # A full djmp implementation requires data section support
        # which is complex. Instead, we can optimize by:
        # 1. Sorting cases by frequency (if profiling available)
        # 2. Using a small lookup table for <= 8 selectors
        
        # TODO: Implement djmp with data section when available
        return False
    
    def analyze_switch(self, stmt) -> Dict:
        """Analyze a selector switch for optimization opportunities.
        
        Returns:
            Dict with analysis results:
            - 'selectors': List of (selector_value, body) tuples
            - 'has_default': Whether there's a default case
            - 'can_use_djmp': Whether djmp is beneficial
        """
        result = {
            'selectors': [],
            'has_default': False,
            'can_use_djmp': False
        }
        
        for case in stmt.cases:
            if case.value is None or case.value == 'default':
                result['has_default'] = True
            else:
                # Extract selector value
                try:
                    val = case.value.value if hasattr(case.value, 'value') else str(case.value)
                    if isinstance(val, str):
                        val = int(val, 16) if val.startswith("0x") else int(val)
                    result['selectors'].append((val, case.body))
                except ValueError:
                    pass
        
        # djmp is beneficial for 4+ selectors
        result['can_use_djmp'] = len(result['selectors']) >= 4
        
        return result
    
    def compute_bucket_assignments(self, selectors: List[int], n_buckets: int) -> Dict[int, List[int]]:
        """Compute which selectors map to which buckets.
        
        Args:
            selectors: List of selector values
            n_buckets: Number of buckets to use
            
        Returns:
            Dict mapping bucket_index -> [selectors in bucket]
        """
        buckets = {i: [] for i in range(n_buckets)}
        for sel in selectors:
            bucket = sel % n_buckets
            buckets[bucket].append(sel)
        return buckets
    
    def _is_selector_expression(self, expr) -> bool:
        """Check if expression is shr(224, calldataload(0))."""
        if expr.function != "shr":
            return False
        
        if len(expr.args) != 2:
            return False
        
        # Check shift amount is 224
        shift_arg = expr.args[0]
        if type(shift_arg).__name__ == "YulLiteral":
            try:
                val = shift_arg.value
                if isinstance(val, str):
                    val = int(val, 16) if val.startswith("0x") else int(val)
                if val != 224:
                    return False
            except ValueError:
                return False
        else:
            return False
        
        # Check calldataload(0)
        cd_arg = expr.args[1]
        if type(cd_arg).__name__ != "YulCall":
            return False
        if cd_arg.function != "calldataload":
            return False
        if len(cd_arg.args) != 1:
            return False
        
        offset_arg = cd_arg.args[0]
        if type(offset_arg).__name__ == "YulLiteral":
            try:
                val = offset_arg.value
                if isinstance(val, str):
                    val = int(val, 16) if val.startswith("0x") else int(val)
                return val == 0
            except ValueError:
                return False
        
        return False


# =============================================================================
# Optimization Pipeline
# =============================================================================

class OptimizationPipeline:
    """Orchestrates all Yul→Venom optimizations.
    
    Usage:
        pipeline = OptimizationPipeline()
        
        # Before generating IR
        pipeline.analyze(functions_ast, recursive_funcs)
        
        # During statement processing
        if pipeline.try_optimize_stmt(stmt, ctx):
            return  # Optimization handled it
    """
    
    def __init__(self):
        self.assert_optimizer = AssertOptimizer()
        self.sha3_optimizer = Sha3Optimizer()
        self.inlining_optimizer = InliningOptimizer()
        self.dispatch_optimizer = SelectorDispatchOptimizer()
        
        # Statement-level optimizers (order matters)
        self.stmt_optimizers = [
            self.assert_optimizer,
            # dispatch_optimizer is handled specially in switch processing
        ]
    
    def analyze(self, functions_ast: Dict, recursive_funcs: set):
        """Analyze function AST for optimization opportunities.
        
        Call this before starting IR generation.
        """
        self.inlining_optimizer.analyze_functions(functions_ast, recursive_funcs)
    
    def try_optimize_stmt(self, stmt, ctx: OptimizationContext) -> bool:
        """Try to optimize a statement. Returns True if handled."""
        for optimizer in self.stmt_optimizers:
            if optimizer.can_optimize(stmt, ctx):
                return optimizer.optimize(stmt, ctx)
        return False
    
    def should_inline(self, func_name: str) -> bool:
        """Check if a function should be inlined."""
        return self.inlining_optimizer.should_inline(func_name)
    
    def get_inline_prefix(self) -> str:
        """Get unique prefix for inlined variables."""
        return self.inlining_optimizer.get_inline_prefix()
    
    def can_use_sha3_64(self, offset_arg, size_arg, recent_mstores: List) -> bool:
        """Check if keccak256 can use sha3_64."""
        return self.sha3_optimizer.can_optimize_keccak(offset_arg, size_arg, recent_mstores)
    
    def get_sha3_64_operands(self, recent_mstores: List) -> tuple:
        """Get slot and key for sha3_64."""
        return self.sha3_optimizer.get_sha3_64_operands(recent_mstores)
    
    def analyze_selector_switch(self, stmt) -> Dict:
        """Analyze switch for djmp optimization."""
        return self.dispatch_optimizer.analyze_switch(stmt)
    
    def try_optimize_operand(self, op: str, operands: list, append_fn) -> Any:
        """Try algebraic identity optimization on an operation.
        
        Returns optimized value (IRLiteral/IRVariable) or None if no optimization.
        """
        return self.algebraic_optimizer.try_optimize(op, operands, append_fn)


# =============================================================================
# Algebraic Identity Optimizer
# =============================================================================

class AlgebraicOptimizer:
    """Algebraic identity elimination and constant folding.
    
    Eliminates trivial operations at IR generation time:
    - add(x, 0) = x
    - mul(x, 1) = x
    - sub(x, x) = 0
    - and(x, -1) = x
    - xor(x, 0) = x
    - shl(0, x) = x
    - etc.
    
    Also handles operand deduplication to satisfy Venom's SSA requirements.
    """
    
    # Maximum uint256 value (used for -1 in two's complement)
    MAX_UINT256 = 2**256 - 1
    
    def try_optimize(self, op: str, operands: list, append_fn) -> Any:
        """Try to optimize an operation.
        
        Args:
            op: The opcode (add, sub, mul, etc.)
            operands: List of operands (IRVariable or IRLiteral)
            append_fn: Function to append instructions (for deduplication)
            
        Returns:
            Optimized value if optimization applied, None otherwise.
        """
        # Try identity elimination first
        result = self._try_identity_elimination(op, operands)
        if result is not None:
            return result
        
        # Try constant folding
        result = self._try_constant_fold(op, operands)
        if result is not None:
            return result
        
        return None
    
    def deduplicate_operands(self, operands: list, append_fn) -> list:
        """Ensure no duplicate variable consumption.
        
        Venom SSA forbids consuming the same variable twice.
        Creates aliases using add(x, 0) for duplicates.
        
        Args:
            operands: List of operands
            append_fn: Function to append instructions
            
        Returns:
            New operand list with duplicates aliased
        """
        seen_vars = set()
        new_operands = []
        
        for arg in operands:
            if isinstance(arg, IRVariable):
                if arg.name in seen_vars:
                    # Duplicate! Create alias
                    alias_var = append_fn("add", arg, IRLiteral(0))
                    new_operands.append(alias_var)
                    continue
                else:
                    seen_vars.add(arg.name)
            new_operands.append(arg)
        
        return new_operands
    
    def _try_identity_elimination(self, op: str, operands: list) -> Any:
        """Try identity elimination rules."""
        if len(operands) != 2:
            return None
        
        a, b = operands
        a_is_zero = isinstance(a, IRLiteral) and a.value == 0
        b_is_zero = isinstance(b, IRLiteral) and b.value == 0
        a_is_one = isinstance(a, IRLiteral) and a.value == 1
        b_is_one = isinstance(b, IRLiteral) and b.value == 1
        a_is_neg1 = isinstance(a, IRLiteral) and a.value == self.MAX_UINT256
        b_is_neg1 = isinstance(b, IRLiteral) and b.value == self.MAX_UINT256
        
        # add(x, 0) = x, add(0, x) = x
        if op == "add":
            if b_is_zero:
                return a
            if a_is_zero:
                return b
        
        # sub(x, 0) = x
        if op == "sub" and b_is_zero:
            return a
        
        # sub(x, x) = 0
        if op == "sub" and isinstance(a, IRVariable) and isinstance(b, IRVariable) and a.name == b.name:
            return IRLiteral(0)
        
        # mul(x, 1) = x, mul(1, x) = x, mul(x, 0) = 0
        if op == "mul":
            if b_is_one:
                return a
            if a_is_one:
                return b
            if a_is_zero or b_is_zero:
                return IRLiteral(0)
        
        # and(x, -1) = x, and(-1, x) = x, and(x, 0) = 0
        if op == "and":
            if b_is_neg1:
                return a
            if a_is_neg1:
                return b
            if a_is_zero or b_is_zero:
                return IRLiteral(0)
        
        # or(x, 0) = x, or(0, x) = x, or(x, -1) = -1
        if op == "or":
            if b_is_zero:
                return a
            if a_is_zero:
                return b
            if a_is_neg1 or b_is_neg1:
                return IRLiteral(self.MAX_UINT256)
        
        # xor(x, 0) = x, xor(0, x) = x, xor(x, x) = 0
        if op == "xor":
            if b_is_zero:
                return a
            if a_is_zero:
                return b
            if isinstance(a, IRVariable) and isinstance(b, IRVariable) and a.name == b.name:
                return IRLiteral(0)
        
        # div(x, 1) = x
        if op == "div" and b_is_one:
            return a
        
        # exp(x, 0) = 1 (any number to power 0 is 1)
        # exp(x, 1) = x (any number to power 1 is itself)
        # exp opcode costs ~50+ gas, so these are significant savings
        if op == "exp":
            if b_is_zero:
                return IRLiteral(1)
            if b_is_one:
                return a
        
        # POWER-OF-2 OPTIMIZATIONS
        # mul(x, 2^n) = shl(n, x) - saves gas (shl is cheaper than mul)
        if op == "mul" and isinstance(b, IRLiteral) and b.value > 1:
            log2 = self._log2_exact(b.value)
            if log2 is not None:
                # Return None to let normal emit happen, but with transformed op
                # We can't directly emit here, so this pattern is already handled
                # by AlgebraicOptimizationPass in Venom pipeline
                pass
        
        # div(x, 2^n) = shr(n, x) - saves gas (shr is cheaper than div)
        if op == "div" and isinstance(b, IRLiteral) and b.value > 1:
            log2 = self._log2_exact(b.value)
            if log2 is not None:
                pass  # Handled by Venom AlgebraicOptimizationPass
        
        # mod(x, 2^n) = and(x, 2^n - 1)
        if op == "mod" and isinstance(b, IRLiteral) and b.value > 1:
            log2 = self._log2_exact(b.value)
            if log2 is not None:
                # mod 2^n = and (2^n - 1)
                pass  # Handled by Venom AlgebraicOptimizationPass
        
        # shr(0, x) = x, shl(0, x) = x
        if op in ("shr", "shl") and a_is_zero:
            return b
        
        # eq(x, x) = 1
        if op == "eq" and isinstance(a, IRVariable) and isinstance(b, IRVariable) and a.name == b.name:
            return IRLiteral(1)
        
        # lt(x, x) = 0, gt(x, x) = 0, slt(x, x) = 0, sgt(x, x) = 0
        if op in ("lt", "gt", "slt", "sgt"):
            if isinstance(a, IRVariable) and isinstance(b, IRVariable) and a.name == b.name:
                return IRLiteral(0)
        
        # lt(x, 0) = 0 for unsigned (nothing is less than 0)
        if op == "lt" and b_is_zero:
            return IRLiteral(0)
        
        # gt(0, x) = 0 for unsigned (0 is not greater than anything)
        if op == "gt" and a_is_zero:
            return IRLiteral(0)
        
        return None
    
    def _log2_exact(self, n: int) -> int:
        """Return log2(n) if n is an exact power of 2, else None."""
        if n <= 0 or (n & (n - 1)) != 0:
            return None
        log2 = 0
        while n > 1:
            n >>= 1
            log2 += 1
        return log2
    
    def _try_constant_fold(self, op: str, operands: list) -> Any:
        """Try constant folding for unary operations."""
        if len(operands) != 1:
            return None
        
        a = operands[0]
        if not isinstance(a, IRLiteral):
            return None
        
        # not(31) = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0
        if op == "not" and a.value == 31:
            return IRLiteral(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0)
        
        # not(0) = -1 (all ones)
        if op == "not" and a.value == 0:
            return IRLiteral(self.MAX_UINT256)
        
        # iszero(0) = 1
        if op == "iszero" and a.value == 0:
            return IRLiteral(1)
        
        # iszero(non-zero) = 0
        if op == "iszero" and a.value != 0:
            return IRLiteral(0)
        
        return None


# Add algebraic optimizer to pipeline
OptimizationPipeline.algebraic_optimizer = AlgebraicOptimizer()

