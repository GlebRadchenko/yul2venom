import sys

try:
    from yul2venom.ir.context import IRContext
    from yul2venom.ir.function import IRFunction
    from yul2venom.ir.basicblock import IRBasicBlock, IRInstruction, IRLabel, IRVariable, IRLiteral
    from yul2venom.parser.yul_parser import YulLiteral, YulCall, YulVariableDeclaration, YulAssignment, YulIf, YulSwitch, YulForLoop, YulBlock, YulCase, YulExpressionStmt
except ImportError:
    from ir.context import IRContext
    from ir.function import IRFunction
    from ir.basicblock import IRBasicBlock, IRInstruction, IRLabel, IRVariable, IRLiteral
    from parser.yul_parser import YulLiteral, YulCall, YulVariableDeclaration, YulAssignment, YulIf, YulSwitch, YulForLoop, YulBlock, YulCase, YulExpressionStmt

# Import Allocation for proper alloca registration with mem_allocator
try:
    from vyper.venom.memory_location import Allocation
except ImportError:
    Allocation = None  # Fallback if not available

# Import memory layout constants from centralized location
try:
    from yul2venom.utils.constants import VENOM_MEMORY_START, YUL_FMP_SLOT
except ImportError:
    from utils.constants import VENOM_MEMORY_START, YUL_FMP_SLOT

# Import optimization pipeline
try:
    from yul2venom.generator.optimizations import OptimizationPipeline, OptimizationContext
except ImportError:
    from generator.optimizations import OptimizationPipeline, OptimizationContext


# Pre-compile translation table
TRANS_TABLE = str.maketrans({'.': '_', ':': '_', '=': 'eq', '$': '_'})

class VenomIRBuilder:
    """
    Venom-Native Generator: Transpiles Yul AST to Venom IR.
    
    Key Design Principles:
    1. OPERAND ORDER: Emits Venom-native order (size, offset, dst) not EVM order
    2. PURE REGISTERS: Uses var_map for direct register allocation, no alloca
    3. INLINING: DAG functions inlined, recursive functions use invoke
    4. CONTROL FLOW: Maps Yul if/switch/for to Venom jnz/djmp/jmp
    
    Calling Convention: param/invoke/ret for inter-function calls
    """
    def __init__(self, config=None):
        # Import config loader if config not provided
        if config is None:
            try:
                from config import get_config
                config = get_config()
            except ImportError:
                config = None
        self.config = config
        
        # Log config values being used
        if self.config:
            print(f"CONFIG: inlining.enabled={config.inlining.enabled}, "
                  f"stmt_threshold={config.inlining.stmt_threshold}, "
                  f"call_threshold={config.inlining.call_threshold}", file=sys.stderr)
        
        self.ctx = IRContext()
        self.current_fn = None
        self.current_bb = None
        self.current_return_names = [] # Track return var NAMES
        
        # NO MORE MEMORY-BASED STACK!
        # Venom uses EVM stack directly via invoke/param/ret
        
        self.label_counter = 0
        self.var_map = {}           # Maps Yul variable names to IRVariable (direct register values)
        self.functions_ast = {}     # Stores parsed Yul function definitions
        
        self.loop_stack = []        # Stack of (start_label, end_label, post_label) for loops
        self.inline_exit_stack = []  # Stack of function names for inlined function calls
        self.inline_exited = False   # Flag set when leave encountered in inlined context
        self.recursive_functions = set()  # Functions in recursive cycles - must use invoke/ret
        self.inlinable_functions = set()  # Non-recursive functions (form a DAG, not a cycle) - can inline
        self.emit_as_functions = set()    # Non-recursive but too large/frequent to inline - emit for invoke
        
        # VENOM-NATIVE: Scratch alloca ID counter for unique memory allocation tracking
        # Mirrors native Vyper's get_scratch_alloca_id() pattern
        self.scratch_alloca_id = 0
        # Track alloca base position for sequential allocation
        # Use config.memory if available, otherwise fall back to constants
        if self.config:
            self.alloca_mem_position = self.config.memory.venom_start
        else:
            self.alloca_mem_position = VENOM_MEMORY_START  # Fallback to constant
        
        # DEFERRED FMP PATTERN: Track pending FMP updates to emit after allocation use
        # This fixes the bug where mload(64) result is lost due to stack manipulation
        # before the struct pointer is stored to the array.
        # Format: (newFMP_var, block) or None
        self.pending_fmp_update = None
        
        # OPTIMIZATION PIPELINE: Modular optimization system
        self.optimizer = OptimizationPipeline()
        
        # SHA3_64 OPTIMIZATION: Track recent mstore operations for pattern detection
        # Pattern: mstore(0x00, key) + mstore(0x20, slot) + keccak256(0x00, 64) -> sha3_64 slot, key
        self.recent_mstores = []  # List of (offset_operand, value_operand) tuples
        
        # INIT CODE SUPPORT: Literal offsets for dataoffset() in init code
        # Maps object_name -> literal_offset (e.g. "Contract_deployed" -> 202)
        # When set, dataoffset returns literal instead of codesize - datasize
        self.offset_map = {}

    def new_label(self, suffix="block"):
        # Use Context's label generator for consistency context-wide?
        # Context uses integer counter. We want descriptive names.
        self.label_counter += 1
        return self.ctx.get_next_label(suffix) # e.g. 1_block

    def sanitize(self, name):
        return name.translate(TRANS_TABLE)

    def _flush_pending_fmp(self):
        """
        Emit any pending FMP update that was deferred from allocate_memory.
        
        This implements the "Use-Before-Commit" pattern:
        - allocate_memory captures FMP (mload 64) immediately
        - The FMP update (mstore 64, newFMP) is deferred
        - We flush the update before the next statement
        
        This ensures the allocation pointer is used BEFORE the FMP is updated,
        preventing the pointer from being lost due to stack manipulation.
        """
        if self.pending_fmp_update is not None:
            new_fmp, _ = self.pending_fmp_update
            self.current_bb.append_instruction("mstore", new_fmp, IRLiteral(64))
            self.pending_fmp_update = None

    def _is_halting_function(self, f_def):
        """
        Detect if function is a strictly halting function.
        
        Halting functions terminate via EVM return/revert/stop, NOT via `ret`.
        They don't consume a return PC from the stack.
        """
        # Main entry is halting - terminates via return/revert/stop
        # Solc generated "external_fun_" functions use EVM return() and are tail-called
        return f_def.name == "__main_entry" or f_def.name.startswith("external_fun_")

    def build(self, yul_ast, data_map=None, immutables=None, offset_map=None):
        self.data_map = data_map or {}
        self.ctx.immutables = immutables or {}
        self.offset_map = offset_map or {}  # INIT CODE: literal offsets for dataoffset()
        
        # 1. Collect functions (Recursive)
        # Check top-level functions (siblings of code)
        if yul_ast.functions:
            for f in yul_ast.functions:
                self.functions_ast[f.name] = f
        
        # Check functions nested inside code block (recursive)
        if yul_ast.code and yul_ast.code.statements:
             self._recursive_scan_functions(yul_ast.code.statements)

        # 3. HYBRID APPROACH: Build call graph to detect recursion
        #    - Inlinable: Functions not in any recursive cycle
        #    - Recursive: Functions that are/call recursive functions (keep invoke/ret)
        self._build_call_graph()
        
        # 4. Build ONLY recursive functions as separate IR functions
        for fname in sorted(self.recursive_functions):
            self._build_function(self.functions_ast[fname])

        # 5. Build non-recursive functions marked for emission (inlining heuristic)
        # These are large/frequent functions that benefit from O(1) dispatch via invoke
        for fname in sorted(self.emit_as_functions):
            self._build_function(self.functions_ast[fname])

        # 6. Build Global/Main
        self._build_main(yul_ast)
        
        return self.ctx

    def _recursive_scan_functions(self, stmts):
        for stmt in stmts:
             s_type = type(stmt).__name__
             if s_type == "YulFunctionDef":
                 self.functions_ast[stmt.name] = stmt
                 # Don't recurse into function body for other functions? 
                 # Yul allows functions inside functions?
                 # Even if so, we flatten them.
                 if stmt.body and stmt.body.statements:
                     self._recursive_scan_functions(stmt.body.statements)
                     
             elif s_type == "YulBlock":
                 self._recursive_scan_functions(stmt.statements)
             elif s_type == "YulIf":
                 self._recursive_scan_functions([stmt.body])
             elif s_type == "YulSwitch":
                 for c in stmt.cases:
                     self._recursive_scan_functions([c.body])
             elif s_type == "YulForLoop":
                 self._recursive_scan_functions([stmt.init, stmt.body, stmt.post])

    def _build_call_graph(self):
        call_graph = {}
        for fname, f_def in self.functions_ast.items():
            callees = set()
            self._collect_callees(f_def.body, callees)
            call_graph[fname] = callees
        WHITE, GRAY, BLACK = 0, 1, 2
        color = {fname: WHITE for fname in self.functions_ast}
        def dfs(node, path):
            if node not in color:
                return False
            if color[node] == GRAY:
                for fn in path[path.index(node):]:
                    self.recursive_functions.add(fn)
                return True
            if color[node] == BLACK:
                return False
            color[node] = GRAY
            path.append(node)
            for callee in call_graph.get(node, set()):
                if dfs(callee, path):
                    self.recursive_functions.add(node)
            path.pop()
            color[node] = BLACK
            return False
        for fname in self.functions_ast:
            if color[fname] == WHITE:
                dfs(fname, [])
        self.inlinable_functions = set(self.functions_ast.keys()) - self.recursive_functions
        
        # INLINING HEURISTIC: Emit large/frequent functions instead of inlining everywhere
        # This enables O(1) function dispatch via djmp jump tables
        # Thresholds configurable via yul2venom.config.yaml
        if self.config and self.config.inlining.enabled:
            STMT_THRESHOLD = self.config.inlining.stmt_threshold
            CALL_THRESHOLD = self.config.inlining.call_threshold
        else:
            STMT_THRESHOLD = 1    # Default: Functions with >1 statements 
            CALL_THRESHOLD = 2    # Default: Called more than 2 times
        
        # Count ALL call sites for each function
        call_site_counts = {fname: 0 for fname in self.functions_ast}
        
        def count_calls_in_node(node):
            """Recursively count function calls in AST node."""
            if node is None:
                return
            node_type = type(node).__name__
            if node_type == 'YulCall':
                if node.function in self.functions_ast:
                    call_site_counts[node.function] += 1
                for arg in node.args:
                    count_calls_in_node(arg)
            elif node_type == 'YulBlock':
                for stmt in node.statements:
                    count_calls_in_node(stmt)
            elif node_type in ('YulVariableDeclaration', 'YulAssignment'):
                count_calls_in_node(getattr(node, 'value', None))
            elif node_type == 'YulIf':
                count_calls_in_node(node.condition)
                count_calls_in_node(node.body)
            elif node_type == 'YulSwitch':
                count_calls_in_node(node.condition)
                for case in node.cases:
                    count_calls_in_node(case.body)
            elif node_type == 'YulForLoop':
                for part in [node.init, node.condition, node.body, node.post]:
                    count_calls_in_node(part)
            elif node_type == 'YulExpressionStmt':
                count_calls_in_node(node.expr)
        
        for fname, f_def in self.functions_ast.items():
            if f_def.body:
                count_calls_in_node(f_def.body)
        
        # Mark large/frequent functions for emission instead of inlining
        for fname in list(self.inlinable_functions):
            f_def = self.functions_ast.get(fname)
            if f_def and f_def.body:
                stmt_count = self._count_statements(f_def.body)
                call_count = call_site_counts.get(fname, 0)
                
                if stmt_count > STMT_THRESHOLD and call_count > CALL_THRESHOLD:
                    self.emit_as_functions.add(fname)
                    self.inlinable_functions.discard(fname)
                    if self.config and getattr(getattr(self.config, "debug", None), "verbose_inlining", False):
                        print(f"INLINING: Emitting {fname} (stmts={stmt_count}, calls={call_count})", file=sys.stderr)
        
        if self.emit_as_functions and self.config and getattr(getattr(self.config, "debug", None), "verbose_inlining", False):
            print(f"INLINING: {len(self.emit_as_functions)} functions marked for emission", file=sys.stderr)
        
        # OPTIMIZATION: Let the optimization pipeline analyze functions for inlining
        self.optimizer.analyze(self.functions_ast, self.recursive_functions)

    def _collect_callees(self, node, callees):
        if node is None:
            return
        node_type = type(node).__name__
        if node_type == 'YulCall':
            if node.function in self.functions_ast:
                callees.add(node.function)
            for arg in node.args:
                self._collect_callees(arg, callees)
        elif node_type == 'YulBlock':
            for stmt in node.statements:
                self._collect_callees(stmt, callees)
        elif node_type in ('YulVariableDeclaration', 'YulAssignment'):
            self._collect_callees(getattr(node, 'value', None), callees)
        elif node_type == 'YulIf':
            self._collect_callees(node.condition, callees)
            self._collect_callees(node.body, callees)
        elif node_type == 'YulSwitch':
            self._collect_callees(node.condition, callees)
            for case in node.cases:
                self._collect_callees(case.body, callees)
        elif node_type == 'YulForLoop':
            for part in [node.init, node.condition, node.body, node.post]:
                self._collect_callees(part, callees)
        elif node_type == 'YulExpressionStmt':
            self._collect_callees(node.expr, callees)

    def _log2_exact(self, n: int):
        """Return log2(n) if n is an exact power of 2, else None.
        
        Used for power-of-2 optimizations:
        - mul(x, 2^n) → shl(n, x)   (5 gas → 3 gas)
        - div(x, 2^n) → shr(n, x)   (5 gas → 3 gas)
        - mod(x, 2^n) → and(x, 2^n-1) (5 gas → 3 gas)
        """
        if n <= 0 or (n & (n - 1)) != 0:
            return None
        log2 = 0
        while n > 1:
            n >>= 1
            log2 += 1
        return log2

    def _build_main(self, yul_obj):
        fn = self.ctx.create_function("__main_entry")
        self.current_fn = fn
        self.ctx.entry_function = fn
        # Build Global (Main) function
        entry_bb = IRBasicBlock(self.ctx.get_next_label("__main_entry"), fn)
        fn.append_basic_block(entry_bb)
        self.current_bb = entry_bb
        
        # NO MORE SP INITIALIZATION - Venom uses EVM stack directly
        
        # Body
        if yul_obj.code and yul_obj.code.statements:
             for stmt in yul_obj.code.statements:
                 # Check if it's not a function definition (already handled)
                 # In parser, functions are separate from code block in Object, but inside code block in Block?
                 # Parser structure: Object(code=Block, functions=[FuncDef])
                 # Functions are extracted to object level.
                 # So code.statements should only contain executables + vars
                 self._visit_stmt(stmt)
            
        # Terminate
        if not self.current_bb.is_terminated:
            self.current_bb.append_instruction("stop")

    def _build_function(self, f_def):
        """
        VENOM-NATIVE: Create a proper IRFunction with args and returns.
        Uses `param` for arguments (popped from stack) and `ret` for returns.
        """
        fname = self.sanitize(f_def.name)
        
        # Create function in context with signature
        num_inputs = len(f_def.args) if f_def.args else 0
        num_outputs = len(f_def.returns) if f_def.returns else 0
        fn = self.ctx.create_function(fname) # create_function calls with correct args? 
        # Wait, context.create_function takes name. IRFunction ctor takes args? No.
        # check context.py logic? "create_function(self, name: str) -> IRFunction"
        # So "num_inputs" handling in my previous code was probably wrong/ignored? 
        # context.py:
        # def create_function(self, name: str) -> IRFunction:
        # It doesn't take num_inputs.
        
        self.current_fn = fn
        self.var_map = {} # Local scope
        
        # Entry Block
        # VENOM FIX: Invoke targets the function name, so the entry block MUST have that label.
        entry_label = IRLabel(fname)
        self.current_bb = IRBasicBlock(entry_label, self.current_fn)
        self.current_fn.append_basic_block(self.current_bb)

        # Handle Arguments (param instruction)
        # In Venom, `param` declares a stack item popped from caller
        
        # CRITICAL: Detect if this function is "halting" (contains EVM return/revert/stop)
        # Halting functions don't use `ret` so their PC param would be marked dead and popped early.
        is_halting = self._is_halting_function(f_def)
        
        # DEBUG: Uniquely identify which revert helper is called
        if fname.startswith("revert_error_"):
            # Name format: revert_error_HEX
            try:
                # Extract hash part (after 2nd underscore)
                parts = fname.split('_')
                if len(parts) >= 3:
                    hash_str = parts[2] 
                    # Take first 8 chars (4 bytes)
                    val = int(hash_str[:8], 16)
                    # Emit Log - DISABLED for staticcall compliance
                    # self.current_bb.append_instruction("log1", IRLiteral(0), IRLiteral(0), IRLiteral(val))
            except:
                pass
        
        # For halting functions, the stack still has args but we won't use PC param
        # For non-halting functions, we capture PC for ret
        
        # Handle Arguments (param instruction)
        # Runtime Stack expected: [argN, ..., arg1, pc] (Top is pc)
        # StackModel fills from Bottom to Top.
        # So we iterate f_def.args in REVERSE.
        
        # Capture Arguments in reverse order
        self.current_arg_vars = []
        
        if is_halting:
            # Halting functions: declare PC param to consume it from invoke's stack,
            # but immediately pop it. This prevents liveness from marking it dead
            # (since pop "uses" it) while properly consuming the invoke's PC.
            if f_def.args:
                # Capture args in reverse (deepest first) before PC
                for arg_name in reversed(f_def.args):
                    p_var = self.current_bb.append_instruction("param")
                    self.current_arg_vars.append(p_var)
                    # VENOM NATIVE: Map param directly to var_map (no alloca)
                    self.var_map[arg_name] = p_var
            # Capture PC param (last/top of stack) and pop it
            # EXCEPTION: "external_fun_" are tail-called via JUMP without pushing a return label.
            # So the stack is empty (or has args). Do NOT attempt to consume PC.
            if not fname.startswith("external_fun_"):
                pc_var = self.current_bb.append_instruction("param")
                self.current_bb.append_instruction("pop", pc_var)
            else:
                # Debug logging for external function entry
                # Emit log1(0, 0, 0xAAAAAAAA...)
                # DISABLED for staticcall compliance
                # self.current_bb.append_instruction("log1", IRLiteral(0), IRLiteral(0), IRLiteral(0xAAAAAAAA))
                pass
            # Note: PC is now "used" by pop, so liveness won't mark it dead
        else:
            # Non-halting functions: stack model is built by pushing param outputs in instruction order
            # Runtime stack at entry: [arg1, arg2, ..., argN, PC] (PC on TOP)
            # Stack model push order must match: arg1 first (deepest), argN, then PC (top)
            # So emit params: args in FORWARD order, then PC
            
            # 1. Capture args in forward order (arg1 is deepest in runtime stack)
            if f_def.args:
                for arg_name in f_def.args:  # Forward order: arg1, arg2, ...
                    p_var = self.current_bb.append_instruction("param")
                    self.current_arg_vars.append(p_var)
                    self.var_map[arg_name] = p_var
            
            # 2. Capture PC last (it's on TOP of runtime stack)
            pc_var = self.current_bb.append_instruction("param")
            self.var_map['$pc'] = pc_var

        # Handle Output Variables (initialize to 0)
        self.current_return_names = []
        if f_def.returns:
            for ret_name in f_def.returns:
                # VENOM NATIVE: Initialize to IRLiteral(0) directly
                self.var_map[ret_name] = IRLiteral(0)
                self.current_return_names.append(ret_name)

        # Process Body
        if f_def.body and f_def.body.statements:
            for stmt in f_def.body.statements:
                 self._visit_stmt(stmt)

        # Handle implicit return if flow continues to end
        if not self.current_bb.is_terminated:
            if is_halting:
                # Halting functions should have been terminated by return/revert/stop
                # If we reach here, emit stop as fallback
                self.current_bb.append_instruction("stop")
            elif f_def.returns:
                ret_vals = []
                for ret_name in f_def.returns:
                    if ret_name in self.var_map:
                        # VENOM NATIVE: var_map contains registers directly, not memory pointers
                        val = self.var_map[ret_name]
                        # FIX: ALWAYS use add pattern for ALL values (both literals and variables).
                        # This forces a consistent sequence for stack ordering.
                        temp_var = self.current_fn.get_next_variable()
                        temp_var.annotation = f"ret_{ret_name}"
                        self.current_bb.append_instruction("add", val, IRLiteral(0), ret=temp_var)
                        ret_vals.append(temp_var)
                    else:
                        # Create a variable for the default 0 value
                        temp_var = self.current_fn.get_next_variable()
                        temp_var.annotation = f"ret_{ret_name}_default"
                        self.current_bb.append_instruction("add", IRLiteral(0), IRLiteral(0), ret=temp_var)
                        ret_vals.append(temp_var)
                # Return values first, PC last (native Vyper convention, no parser reversal)
                self.current_bb.append_instruction("ret", *ret_vals, self.var_map['$pc'])
            else:
                self.current_bb.append_instruction("ret", self.var_map['$pc'])
    
    def _inline_function_call(self, func_name, arg_vals):
        """
        Inline a Yul function call directly into the current basic block.
        
        Args:
            func_name: Name of the Yul function to inline
            arg_vals: List of IRVariable/IRLiteral for arguments
            
        Returns:
            List of IRVariable for return values
        """
        f_def = self.functions_ast.get(func_name)
        if not f_def:
            raise ValueError(f"Function {func_name} not found for inlining")
        
        # Save current variable scope
        saved_var_map = self.var_map.copy()
        
        # Map arguments to function parameters
        for arg_name, arg_val in zip(f_def.args, arg_vals):
            self.var_map[arg_name] = arg_val
        
        # Initialize return variables to 0 (VENOM NATIVE: direct mapping)
        if f_def.returns:
            for ret_name in f_def.returns:
                self.var_map[ret_name] = IRLiteral(0)
        
        # Create cleanup block for this inlined function
        cleanup_lbl = self.ctx.get_next_label(f"inline_cleanup_{func_name}")
        cleanup_bb = IRBasicBlock(cleanup_lbl, self.current_fn)
        
        # Dictionary to collect PHI inputs for each return variable
        # return_name -> list of {'val': val, 'label': label, 'block': block}
        phi_data = {name: [] for name in (f_def.returns or [])}
        
        # Push cleanup info onto stack: (cleanup_lbl, return_names, phi_data)
        self.inline_exit_stack.append((cleanup_lbl, f_def.returns or [], phi_data))
        
        # Inline function body
        if f_def.body and f_def.body.statements:
            for stmt in f_def.body.statements:
                self._visit_stmt(stmt)
        
        # Handle implicit fallthrough (end of function body without leave)
        if not self.current_bb.is_terminated:
            self.current_bb.append_instruction("jmp", cleanup_lbl)
            if f_def.returns:
                for ret_name in f_def.returns:
                    if ret_name in self.var_map:
                        phi_data[ret_name].append({
                            'val': self.var_map[ret_name], 
                            'label': self.current_bb.label, 
                            'block': self.current_bb
                        })
        
        # Pop exit stack
        self.inline_exit_stack.pop()
        
        # Check if any path reached the cleanup block (via phi_data or implicit fallthrough)
        has_predecessors = any(len(inputs) > 0 for inputs in phi_data.values()) if f_def.returns else (not self.current_bb.is_terminated)
        
        # If no return variables, check if we added an implicit fallthrough jump to cleanup
        # The fallthrough jump happens when block is not terminated before cleanup creation
        if not f_def.returns:
            # No returns - check if implicit fallthrough was added (current_bb should have jmp to cleanup_lbl)
            has_predecessors = False
            for bb in self.current_fn.get_basic_blocks():
                if bb.is_terminated:
                    last_inst = bb.instructions[-1] if bb.instructions else None
                    if last_inst and last_inst.opcode == "jmp":
                        if last_inst.operands and last_inst.operands[0] == cleanup_lbl:
                            has_predecessors = True
                            break
        else:
            # With returns - check phi_data
            has_predecessors = any(len(inputs) > 0 for inputs in phi_data.values())
        
        # Only add cleanup block if it's reachable
        if has_predecessors:
            self.current_fn.append_basic_block(cleanup_bb)
            self.current_bb = cleanup_bb
        
            # Generate PHI nodes for return values
            result_vals = []
            if f_def.returns:
                for ret_name in f_def.returns:
                    inputs = phi_data[ret_name]
                    if not inputs:
                        # Should not happen in reachable code, but default to 0
                        result_vals.append(IRLiteral(0))
                    elif len(inputs) == 1:
                        # Single path - no PHI needed
                        # Materialize value in CLEANUP block (current_bb), not source block
                        # This ensures the variable is defined in the block where it's used
                        val = inputs[0]['val']
                        if isinstance(val, IRLiteral):
                            # Literals just get assigned in the cleanup block
                            new_var = self.current_fn.get_next_variable()
                            self.current_bb.append_instruction("assign", val, ret=new_var)
                            result_vals.append(new_var)
                            self.var_map[ret_name] = new_var
                        else:
                            # Variables from source block - just use directly 
                            # (they're still in scope since single path means linear flow)
                            result_vals.append(val)
                            self.var_map[ret_name] = val
                    else:
                        # Multiple paths - emit PHI
                        phi_args = []
                        for item in inputs:
                            phi_args.append(item['label'])
                            val_reg = self._materialize_literal(item['val'], item['block'])
                            phi_args.append(val_reg)
                        
                        phi_res = self.current_bb.append_instruction("phi", *phi_args)
                        result_vals.append(phi_res)
                        self.var_map[ret_name] = phi_res
        else:
            # No paths reach cleanup - function always terminates (revert/stop/return)
            # Don't append the cleanup block - it would be dead code
            # Return empty results (function never returns normally)
            result_vals = [IRLiteral(0) for _ in (f_def.returns or [])]
        
        # Restore variable scope - restore ALL variables that existed before inlining.
        # This is critical to prevent local variables in the inlined function
        # (e.g., "memPtr_1" from allocate_memory) from permanently shadowing
        # outer scope variables with the same name.
        # The result returned from the inlined call will be assigned to the caller's
        # target variable separately, so we need the outer scope to be clean.
        for var_name, var_val in saved_var_map.items():
            self.var_map[var_name] = var_val
        
        return result_vals

    def _collect_assigned_vars(self, stmt, result_set):
        """Recursively collect variable names that are assigned in a statement."""
        stmt_type = type(stmt).__name__
        if stmt_type == "YulAssignment":
            for var_name in stmt.vars:
                result_set.add(var_name)
        elif stmt_type == "YulBlock":
            for s in stmt.statements:
                self._collect_assigned_vars(s, result_set)
        elif stmt_type == "YulIf":
            self._collect_assigned_vars(stmt.body, result_set)
        elif stmt_type == "YulSwitch":
            for c in stmt.cases:
                self._collect_assigned_vars(c.body, result_set)
        elif stmt_type == "YulForLoop":
            if stmt.init:
                self._collect_assigned_vars(stmt.init, result_set)
            if stmt.body:
                self._collect_assigned_vars(stmt.body, result_set)
            if stmt.post:
                self._collect_assigned_vars(stmt.post, result_set)

    def _collect_used_vars(self, node, result_set, scope_vars):
        """Recursively collect variable names that are USED (read) in a Yul AST node.
        
        Only collects variables that exist in scope_vars (to filter out function names
        and literals that aren't actual variables).
        
        Args:
            node: Yul AST node to traverse
            result_set: Set to add used variable names to
            scope_vars: Set of variable names currently in scope (from var_map keys)
        """
        if node is None:
            return
            
        node_type = type(node).__name__
        
        if node_type == "YulLiteral":
            # Check if this is a variable reference (not a numeric literal)
            val = node.value
            if val in scope_vars:
                result_set.add(val)
        elif node_type == "YulCall":
            # Function name is not a variable reference, but args may contain vars
            for arg in node.args:
                self._collect_used_vars(arg, result_set, scope_vars)
        elif node_type == "YulBlock":
            for s in node.statements:
                self._collect_used_vars(s, result_set, scope_vars)
        elif node_type == "YulVariableDeclaration":
            # The RHS expression may use variables
            if node.value:
                self._collect_used_vars(node.value, result_set, scope_vars)
        elif node_type == "YulAssignment":
            # RHS expression may use variables
            if node.value:
                self._collect_used_vars(node.value, result_set, scope_vars)
        elif node_type == "YulIf":
            self._collect_used_vars(node.condition, result_set, scope_vars)
            self._collect_used_vars(node.body, result_set, scope_vars)
        elif node_type == "YulSwitch":
            self._collect_used_vars(node.condition, result_set, scope_vars)
            for c in node.cases:
                self._collect_used_vars(c.body, result_set, scope_vars)
        elif node_type == "YulForLoop":
            if node.init:
                self._collect_used_vars(node.init, result_set, scope_vars)
            self._collect_used_vars(node.condition, result_set, scope_vars)
            if node.body:
                self._collect_used_vars(node.body, result_set, scope_vars)
            if node.post:
                self._collect_used_vars(node.post, result_set, scope_vars)
        elif node_type == "YulExpressionStmt":
            self._collect_used_vars(node.expr, result_set, scope_vars)

    def _count_statements(self, node):
        """Count statements in a Yul AST node for inlining complexity analysis.
        
        Used by inlining heuristics to decide whether a function is too complex
        to inline everywhere, based on an approximate statement count.
        
        Counting rules:
        - YulBlock: sum of all contained statements
        - YulIf/YulSwitch/YulForLoop: 1 + sum of body statements
        - Simple statements (assignment, declaration, expression, leave, break, continue): 1
        """
        if node is None:
            return 0
        node_type = type(node).__name__
        if node_type == 'YulBlock':
            count = 0
            for stmt in node.statements:
                count += self._count_statements(stmt)
            return count
        elif node_type == 'YulIf':
            return 1 + self._count_statements(node.body)
        elif node_type == 'YulSwitch':
            count = 1
            for case in node.cases:
                count += self._count_statements(case.body)
            return count
        elif node_type == 'YulForLoop':
            return 1 + self._count_statements(node.init) + self._count_statements(node.body) + self._count_statements(node.post)
        else:
            # Simple statements: assignment, declaration, expression, leave, break, continue
            return 1

    def _collect_loop_assigned_vars(self, stmt, result_set):
        """Collect vars assigned INSIDE for-loops (body/post). Used to exclude from switch_var_mem."""
        stmt_type = type(stmt).__name__
        if stmt_type == "YulVariableDeclaration":
            # Declarations in loop body/post
            for v in stmt.vars:
                result_set.add(v)
        elif stmt_type == "YulAssignment":
            for v in stmt.vars:
                result_set.add(v)
        elif stmt_type == "YulBlock":
            for s in stmt.statements:
                self._collect_loop_assigned_vars(s, result_set)
        elif stmt_type == "YulIf":
            self._collect_loop_assigned_vars(stmt.body, result_set)
        elif stmt_type == "YulSwitch":
            for c in stmt.cases:
                self._collect_loop_assigned_vars(c.body, result_set)
        elif stmt_type == "YulForLoop":
            # THIS is what we're looking for - collect vars from init/body/post
            if stmt.init:
                self._collect_loop_assigned_vars(stmt.init, result_set)
            if stmt.body:
                self._collect_loop_assigned_vars(stmt.body, result_set)
            if stmt.post:
                self._collect_loop_assigned_vars(stmt.post, result_set)

    # NOTE: _is_simple_revert_body moved to AssertOptimizer in optimizations.py
    def _materialize_literal(self, val, block):
        """Materialize a value into a variable at the end of the given block.
        
        For IRLiterals: Uses 'assign' which is optimized away by AssignElimPass.
        For IRVariables: Uses 'add val, 0' to force proper DUP handling due to
        backend stack model issues with assign on multi-use variables.
        """
        new_var = self.current_fn.get_next_variable()
        
        if isinstance(val, IRVariable):
            # Variables need add x,0 pattern to force DUP in backend
            if block.is_terminated:
                inst = IRInstruction("add", [val, IRLiteral(0)], [new_var])
                block.insert_instruction(inst, len(block.instructions) - 1)
            else:
                block.append_instruction("add", val, IRLiteral(0), outputs=[new_var])
        else:
            # Literals: use assign (gets eliminated by AssignElimPass)
            if block.is_terminated:
                inst = IRInstruction("assign", [val], [new_var])
                block.insert_instruction(inst, len(block.instructions) - 1)
            else:
                block.append_instruction("assign", val, outputs=[new_var])
            
        return new_var

    def _visit_stmt(self, stmt):
        stmt_type = type(stmt).__name__
        
        if stmt_type == "YulBlock":
            # Track which variables exist before the block (for scoping)
            old_map = self.var_map.copy()
            for s in stmt.statements:
                # Early exit if block was terminated by inlined halting instruction
                if self.current_bb.is_terminated:
                    break
                self._visit_stmt(s)
            # Only restore variables that were NEWLY declared in this block (scoping)
            # Keep assignments to variables that existed BEFORE the block
            for key in list(self.var_map.keys()):
                if key not in old_map:
                    # This was a new declaration inside the block - should be scoped out
                    del self.var_map[key]
            # Note: Assignments to existing variables (key in old_map) are preserved

        elif stmt_type == 'YulVariableDeclaration': # let ...
            # VENOM NATIVE: Use registers directly, no memory indirection
            
            # Flush any pending FMP updates from previous allocations
            self._flush_pending_fmp()
            
            if isinstance(stmt.value, YulCall) and stmt.value.function in self.functions_ast:
                 arg_vals = [self._visit_expr(a) for a in stmt.value.args]
                 func_name = stmt.value.function
                 
                 # SPECIAL CASE: allocate_memory with deferred FMP update
                 # This fixes the "32 != 20" bug where struct pointer is lost due to
                 # stack manipulation between mload(64) and its use in mstore(slot, ptr).
                 #
                 # Instead of complex deferred pattern that creates cross-block issues,
                 # we inline normally BUT mark that we're in an allocation context.
                 # The FMP update will be emitted immediately, but we'll duplicate the
                 # result variable to ensure it's preserved for later use.
                 if func_name == 'allocate_memory' and func_name in self.inlinable_functions:
                     # Inline the function normally
                     result_vals = self._inline_function_call(func_name, arg_vals)
                     
                     # The result is the allocation pointer - emit a DUP-style preservation
                     # by assigning it to a new variable that will be used for the mstore
                     if result_vals:
                         ptr = result_vals[0]
                         # Create an explicit copy that the backend will preserve
                         # Using 'add with 0' pattern to force proper stack handling
                         preserved_ptr = self.current_bb.append_instruction("add", IRLiteral(0), ptr)
                         result_vals = [preserved_ptr]
                 # Only inline if function is safe to inline (not recursive)
                 elif func_name in self.inlinable_functions:
                     # NATIVE-INLINING: Inline function body instead of invoke
                     result_vals = self._inline_function_call(func_name, arg_vals)
                 else:
                     # Recursive function - use invoke instead of inlining
                     # Explicitly allocate return variable since invoke is in NO_OUTPUT_INSTRUCTIONS
                     f_def = self.functions_ast.get(func_name)
                     if f_def and f_def.returns:
                         # Create one variable for EACH return value (multi-return support)
                         ret_vars = [self.current_fn.get_next_variable() for _ in f_def.returns]
                         invoke_inst = IRInstruction("invoke", [IRLabel(self.sanitize(func_name))] + arg_vals, outputs=ret_vars)
                         invoke_inst.parent = self.current_bb
                         self.current_bb.instructions.append(invoke_inst)
                         result_vals = ret_vars
                     else:
                         self.current_bb.append_instruction("invoke", IRLabel(self.sanitize(func_name)), *arg_vals)
                         result_vals = []
                 
                 # Map results to declared variables
                 for i, v_name in enumerate(stmt.vars):
                     if i < len(result_vals):
                         self.var_map[v_name] = result_vals[i]
                     else:
                         self.var_map[v_name] = IRLiteral(0)
                 return

            # Simple value: let x := 5 or let x := expr
            if stmt.value:
                val = self._visit_expr(stmt.value)
            else:
                val = IRLiteral(0)
            
            # VENOM NATIVE: Map variable directly to value/register
            for var_name in stmt.vars:
                # Map directly - Venom backend handles literals via PUSH
                self.var_map[var_name] = val

        elif stmt_type == 'YulAssignment': # :=
            # VENOM NATIVE: Update variable mapping directly (SSA-style)
            
            # Call assignment: a, b := func(x, y)
            if isinstance(stmt.value, YulCall) and stmt.value.function in self.functions_ast:
                 arg_vals = [self._visit_expr(a) for a in stmt.value.args]
                 func_name = stmt.value.function
                 
                 # Only inline if function is safe to inline (not recursive)
                 if func_name in self.inlinable_functions:
                     result_vals = self._inline_function_call(func_name, arg_vals)
                 else:
                     # Recursive function - use invoke
                     # Explicitly allocate return variable since invoke is in NO_OUTPUT_INSTRUCTIONS
                     f_def = self.functions_ast.get(func_name)
                     if f_def and f_def.returns:
                         # Create one variable for EACH return value (multi-return support)
                         ret_vars = [self.current_fn.get_next_variable() for _ in f_def.returns]
                         invoke_inst = IRInstruction("invoke", [IRLabel(self.sanitize(func_name))] + arg_vals, outputs=ret_vars)
                         invoke_inst.parent = self.current_bb
                         self.current_bb.instructions.append(invoke_inst)
                         result_vals = ret_vars
                     else:
                         self.current_bb.append_instruction("invoke", IRLabel(self.sanitize(func_name)), *arg_vals)
                         result_vals = []
                 # Map results to assigned variables (pure register model)
                 for i, v in enumerate(stmt.vars):
                     result_val = result_vals[i] if i < len(result_vals) else IRLiteral(0)
                     self.var_map[v] = result_val
                 return

            # Simple assignment: x := y + 5 (pure register model)
            val = self._visit_expr(stmt.value)
            
            for var_name in stmt.vars:
                self.var_map[var_name] = val


        elif stmt_type == 'YulExpressionStmt':
            # VENOM-NATIVE: Detect and strip FMP init pattern
            # Pattern: mstore(64, memoryguard(...))
            # Venom manages memory statically via MemoryAllocator - FMP not needed
            expr = stmt.expr
            if isinstance(expr, YulCall) and expr.function == "mstore":
                if len(expr.args) == 2:
                    ptr_arg = expr.args[0]
                    val_arg = expr.args[1]
                    # Check if ptr is 64/0x40 (FMP slot) and val is memoryguard result
                    # Note: String matching here because we're parsing Yul source literals,
                    # not generating code. The constant YUL_FMP_SLOT is used when generating IR.
                    is_fmp_slot = (isinstance(ptr_arg, YulLiteral) and 
                                   (ptr_arg.value == "64" or ptr_arg.value == "0x40"))
                    is_memguard = isinstance(val_arg, YulCall) and val_arg.function == "memoryguard"
                    if is_fmp_slot and is_memguard:
                        # BRIDGE YUL FMP TO VENOM: Initialize FMP to venom_start
                        # Yul code uses mload(64)/mstore(64) for dynamic memory allocation.
                        # Venom's MemoryAllocator uses 0x00-venom_start for static allocation.
                        # We initialize FMP to venom_start so Yul's dynamic allocation starts
                        # above Venom's region, avoiding memory conflicts.
                        fmp_slot = self.config.memory.fmp_slot if self.config else YUL_FMP_SLOT
                        venom_start = self.config.memory.venom_start if self.config else VENOM_MEMORY_START
                        self.current_bb.append_instruction("mstore", IRLiteral(fmp_slot), IRLiteral(venom_start))
                        return
            self._visit_expr(stmt.expr)

        elif stmt_type == "YulIf":
            # OPTIMIZATION: Delegate to optimization pipeline
            # Pipeline handles patterns like: if cond { revert(0,0) } → assert
            opt_ctx = OptimizationContext(
                current_bb=self.current_bb,
                current_fn=self.current_fn,
                var_map=self.var_map,
                functions_ast=self.functions_ast,
                visit_expr=self._visit_expr,
                append_instruction=lambda op, *args: self.current_bb.append_instruction(op, *args)
            )
            if self.optimizer.try_optimize_stmt(stmt, opt_ctx):
                return
            
            # SSA Construction for If:
            # 1. Identify modified vars.
            # 2. Branch to Then/End.
            # 3. Visit Then (reset scope).
            # 4. Merge at End with Phis.
            
            # Identify modified vars
            if_assigned_vars = set()
            self._collect_assigned_vars(stmt.body, if_assigned_vars)
            vars_needing_phi = {v for v in if_assigned_vars if v in self.var_map}
            
            # Evaluate condition
            cond_var = self._visit_expr(stmt.condition)
            
            # Capture Entry State (Predecessor 1)
            entry_var_map = self.var_map.copy()
            entry_bb = self.current_bb
            
            # Create blocks
            then_lbl = self.ctx.get_next_label("then")
            end_lbl = self.ctx.get_next_label("end_if")
            
            then_bb = IRBasicBlock(then_lbl, self.current_fn)
            end_bb = IRBasicBlock(end_lbl, self.current_fn)
            
            # Emit Branch
            # Entry -> Then (true), Entry -> End (false)
            self.current_bb.append_instruction("jnz", cond_var, then_bb.label, end_bb.label)
            
            # Visit Then Path
            # Reset scope to entry
            self.var_map = entry_var_map.copy()
            
            self.current_fn.append_basic_block(then_bb)
            self.current_bb = then_bb
            
            self._visit_stmt(stmt.body) # Standard visit, no memory map needed
            
            # Collect Then Path State (Predecessor 2)
            then_reached_end = False
            then_end_label = None
            then_end_bb = None # Capture block object
            then_end_map = None
            
            if not self.current_bb.is_terminated:
                self.current_bb.append_instruction("jmp", end_bb.label)
                then_reached_end = True
                then_end_label = self.current_bb.label
                then_end_bb = self.current_bb
                then_end_map = self.var_map.copy()
            
            # Join Block
            self.current_fn.append_basic_block(end_bb)
            self.current_bb = end_bb
            
            # Reset scope to Entry (base) and update with Phis
            self.var_map = entry_var_map.copy()
            
            if then_reached_end:
                # Merge Entry (False) + Then (True)
                for v in vars_needing_phi:
                    val_entry = entry_var_map[v]
                    val_then = then_end_map[v]
                    
                    # Optimization: If values identical, no Phi needed
                    if val_entry == val_then:
                         continue
                         
                    # Materialize literals
                    # Predecessor 1: entry_bb (False path)
                    val_entry_reg = self._materialize_literal(val_entry, entry_bb)
                    
                    # Predecessor 2: then_end_bb (True path)
                    val_then_reg = self._materialize_literal(val_then, then_end_bb)

                    phi_res = self.current_bb.append_instruction("phi", 
                                                               entry_bb.label, val_entry_reg, 
                                                               then_end_label, val_then_reg)
                    self.var_map[v] = phi_res
            else:
                # Then path diverged/reverted. End is only reachable from Entry (False).
                # State remains as Entry state. No Phis needed.
                pass

        elif stmt_type == "YulSwitch":
            # SSA Construction for Switch:
            # 1. Identify variables modified in any branch.
            # 2. Reset scope (var_map) before visiting each branch.
            # 3. Collect final values from each branch.
            # 4. Emit Phi nodes at join block.
            
            # Analyze modified vars
            switch_assigned_vars = set()
            for case in stmt.cases:
                self._collect_assigned_vars(case.body, switch_assigned_vars)
            
            # Filter to only vars that exist in current scope (outer vars)
            vars_needing_phi = {v for v in switch_assigned_vars if v in self.var_map}
            
            # Save entry scope
            entry_var_map = self.var_map.copy()
            entry_bb = self.current_bb
            
            end_lbl = self.ctx.get_next_label("switch_end")
            end_bb = IRBasicBlock(end_lbl, self.current_fn)
            
            # Prepare dispatch logic
            default_case = None
            case_blocks = [] # (val, label, case_obj)
            
            # 1. Setup Case Blocks and Dispatch
            for case in stmt.cases:
                if case.value is None or case.value == 'default':
                    default_case = case
                else:
                    lbl = self.ctx.get_next_label("case")
                    val_str = case.value
                    if isinstance(val_str, str) and val_str.startswith("0x"): val = IRLiteral(int(val_str, 16))
                    elif isinstance(val_str, str) and val_str.isdigit(): val = IRLiteral(int(val_str))
                    elif isinstance(val_str, int): val = IRLiteral(val_str)
                    else: val = IRLiteral(0)
                    
                    case_blocks.append((val, lbl, case))

            # 2. Evaluate condition (selector value)
            cond_val = self._visit_expr(stmt.condition)

            # DJMP O(1) DISPATCH with 2-layer collision handling
            # Layer 1: djmp to bucket handler based on selector mod n_buckets
            # Layer 2: within bucket, linear search for exact selector match
            use_djmp = len(case_blocks) >= 4
            
            if use_djmp:
                # 2-LAYER DISPATCH: bucket jump + per-bucket collision resolution
                # This handles selector collisions while maintaining O(1) average case
                
                n_buckets = len(case_blocks) + 1  # +1 for default
                bucket_size_lit = IRLiteral(n_buckets)
                bucket_idx = self.current_bb.append_instruction1("mod", cond_val, bucket_size_lit)
                
                # Group selectors by bucket (handle collisions)
                buckets: dict[int, list[tuple]] = {}  # bucket_id -> [(val, lbl, case), ...]
                for val, lbl, case in case_blocks:
                    selector_val = val.value if hasattr(val, 'value') else val
                    bucket = selector_val % n_buckets
                    buckets.setdefault(bucket, []).append((val, lbl, case))
                
                # Create fallback label for default case
                fallback_lbl = self.ctx.get_next_label("fallback")
                fallback_bb = IRBasicBlock(fallback_lbl, self.current_fn)
                
                # Create bucket handler blocks
                bucket_handlers = {}  # bucket_id -> (bucket_lbl, bucket_bb)
                for bucket_id in range(n_buckets):
                    if bucket_id in buckets:
                        bucket_lbl = self.ctx.get_next_label(f"bucket_{bucket_id}")
                        bucket_bb = IRBasicBlock(bucket_lbl, self.current_fn)
                        bucket_handlers[bucket_id] = (bucket_lbl, bucket_bb)
                    else:
                        # Empty bucket -> fallback
                        bucket_handlers[bucket_id] = (fallback_lbl, None)
                
                # Build djmp label list
                djmp_labels = []
                for bucket_id in range(n_buckets):
                    djmp_labels.append(bucket_handlers[bucket_id][0])
                
                # Create data section for jump table
                table_label = self.ctx.get_next_label("selector_buckets")
                self.ctx.append_data_section(table_label)
                for lbl in djmp_labels:
                    self.ctx.append_data_item(lbl)
                
                # Calculate bucket index from selector
                shift_amt = IRLiteral(1)
                offset = self.current_bb.append_instruction1("shl", shift_amt, bucket_idx)
                
                # Add table base + offset
                code_offset = self.current_bb.append_instruction1("add", table_label, offset)
                
                # Copy from code section to memory (native Venom order: dest, src, size)
                memory_slot = IRLiteral(30)
                copy_size = IRLiteral(2)
                self.current_bb.append_instruction("codecopy", memory_slot, code_offset, copy_size)
                
                # Load destination address
                # mload reads 32 bytes from the address, so for a 2-byte value at offset 30,
                # we load from offset 0 (the 2 bytes at 30-31 will be in the lowest bits)
                load_offset = IRLiteral(0)
                dest_addr = self.current_bb.append_instruction1("mload", load_offset)
                
                # Emit djmp to bucket handlers
                self.current_bb.append_instruction("djmp", dest_addr, *djmp_labels)
                
                # Generate bucket handler bodies with collision resolution
                # NATIVE VYPER PATTERN: Each bucket starts with %local = %selector (assign)
                # This creates a local copy that SSA/liveness analysis tracks properly
                for bucket_id, selectors in buckets.items():
                    bucket_lbl, bucket_bb = bucket_handlers[bucket_id]
                    if bucket_bb is None:
                        continue
                    
                    self.current_fn.append_basic_block(bucket_bb)
                    self.current_bb = bucket_bb
                    
                    # CRITICAL FIX: Recompute selector locally instead of referencing 
                    # cond_val from parent block. This avoids SSA cross-block dependency
                    # issues where the variable isn't live through the DJMP.
                    # Pattern: shr(224, calldataload(0)) to extract 4-byte selector
                    cd_zero = IRLiteral(0)
                    cd_load = self.current_bb.append_instruction1("calldataload", cd_zero)
                    shift_amt = IRLiteral(224)
                    local_sel = self.current_bb.append_instruction1("shr", shift_amt, cd_load)
                    
                    if len(selectors) == 1:
                        # Single selector in bucket - check and jump to fallback on mismatch
                        # Pattern: xor %local, expected; jnz xor, fallback, handler
                        # This allows receive() (calldatasize=0) to properly reach fallback
                        val, lbl, case = selectors[0]
                        xor_result = self.current_bb.append_instruction1("xor", val, local_sel)
                        # jnz: if xor!=0 (mismatch) -> fallback, if xor==0 (match) -> handler
                        self.current_bb.append_instruction("jnz", xor_result, fallback_lbl, lbl)
                    else:
                        # Multiple selectors in bucket - linear search using local_sel computed above
                        
                        for i, (val, lbl, case) in enumerate(selectors):
                            # Native pattern: xor for comparison
                            xor_result = self.current_bb.append_instruction1("xor", val, local_sel)
                            # Native optimization: Skip iszero, use jnz on xor result directly
                            # Logic: jnz(xor, FAIL, MATCH)
                            # If xor!=0 (Mismatch) -> Jump to FAIL
                            # If xor==0 (Match)    -> Jump to MATCH
                            
                            if i < len(selectors) - 1:
                                # More selectors to check
                                next_check_lbl = self.ctx.get_next_label(f"bucket_{bucket_id}_check")
                                next_check_bb = IRBasicBlock(next_check_lbl, self.current_fn)
                                self.current_fn.append_basic_block(next_check_bb)
                                self.current_bb.append_instruction("jnz", xor_result, next_check_lbl, lbl)
                                self.current_bb = next_check_bb
                            else:
                                # Last selector - if not match, go to fallback
                                self.current_bb.append_instruction("jnz", xor_result, fallback_lbl, lbl)
                
                # Fallback block for default case
                self.current_fn.append_basic_block(fallback_bb)
                self.current_bb = fallback_bb
                
                # DON'T revert - let post-switch statements handle fallback behavior
                # (e.g., Solidity's fallback() or receive() functions)
                
                next_check_bb = fallback_bb
            else:
                # SIMPLE JNZ CHAIN for < 4 selectors
                # Linear dispatch: check each selector with jnz, fall through on mismatch
                fallback_lbl = self.ctx.get_next_label("fallback")
                fallback_bb = IRBasicBlock(fallback_lbl, self.current_fn)
                
                for i, (val, lbl, case) in enumerate(case_blocks):
                    # XOR comparison
                    xor_result = self.current_bb.append_instruction1("xor", val, cond_val)
                    
                    if i < len(case_blocks) - 1:
                        # More selectors to check - create next check block
                        next_check_lbl = self.ctx.get_next_label("case_check")
                        next_bb = IRBasicBlock(next_check_lbl, self.current_fn)
                        self.current_fn.append_basic_block(next_bb)
                        # jnz xor, next_check (mismatch), handler (match)
                        self.current_bb.append_instruction("jnz", xor_result, next_check_lbl, lbl)
                        self.current_bb = next_bb
                    else:
                        # Last selector - if not match, go to fallback
                        self.current_bb.append_instruction("jnz", xor_result, fallback_lbl, lbl)
                
                # Fallback block - DON'T automatically revert!
                # Post-switch statements (like Solidity's fallback/receive code) will handle
                # unmatched selectors. The fallback block should flow to switch_end.
                self.current_fn.append_basic_block(fallback_bb)
                # Let fallback flow to the end where post-switch statements are processed
                # or implicit function termination will add stop/return as needed.
                
                # Keep next_check_bb as the fallback for default processing later
                next_check_bb = fallback_bb
            
            # 3. Visit Bodies and Collect Phi Inputs
            phi_inputs = {v: [] for v in vars_needing_phi}
            
            # Helper to process body exit
            def process_exit(bb):
                if not bb.is_terminated:
                    bb.append_instruction("jmp", end_lbl)
                    # Collect phi values for this path
                    for v in vars_needing_phi:
                        # Only add if the variable exists in the current var_map (was defined/assigned)
                        if v in self.var_map:
                            # Capture block object for later materialization
                            phi_inputs[v].append({'val': self.var_map[v], 'label': bb.label, 'block': bb})
            
            # Visit Case Bodies
            for val, lbl, case in case_blocks:
                # Reset scope
                self.var_map = entry_var_map.copy()
                
                body_bb = IRBasicBlock(lbl, self.current_fn)
                self.current_fn.append_basic_block(body_bb)
                self.current_bb = body_bb
                
                # Visit statements
                for s in case.body.statements:
                    self._visit_stmt(s)
                
                process_exit(self.current_bb)
                
            # Visit Default
            self.var_map = entry_var_map.copy()
            # Default continues from the last check block (next_check_bb)
            # BUT: if next_check_bb is already terminated (e.g., with revert for fallback),
            # we should NOT try to append more code to it
            if not next_check_bb.is_terminated:
                self.current_bb = next_check_bb 
                
                if default_case:
                    for s in default_case.body.statements:
                        self._visit_stmt(s)
                
                process_exit(self.current_bb)
            
            # 4. Join Block and Phi Nodes
            # Set scope to entry scope (base) - we will update with Phis
            self.var_map = entry_var_map.copy() 
            self.current_fn.append_basic_block(end_bb)
            self.current_bb = end_bb
            
            for v in vars_needing_phi:
                inputs = phi_inputs[v]
                if not inputs: continue
                
                # Single-input phi is redundant - just use the value directly
                if len(inputs) == 1:
                    val = inputs[0]['val']
                    self.var_map[v] = val
                    continue
                
                # Flatten args for Phi instruction: label, val, label, val...
                phi_args = []
                for item in inputs:
                    lbl = item['label']
                    val = item['val']
                    pred_bb = item['block']
                    
                    # Materialize literal
                    val_reg = self._materialize_literal(val, pred_bb)
                    
                    phi_args.append(lbl)
                    phi_args.append(val_reg)
                
                # Emit Phi
                phi_res = self.current_bb.append_instruction("phi", *phi_args)
                self.var_map[v] = phi_res

        elif stmt_type == 'YulForLoop':
            # 1. Init
            if stmt.init and stmt.init.statements:
                for s in stmt.init.statements:
                    self._visit_stmt(s)
            
            # Save Pre-Loop Block and Scope
            ptr_loop_entry = self.current_bb
            entry_var_map = self.var_map.copy()

            # 2. Identify Loop-Carried Variables AND Loop-Invariant Variables
            # We need phis for:
            # a) Variables assigned inside the loop (their value changes each iteration)
            # b) Variables used inside the loop but defined BEFORE (loop-invariants from outer scope)
            #    These need phis so the SSA validator sees them as defined on ALL paths to loop header
            #    (including the back-edge from loop_post)
            
            loop_assigned_vars = set()
            self._collect_assigned_vars(stmt.body, loop_assigned_vars)
            self._collect_assigned_vars(stmt.post, loop_assigned_vars)
            
            # Collect variables USED inside the loop (body, condition, post)
            loop_used_vars = set()
            scope_vars = set(self.var_map.keys())  # Current scope variables
            self._collect_used_vars(stmt.condition, loop_used_vars, scope_vars)
            self._collect_used_vars(stmt.body, loop_used_vars, scope_vars)
            self._collect_used_vars(stmt.post, loop_used_vars, scope_vars)
            
            # Variables needing phi = assigned vars + used vars from outer scope (not assigned inside)
            # Filter to only include vars that exist in var_map
            loop_invariant_used = loop_used_vars - loop_assigned_vars  # Used but not assigned = loop-invariant
            all_vars_needing_phi = (loop_assigned_vars | loop_invariant_used) & set(self.var_map.keys())
            sorted_vars = sorted(list(all_vars_needing_phi))  # Deterministic order
            
            # Prepare Blocks
            loop_start_bb = IRBasicBlock(self.ctx.get_next_label("blk_loop_start"), self.current_fn)
            loop_body_bb = IRBasicBlock(self.ctx.get_next_label("blk_loop_body"), self.current_fn)
            loop_post_bb = IRBasicBlock(self.ctx.get_next_label("blk_loop_post"), self.current_fn)
            loop_end_bb = IRBasicBlock(self.ctx.get_next_label("blk_loop_end"), self.current_fn)
            
            # Jump to Start
            self.current_bb.append_instruction("jmp", loop_start_bb.label)
            
            # --- LOOP START (Phi Header) ---
            self.current_fn.append_basic_block(loop_start_bb)
            self.current_bb = loop_start_bb
            
            # Create Phis (Forward definition)
            # We only know the Entry value now. Post value comes later.
            phi_instructions = {}
            phi_results = {} # Store Phi result variables to restore scope later
            
            for var_name in sorted_vars:
                init_val = entry_var_map[var_name]
                
                # Materialize init_val in ptr_loop_entry (pre-header)
                init_val_reg = self._materialize_literal(init_val, ptr_loop_entry)
                
                # Create Phi with just entry value for now
                # We will append the back-edge value later
                phi_res = self.current_bb.append_instruction("phi", ptr_loop_entry.label, init_val_reg)
                phi_inst = self.current_bb.instructions[-1]
                
                # Update map to use Phi result inside loop
                self.var_map[var_name] = phi_res
                
                # Track instruction and result
                phi_instructions[var_name] = phi_inst
                phi_results[var_name] = phi_res
                
            # Condition
            cond_val = self._visit_expr(stmt.condition)
            
            # Fix: If condition is false, jump to END. If true, fallthrough to BODY.
            # Yul loop: for { ... } condition { ... } { body }
            # If !condition -> break
            is_false = self.current_bb.append_instruction1("iszero", cond_val)
            
            # Use explicit 2-label JNZ to ensure CFG connectivity
            # jnz(is_false, target_if_true=END, target_if_false=BODY)
            self.current_bb.append_instruction("jnz", is_false, loop_end_bb.label, loop_body_bb.label)
            
            # --- LOOP BODY ---
            self.current_fn.append_basic_block(loop_body_bb)
            self.current_bb = loop_body_bb
            
            # Track continue statements to collect values for post-block phis
            continue_sources = []  # List of (label, var_map_copy) for each continue
            self.loop_stack.append((loop_start_bb.label, loop_end_bb.label, loop_post_bb.label, continue_sources, phi_results))
            
            self._visit_stmt(stmt.body) # Visit normally (updates var_map references)
            
            # Capture body-end state for phis
            body_end_var_map = self.var_map.copy()
            body_reached_post = not self.current_bb.is_terminated
            body_end_label = self.current_bb.label if body_reached_post else None
            body_end_bb = self.current_bb if body_reached_post else None
            
            if body_reached_post:
                self.current_bb.append_instruction("jmp", loop_post_bb.label)
                
            # --- LOOP POST ---
            self.current_fn.append_basic_block(loop_post_bb)
            self.current_bb = loop_post_bb
            
            # Create post-block phis if there are multiple incoming edges (body + continue(s))
            # This merges values from normal body completion and continue statements
            if continue_sources or body_reached_post:
                # Collect all sources for the post block
                post_sources = []
                if body_reached_post:
                    post_sources.append((body_end_label, body_end_var_map, body_end_bb))
                for cont_label, cont_map, cont_bb in continue_sources:
                    post_sources.append((cont_label, cont_map, cont_bb))
                
                if len(post_sources) > 1:
                    # Need phis to merge values
                    for var_name in sorted_vars:
                        # Get value from each source, using phi_result as fallback for continue paths
                        first_label, first_map, first_bb = post_sources[0]
                        first_val = first_map.get(var_name, phi_results[var_name])
                        first_val_reg = self._materialize_literal(first_val, first_bb)
                        
                        # Start building phi
                        phi_operands = [first_label, first_val_reg]
                        
                        for src_label, src_map, src_bb in post_sources[1:]:
                            src_val = src_map.get(var_name, phi_results[var_name])
                            src_val_reg = self._materialize_literal(src_val, src_bb)
                            phi_operands.extend([src_label, src_val_reg])
                        
                        phi_res = self.current_bb.append_instruction("phi", *phi_operands)
                        self.var_map[var_name] = phi_res
                elif len(post_sources) == 1:
                    # Single source, just use its values
                    _, src_map, _ = post_sources[0]
                    for var_name in sorted_vars:
                        self.var_map[var_name] = src_map.get(var_name, phi_results[var_name])
            
            self._visit_stmt(stmt.post)
            
            # Back-edge (Post -> Start)
            post_block_label = self.current_bb.label
            if not self.current_bb.is_terminated:
                self.current_bb.append_instruction("jmp", loop_start_bb.label)
            
            self.loop_stack.pop()
            
            # --- BACK-PATCH PHIS ---
            # Append (post_block_label, current_val) to Phis
            for var_name in sorted_vars:
                phi_inst = phi_instructions[var_name]
                post_val = self.var_map[var_name] # Value at end of Post block
                
                # Materialize in post block
                post_val_reg = self._materialize_literal(post_val, self.current_bb)

                # Venom IRInstruction operands: list of IROperand
                # Append Label, Val
                phi_inst.operands.append(post_block_label)
                phi_inst.operands.append(post_val_reg)
                
            # --- LOOP END ---
            self.current_fn.append_basic_block(loop_end_bb)
            self.current_bb = loop_end_bb
            
            # Scope Exit:
            # Variables modified in loop retain their values from the "Exit" condition.
            # Which values?
            # 1. Start Block -> End (False condition).
            # The values in Start block are the Phi results!
            # Since Start dominates End, we MUST use the Phi results as the variable values
            # for any code following the loop. The 'current' var_map reflects the state at 
            # the end of 'post' or 'body', which is incorrect for the 'end' block.
            
            for var_name in sorted_vars:
                self.var_map[var_name] = phi_results[var_name]
            
        elif stmt_type == 'YulBreak':

            if self.loop_stack:
                _, end_label, _, _, _ = self.loop_stack[-1]
                self.current_bb.append_instruction("jmp", end_label)
            else:
                print("WARNING: break outside loop", file=sys.stderr)
            
        elif stmt_type == 'YulContinue':
            if self.loop_stack:
                _, _, post_label, continue_sources, phi_results = self.loop_stack[-1]
                # Record current var_map state for this continue path
                continue_sources.append((self.current_bb.label, self.var_map.copy(), self.current_bb))
                self.current_bb.append_instruction("jmp", post_label)
            else:
                print("WARNING: continue outside loop", file=sys.stderr)
            
        elif stmt_type == 'YulLeave':
            # Check if we're in an inlined function with an exit label
            if self.inline_exit_stack:
                # NATIVE VYPER PATTERN: Jump to cleanup block, merging return values via PHI
                cleanup_lbl, return_names, phi_data = self.inline_exit_stack[-1]
                
                # Collect return values for PHI
                for ret_name in return_names:
                    # Variable should exist (init to 0 at start of inline)
                    if ret_name in self.var_map:
                        phi_data[ret_name].append({
                            'val': self.var_map[ret_name],
                            'label': self.current_bb.label,
                            'block': self.current_bb
                        })
                
                self.current_bb.append_instruction("jmp", cleanup_lbl)
            elif '$pc' not in self.var_map:
                # No exit label and no $pc - should not happen in well-formed code
                # This is main entry without invoke, just stop
                self.current_bb.append_instruction("stop")
            elif self.current_return_names:
                ret_vals = []
                for n in self.current_return_names:
                    if n in self.var_map:
                        val = self.var_map[n]
                        # FIX: ALWAYS use add pattern for ALL values (both literals and variables).
                        # The optimizer eliminates assign but respects add for stack ordering.
                        # This forces consistent ordering between base case and recursive case.
                        temp_var = self.current_fn.get_next_variable()
                        temp_var.annotation = f"ret_{n}"
                        self.current_bb.append_instruction("add", val, IRLiteral(0), ret=temp_var)
                        ret_vals.append(temp_var)
                    else:
                        temp_var = self.current_fn.get_next_variable()
                        temp_var.annotation = f"ret_{n}_default"
                        self.current_bb.append_instruction("add", IRLiteral(0), IRLiteral(0), ret=temp_var)
                        ret_vals.append(temp_var)
                # Return values first, PC last (native Vyper convention, no parser reversal)
                self.current_bb.append_instruction("ret", *ret_vals, self.var_map['$pc'])
            else:
                self.current_bb.append_instruction("ret", self.var_map['$pc'])



    def _visit_expr(self, expr, _depth=0):
        # expr is YulLiteral, YulCall, or YulExpression wrapper
        if _depth > 100:
            raise RecursionError(f"Max expression depth exceeded. Possible circular reference: {type(expr)}")
        
        node = expr
        
        # Unwrap YulExpression if present (max 3 levels to prevent loops)
        unwrap_count = 0
        while hasattr(node, "node") and unwrap_count < 3:
            node = node.node
            unwrap_count += 1
             
        if isinstance(node, YulLiteral):
            val = node.value
            if val.startswith('"') and val.endswith('"'):
                # Handle string literal
                inner = val.strip('"')
                if inner.isdigit(): return IRLiteral(int(inner))
                try: 
                    if inner.startswith("0x"): return IRLiteral(int(inner, 16))
                except ValueError: pass
                # String literal used as key (e.g., for loadimmutable, log topics)
                # Return the YulLiteral node - handlers that need the string will extract it
                # append_instruction will convert to hex bytes if this reaches IR emission
                return node
            
            if val.startswith("0x"): return IRLiteral(int(val, 16))
            if val.isdigit(): return IRLiteral(int(val))
            
            # Identifier - DIRECT lookup from var_map (pure register model)
            if val in self.var_map:
                return self.var_map[val]
            
            # Undefined variable - return 0
            return IRLiteral(0)
            
        if isinstance(node, YulCall):
            func = node.function
            args = node.args # List[YulExpression]
            
            # PEEPHOLE OPTIMIZATION: iszero(eq(a, b)) → xor(a, b)
            # Native Vyper uses xor for inequality (3 gas vs 6 gas for eq+iszero)
            if func == "iszero" and len(args) == 1:
                inner = args[0]
                if isinstance(inner, YulCall) and inner.function == "eq" and len(inner.args) == 2:
                    # Transform: iszero(eq(a, b)) → xor(a, b)
                    inner_arg_vals = [self._visit_expr(a, _depth+1) for a in inner.args]
                    return self.current_bb.append_instruction1("xor", *inner_arg_vals)
            
            # PEEPHOLE OPTIMIZATION: iszero(iszero(x)) → x (when used as boolean)
            # This is a double negation that can be eliminated
            if func == "iszero" and len(args) == 1:
                inner = args[0]
                if isinstance(inner, YulCall) and inner.function == "iszero" and len(inner.args) == 1:
                    # Transform: iszero(iszero(x)) → x (normalize to truthy)
                    innermost_val = self._visit_expr(inner.args[0], _depth+1)
                    # Can't just return x - need to normalize to 0/1 for boolean contexts
                    # Use iszero(iszero(x)) when backend needs 0/1, but for jnz non-zero works
                    # For now, keep double iszero - let BranchOptimizationPass handle it
                    pass
            
            arg_vals = [self._visit_expr(a, _depth+1) for a in args]
            
            if func in self.inlinable_functions:
                # NATIVE-INLINING: Inline function body instead of invoke
                f_def = self.functions_ast[func]
                result_vals = self._inline_function_call(func, arg_vals)
                
                if not f_def.returns:
                    # Void call - return dummy
                    return IRLiteral(0)
                
                # Return first result (most common case)
                if len(result_vals) >= 1:
                    return result_vals[0]
                return IRLiteral(0)
            elif func in self.functions_ast:
                # Recursive function - use invoke
                f_def = self.functions_ast[func]
                if f_def.returns:
                    ret = self.current_fn.get_next_variable()
                    self.current_bb.append_instruction("invoke", IRLabel(self.sanitize(func)), *arg_vals, ret=ret)
                    return ret
                else:
                    self.current_bb.append_instruction("invoke", IRLabel(self.sanitize(func)), *arg_vals)
                    return IRLiteral(0)
            
            return self._handle_intrinsic(func, arg_vals)

    def _handle_call_abi(self, func, arg_vals, assign_targets, is_assignment=False):
        """
        VENOM-NATIVE: Handle function call using invoke instruction.
        Args passed directly as operands (REVERSED per Venom convention).
        assign_targets: List of variable names (if is_assignment=False) OR List of IRVariables (if is_assignment=True)
        """
        s_func = self.sanitize(func)
        
        # Convert iterator to list so we can use it multiple times
        assign_targets = list(assign_targets)
        
        # Arguments for Venom invoke (FORWARD: Assembler pushes in order, Stack grows Bottom->Top)
        reversed_args = list(arg_vals)
        
        # Handle return values (Strictly enforce function signature)
        f_def = self.functions_ast.get(func)
        num_returns = len(f_def.returns) if f_def else 0
        
        ret_vars = []
        
        if len(assign_targets) > 0:
            if is_assignment:
                # Targets are already IRVariables
                ret_vars = assign_targets
            else:
                # Create NEW variables for declaration
                for var_name in assign_targets:
                    ret_var = self.current_fn.get_next_variable()
                    ret_var.annotation = f"var_{self.sanitize(var_name)}"
                    ret_vars.append(ret_var)
                    # Map to variable
                    self.var_map[var_name] = ret_var
        
        # Stack Leak Fix: If function returns values but we didn't assign them (expression stmt),
        # we MUST create dummy variables so the backend knows to POP the stack.
        if len(ret_vars) < num_returns:
            for _ in range(num_returns - len(ret_vars)):
                dummy = self.current_fn.get_next_variable()
                dummy.annotation = "unused_ret"
                ret_vars.append(dummy)

        if len(ret_vars) > 0:
            # Invoke with returns
            # Construct instruction manually
            operands = [IRLabel(s_func)] + reversed_args
            invoke_inst = IRInstruction("invoke", operands, outputs=ret_vars)
            invoke_inst.parent = self.current_bb
            invoke_inst.annotation = f"call {s_func}"
            
            # Append to block
            self.current_bb.instructions.append(invoke_inst)
        else:
            # No return values - void call
            self.current_bb.append_instruction("invoke", IRLabel(s_func), *reversed_args)

    def _handle_call_abi_expr(self, func, arg_vals):
        """
        VENOM-NATIVE: Handle function call in expression context via invoke.
        Returns the result variable.
        """
        s_func = self.sanitize(func)
        # VENOM FIX: Do NOT reverse args. invoke operands are [Arg1, Arg2].
        # Backend builds stack [Arg1, Arg2] (Arg2 Top).
        # Function expects [Arg1, Arg2] (Arg2 Top).
        reversed_args = list(arg_vals)
        
        # Create result variable
        ret_var = self.current_fn.get_next_variable()
        ret_var.annotation = f"ret_{s_func}"
        
        # Invoke (assume 1 return for expression context)
        self.current_bb.append_instruction("invoke", IRLabel(s_func), *reversed_args, ret=ret_var)
        
        return ret_var


    def _handle_intrinsic(self, func, args):
        # Special Yul-specific intrinsics
        if func == "dataoffset":
            # dataoffset("name")
            # Returns the byte offset where the named object starts in the deployed bytecode.
            # For init code: runtime is at a LITERAL offset (init_size), not at end.
            # For runtime: data is appended at end, use codesize - datasize.
            if args and isinstance(args[0], YulLiteral):
                 obj_name = args[0].value.strip('"')
                 
                 # INIT CODE FIX: Use literal offset if available in offset_map
                 # This is used when runtime code is in the MIDDLE of bytecode
                 # (layout: [init][runtime][args]), not at the END.
                 if obj_name in self.offset_map:
                     offset = self.offset_map[obj_name]
                     return IRLiteral(offset)
                 
                 # RUNTIME CODE FALLBACK: Dynamic calculation for data at END
                 if obj_name in self.data_map:
                     # data_map stores raw bytes from transpile_object
                     size = len(self.data_map[obj_name])
                     
                     # offset = codesize - size
                     # This works when data is appended at the very end.
                     code_size_var = self.current_bb.append_instruction1("codesize")
                     size_literal = IRLiteral(size)
                     return self.current_bb.append_instruction1("sub", code_size_var, size_literal)
                 else:
                     print(f"WARNING: dataoffset({obj_name}) failed. Keys: data_map={list(self.data_map.keys())}, offset_map={list(self.offset_map.keys())}", file=sys.stderr)
            
            return IRLiteral(0)
        
        if func == "datasize":
            # datasize("name")
            if args and isinstance(args[0], YulLiteral):
                 obj_name = args[0].value.strip('"')
                 
                 if obj_name in self.data_map:
                     size = len(self.data_map[obj_name])
                     return IRLiteral(size)
                 else:
                     print(f"WARNING: datasize({obj_name}) failed. Keys: {list(self.data_map.keys())}", file=sys.stderr)
            
            return IRLiteral(0)
        
        if func == "setimmutable":
            # Ignore setimmutable in init code because we use Python-side patching or hardcoded checks
            return IRLiteral(0)

        if func == "loadimmutable":
            # Native Immutable Support
            # args[0] passed from _visit_expr is the YulLiteral node (if string) or IRLiteral
            # See _visit_expr logic for string literals: it returns the node itself.
            
            key = None
            if args:
                if hasattr(args[0], 'value'): 
                   val = args[0].value
                   if isinstance(val, str):
                       key = val.strip('"')
                   else:
                       # It's IRLiteral(int) or similar. Convert to string?
                       # This shouldn't happen for valid loadimmutable("string")
                       key = str(val)
                elif isinstance(args[0], str): # Raw string
                   key = args[0]
            
            # Try both string and int keys (yul2venom.py converts IDs to int)
            lookup_key = None
            if key:
                if key in self.ctx.immutables:
                    lookup_key = key
                elif key.isdigit() and int(key) in self.ctx.immutables:
                    lookup_key = int(key)
            
            if lookup_key is not None:
                val = self.ctx.immutables[lookup_key]
                # Convert hex string if needed
                if isinstance(val, str) and val.startswith("0x"):
                    val = int(val, 16)
                elif isinstance(val, str) and val.isdigit():
                    val = int(val)
                return IRLiteral(val)
            
            # If not found or invalid arg, fallback
            print(f"WARNING: loadimmutable failed for key: {key}. Available: {list(self.ctx.immutables.keys())}", file=sys.stderr)
            return IRLiteral(0)

        if func == "linkersymbol":
            # External library linking: linkersymbol("path:LibraryName")
            # Returns a placeholder address for the library.
            # 
            # For transpilation, we support two modes:
            # 1. If library address is in ctx.library_addresses dict, use it
            # 2. Otherwise, return a placeholder (0xDEADxxxxxx...) that can be patched
            #
            # The placeholder format uses the library name hash to create unique addresses.
            
            lib_path = None
            if args and hasattr(args[0], 'value'):
                val = args[0].value
                if isinstance(val, str):
                    lib_path = val.strip('"')
            
            if lib_path:
                # Check if we have a configured address for this library
                if hasattr(self.ctx, 'library_addresses') and lib_path in self.ctx.library_addresses:
                    addr = self.ctx.library_addresses[lib_path]
                    if isinstance(addr, str) and addr.startswith("0x"):
                        addr = int(addr, 16)
                    return IRLiteral(addr)
                
                # Generate a deterministic placeholder address from library path
                # Use keccak-like hash of the path to create unique placeholder
                import hashlib
                h = hashlib.sha256(lib_path.encode()).hexdigest()[:40]
                placeholder = int("0x" + h, 16) & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                
                print(f"WARNING: linkersymbol({lib_path}) using placeholder address: 0x{placeholder:040x}", file=sys.stderr)
                print(f"  To use a real library address, add to config: library_addresses['{lib_path}'] = '0x...'", file=sys.stderr)
                
                return IRLiteral(placeholder)
            
            print(f"WARNING: linkersymbol failed - no library path provided", file=sys.stderr)
            return IRLiteral(0)

        # Map opcodes
        # Full mapping based on basicblock.py support
        
        # VENOM-NATIVE: The Venom backend (venom_to_assembly.py line 514) already
        # reverses operands via `operands = list(reversed(inst.operands))`.
        # So we emit operands in Yul order and let the backend handle EVM ordering.
        # This avoids the double-reversal bug that was causing incorrect bytecode.
        
        if func == "memoryguard":
            # Venom Backend reserves 0x80-VENOM_MEMORY_START for stack spills (Frame).
            # We MUST start Yul heap at VENOM_MEMORY_START to avoid corruption.
            return IRLiteral(VENOM_MEMORY_START)
        
        # VENOM-NATIVE MEMORY MODEL: Handle mload(64) - Solidity's allocate_unbounded
        # 
        # VERIFIED: Native Vyper uses HARDCODED addresses for return buffers, not alloca.
        # Example from native Vyper runtime VNM:
        #   mstore %492, %491
        #   %493 = 32        ; size
        #   %494 = 64        ; hardcoded address!
        #   return %494, %493
        #
        # alloca is for LOCAL VARIABLES only → Mem2Var converts to registers (init 0).
        # Return buffers need REAL memory addresses → use constants like native Vyper.
        #
        # We use addresses starting at 0x1000 to avoid Venom's stack spill region (0x80-0x1000).
        #
        
        if func == "mload":
             # NO OVERRIDE: Allow reading FMP from memory (0x40).
             # We rely on memoryguard returning 0x1000 to set the safe initial FMP.
             pass

        


        if func == "invalid":
             return self.current_bb.append_instruction("invalid")
        
        # OPERAND ORDERING:
        # Extensive testing confirmed that Yul argument order matches EVM stack order (Top -> Bottom).
        # Example: Yul mstore(p, v) -> Args [p, v]. EVM MSTORE expects Stack: p (Top), v.
        # Example: Yul mcopy(dst, src, len) -> Args [dst, src, len]. EVM MCOPY expects Stack: dst (Top), src, len.
        # Venom backend preserves this order (operands[0] -> Top).
        # Therefore, we pass arguments 1:1 without reversal.
        
        if func in ("codecopy", "calldatacopy", "returndatacopy", "mcopy"):
            self.current_bb.append_instruction(func, *args)
            return IRLiteral(0)
        
        if func == "extcodecopy":
            self.current_bb.append_instruction(func, *args)
            return IRLiteral(0)
        
        if func in ("pop", "log0", "log1", "log2", "log3", "log4", "stop", "selfdestruct"):
            self.current_bb.append_instruction(func, *args)
            return IRLiteral(0)
        
        # MSTORE TRACKING for sha3_64 optimization
        # Track recent mstores to detect keccak256(mstore(0, key), mstore(32, slot)) -> sha3_64
        if func == "mstore":
            # Track this mstore for potential sha3_64 pattern
            if len(args) >= 2:
                offset, value = args[0], args[1]
                # Only track mstores to scratch space (0x00-0x3F) used for mapping slots
                if isinstance(offset, IRLiteral) and offset.value in (0, 32):
                    self.recent_mstores.append((offset, value))
                    # Keep only the last 4 mstores to bound memory usage
                    if len(self.recent_mstores) > 4:
                        self.recent_mstores.pop(0)
                else:
                    # Non-scratch mstore clears the tracking (pattern broken)
                    self.recent_mstores.clear()
            self.current_bb.append_instruction("mstore", *args)
            return IRLiteral(0)
        
        # sstore/tstore: void, no tracking needed
        if func in ("sstore", "tstore"):
            self.current_bb.append_instruction(func, *args)
            return IRLiteral(0)
        
        # return/revert: Yul order (offset, size) -> Venom order (offset, size)
        # Backend places Operand 0 (offset) at Top, which EVM expects.
        if func in ("return", "revert"):
            self.current_bb.append_instruction(func, *args)
            return IRLiteral(0)

        # 1-output instructions
        # Non-commutative ops: sub(a, b). Backend pushes a, b. Top = a. EVM SUB = a - b. Correct.
        if func in ("sub", "div", "sdiv", "mod", "smod", "exp", "lt", "gt", "slt", "sgt", "shl", "shr", "sar"):
             return self.current_bb.append_instruction1(func, *args)

        # sha3/keccak256: Yul uses keccak256, Venom uses sha3
        # Note: We previously had a sha3_64 optimization here, but it's been removed
        # because the Vyper backend doesn't handle sha3_64 in the VNM text path,
        # and expanding it back to mstore+sha3 provides no gas savings.
        # The Yul code already has the mstores, so we just use native sha3.
        if func in ("sha3", "keccak256"):
            return self.current_bb.append_instruction1("sha3", *args)


        if func in ("add", "mul", "not", "eq", "iszero", "and", "or", "xor", "addmod", "mulmod", "signextend", "mload", "sload", "tload", "calldataload", "callvalue", "calldatasize", "codesize", "returndatasize", "gas", "address", "caller", "origin", "gasprice", "chainid", "basefee", "timestamp", "number", "difficulty", "gaslimit"):
            return self.current_bb.append_instruction1(func, *args)
            
        # Call-like (volatile, returns 1)
        if func in ("call", "staticcall", "delegatecall", "create", "create2"):
            # These usually return success/address
            return self._emit_deduplicated(func, *args)

        # Fallback for strict passthrough
        return self._emit_deduplicated(func, *args)

    def _emit_deduplicated(self, op, *operands):
        """Emit instruction with deduplication and peephole optimizations.
        
        Optimization Architecture:
        1. FIRST: Try optimizations.py pipeline via optimizer.try_optimize_operand()
           - Handles statement-level patterns (assert, sha3_64, inlining)
           - Can only return replacement operands, not emit new instructions
           
        2. FALLBACK: Peephole optimizations here in venom_generator.py
           - Handles algebraic identities (add(x,0)=x, mul(x,1)=x)
           - Can emit TRANSFORMED instructions (mul(x,2^n)→shl(n,x))
           - Can do constant folding (iszero(0)=1, not(31)=mask)
           
        Power-of-2 optimizations (mul→shl, div→shr, mod→and, exp(2,n)→shl)
        MUST be here because they emit different opcodes, not just replace values.
        """
        # DELEGATE TO OPTIMIZATION PIPELINE
        # Try algebraic identity optimization first
        result = self.optimizer.try_optimize_operand(op, list(operands), 
            lambda opc, *args: self.current_bb.append_instruction(opc, *args))
        if result is not None:
            return result
        
        # PEEPHOLE OPTIMIZATIONS (emit-time transformations)
        # Catch and eliminate trivial operations at generation time
        if len(operands) == 2:
            a, b = operands
            a_is_zero = isinstance(a, IRLiteral) and a.value == 0
            b_is_zero = isinstance(b, IRLiteral) and b.value == 0
            a_is_one = isinstance(a, IRLiteral) and a.value == 1
            b_is_one = isinstance(b, IRLiteral) and b.value == 1
            a_is_neg1 = isinstance(a, IRLiteral) and a.value == (2**256 - 1)
            b_is_neg1 = isinstance(b, IRLiteral) and b.value == (2**256 - 1)
            
            # add(x, 0) = x, add(0, x) = x
            if op == "add":
                if b_is_zero:
                    return a
                if a_is_zero:
                    return b
            
            # sub(x, 0) = x
            if op == "sub" and b_is_zero:
                return a
            
            # sub(x, x) = 0 (same variable)
            if op == "sub" and isinstance(a, IRVariable) and isinstance(b, IRVariable) and a.name == b.name:
                return IRLiteral(0)
            
            # mul(x, 1) = x, mul(1, x) = x
            if op == "mul":
                if b_is_one:
                    return a
                if a_is_one:
                    return b
                # mul(x, 0) = 0, mul(0, x) = 0
                if a_is_zero or b_is_zero:
                    return IRLiteral(0)
                # POWER-OF-2 OPTIMIZATION: mul(x, 2^n) → shl(n, x) (5 gas → 3 gas)
                if isinstance(b, IRLiteral) and b.value > 1:
                    log2 = self._log2_exact(b.value)
                    if log2 is not None:
                        return self.current_bb.append_instruction1("shl", IRLiteral(log2), a)
                if isinstance(a, IRLiteral) and a.value > 1:
                    log2 = self._log2_exact(a.value)
                    if log2 is not None:
                        return self.current_bb.append_instruction1("shl", IRLiteral(log2), b)
            
            # POWER-OF-2 OPTIMIZATION: div(x, 2^n) → shr(n, x) (5 gas → 3 gas)
            if op == "div":
                if b_is_one:
                    return a
                if isinstance(b, IRLiteral) and b.value > 1:
                    log2 = self._log2_exact(b.value)
                    if log2 is not None:
                        return self.current_bb.append_instruction1("shr", IRLiteral(log2), a)
            
            # POWER-OF-2 OPTIMIZATION: mod(x, 2^n) → and(x, 2^n - 1) (5 gas → 3 gas)
            if op == "mod":
                if isinstance(b, IRLiteral) and b.value > 1:
                    log2 = self._log2_exact(b.value)
                    if log2 is not None:
                        mask = b.value - 1
                        return self.current_bb.append_instruction1("and", IRLiteral(mask), a)
            
            # and(x, -1) = x, and(-1, x) = x (no-op mask)
            if op == "and":
                if b_is_neg1:
                    return a
                if a_is_neg1:
                    return b
                # and(x, 0) = 0
                if a_is_zero or b_is_zero:
                    return IRLiteral(0)
            
            # or(x, 0) = x, or(0, x) = x
            if op == "or":
                if b_is_zero:
                    return a
                if a_is_zero:
                    return b
                # or(x, -1) = -1
                if a_is_neg1 or b_is_neg1:
                    return IRLiteral(2**256 - 1)
            
            # xor(x, 0) = x, xor(0, x) = x
            if op == "xor":
                if b_is_zero:
                    return a
                if a_is_zero:
                    return b
                # xor(x, x) = 0
                if isinstance(a, IRVariable) and isinstance(b, IRVariable) and a.name == b.name:
                    return IRLiteral(0)
            
            # div(x, 1) = x
            if op == "div" and b_is_one:
                return a
            
            # shr(0, x) = x (shift by 0)
            if op == "shr" and a_is_zero:
                return b
            
            # shl(0, x) = x (shift by 0)
            if op == "shl" and a_is_zero:
                return b
            
            # eq(x, x) = 1
            if op == "eq" and isinstance(a, IRVariable) and isinstance(b, IRVariable) and a.name == b.name:
                return IRLiteral(1)
            
            # POWER OPTIMIZATION: exp(2, n) → shl(n, 1) (10+50*bits gas → 3 gas)
            # exp with base 2 is much cheaper as a shift
            if op == "exp":
                if isinstance(a, IRLiteral) and a.value == 2:
                    return self.current_bb.append_instruction1("shl", b, IRLiteral(1))
        
        # CONSTANT FOLDING for common patterns
        if len(operands) == 1:
            a = operands[0]
            # not(31) = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0
            if op == "not" and isinstance(a, IRLiteral) and a.value == 31:
                return IRLiteral(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0)
            # iszero(0) = 1
            if op == "iszero" and isinstance(a, IRLiteral) and a.value == 0:
                return IRLiteral(1)
            # iszero(non-zero literal) = 0
            if op == "iszero" and isinstance(a, IRLiteral) and a.value != 0:
                return IRLiteral(0)
        
        # DEDUPLICATION: Venom backend forbids duplicate consumed operands
        seen_vars = set()
        new_operands = []
        
        for arg in operands:
            if isinstance(arg, IRVariable):
                if arg.name in seen_vars:
                    # Duplicate usage! Create alias using add(x, 0)
                    alias_var = self.current_bb.append_instruction("add", arg, IRLiteral(0))
                    new_operands.append(alias_var)
                    continue
                else:
                    seen_vars.add(arg.name)
            
            new_operands.append(arg)
            
        if op in ("call", "staticcall", "delegatecall", "create", "create2"):
             return self.current_bb.append_instruction1(op, *new_operands)
        return self.current_bb.append_instruction(op, *new_operands)
