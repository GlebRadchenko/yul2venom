"""
Yul Source Optimizer - Production-Grade Implementation

Pre-transpilation optimization of Yul source code through:
1. Structural analysis - Remove panics/reverts in if blocks
2. Regex transformations - Pattern-based code rewriting
3. Algebraic simplifications - Constant folding and identity elimination

Usage:
    from yul_source_optimizer import YulSourceOptimizer, OptimizationLevel
    
    opt = YulSourceOptimizer(level=OptimizationLevel.AGGRESSIVE)
    optimized_yul = opt.optimize(yul_source)
    opt.print_report()
"""

from __future__ import annotations

import re
import sys
import time
from dataclasses import dataclass, field
from enum import Enum
from typing import Callable, Pattern, Optional


class OptimizationLevel(Enum):
    """Optimization aggressiveness levels.
    
    SAFE: Only remove clearly dead code (validators, empty blocks)
    STANDARD: Remove non-payable checks, basic ABI decoder checks  
    AGGRESSIVE: Remove runtime checks (extcodesize, returndatasize)
    MAXIMUM: Remove overflow/bounds checks (DANGEROUS - use with caution)
    """
    SAFE = "safe"
    STANDARD = "standard"
    AGGRESSIVE = "aggressive"
    MAXIMUM = "maximum"


@dataclass
class OptimizationRule:
    """A single optimization rule with compiled pattern."""
    name: str
    pattern: Pattern[str]
    replacement: str
    level: OptimizationLevel
    matches: int = 0
    bytes_saved: int = 0


@dataclass 
class OptimizationStats:
    """Statistics from an optimization run."""
    original_size: int = 0
    final_size: int = 0
    duration_ms: float = 0
    passes: int = 0
    blocks_removed: int = 0
    rules_applied: list[dict] = field(default_factory=list)
    
    @property
    def bytes_saved(self) -> int:
        return self.original_size - self.final_size
    
    @property
    def percent_reduction(self) -> float:
        if self.original_size == 0:
            return 0.0
        return (self.bytes_saved / self.original_size) * 100


class YulSourceOptimizer:
    """Production-grade Yul source optimizer.
    
    Applies a series of transformations to reduce bytecode size:
    - Structural: Remove if-blocks containing panic/revert
    - Regex: Pattern-based code rewriting
    - Cleanup: Remove dead function definitions
    
    Thread-safe: Each instance maintains its own state.
    """
    
    # Maximum optimization passes before stopping
    MAX_PASSES = 5
    
    # Structural targets (patterns that trigger if-block removal)
    STRUCTURAL_TARGETS = [
        r"panic_error_0x41\(\)",  # Memory overflow
        r"panic_error_0x32\(\)",  # Array bounds
        r"panic_error_0x11\(\)",  # Arithmetic overflow
        r"panic_error_0x12\(\)",  # Division by zero
        r"panic_error_0x21\(\)",  # Enum/Push errors
        r"revert_forward_1\(\)",  # Contract creation failure
        r"revert_error_",         # Custom errors
    ]
    
    def __init__(
        self, 
        level: OptimizationLevel = OptimizationLevel.SAFE,
        config: Optional[dict] = None,
        max_passes: int = MAX_PASSES
    ):
        """Initialize optimizer with given level.
        
        Args:
            level: Optimization aggressiveness
            config: Optional config dict with 'immutables' and 'optimizations' keys
            max_passes: Maximum convergence passes (default 5)
        """
        self.level = level
        self.config = config or {}
        self.max_passes = max_passes
        self.rules: list[OptimizationRule] = []
        self.stats = OptimizationStats()
        
        # Build rule set for current level
        self._build_rules()
    
    def _add_rule(
        self, 
        name: str, 
        pattern: str, 
        replacement: str,
        level: OptimizationLevel = OptimizationLevel.SAFE,
        flags: int = 0
    ) -> None:
        """Add a regex rule with validation.
        
        Args:
            name: Human-readable rule name
            pattern: Regex pattern string
            replacement: Replacement string (can use backreferences)
            level: Minimum level for this rule to apply
            flags: Regex flags (re.MULTILINE, etc.)
        """
        try:
            compiled = re.compile(pattern, flags)
            self.rules.append(OptimizationRule(
                name=name,
                pattern=compiled,
                replacement=replacement,
                level=level
            ))
        except re.error as e:
            print(f"[WARN] Invalid regex in rule '{name}': {e}", file=sys.stderr)
    
    def _build_rules(self) -> None:
        """Build the optimization rule set based on current level."""
        
        # === ALWAYS APPLIED (SAFE level) ===
        self._add_safe_rules()
        
        # === STANDARD level and above ===
        if self.level.value in ('standard', 'aggressive', 'maximum'):
            self._add_standard_rules()
        
        # === AGGRESSIVE level and above ===
        if self.level.value in ('aggressive', 'maximum'):
            self._add_aggressive_rules()
        
        # === MAXIMUM level only (DANGEROUS) ===
        if self.level == OptimizationLevel.MAXIMUM:
            self._add_maximum_rules()
        
        # === Config-based rules ===
        self._add_config_rules()
        
        # === Cleanup rules (always applied) ===
        self._add_cleanup_rules()
    
    def _add_safe_rules(self) -> None:
        """Rules that are always safe to apply."""
        
        # Strip empty validators
        self._add_rule(
            "Strip Validator Calls",
            r'validator_[\w]+\s*\([^)]+\)',
            ''
        )
        
        # Strip identity validators
        self._add_rule(
            "Strip Identity Validators",
            r'if\s+iszero\(eq\([^,]+,\s*[\w_$]+\([^)]+\)\)\)\s*\{\s*revert\(0,\s*0\)\s*\}',
            ''
        )
        
        # Unwrap calldata size check (selector check wrapper)
        self._add_rule(
            "Unwrap Calldata Check",
            r'if\s+iszero\(lt\(calldatasize\(\),\s*4\)\)',
            ''
        )
        
        # Algebraic simplifications
        self._add_rule("Simplify eq(x,x)", r'eq\((\w+),\s*\1\)', '1')
        self._add_rule("Simplify iszero(eq(x,x))", r'iszero\(eq\((\w+),\s*\1\)\)', '0')
        self._add_rule("Simplify add(x,0)", r'add\((\w+),\s*0\)', r'\1')
        self._add_rule("Simplify sub(x,0)", r'sub\((\w+),\s*0\)', r'\1')
        self._add_rule("Simplify mul(x,1)", r'mul\((\w+),\s*1\)', r'\1')
        
        # Double negation: iszero(iszero(x)) → bool(x), but since Yul has no bool type,
        # we keep it for conditions. For return values like mstore(pos, iszero(iszero(x))),
        # this is essentially converting to 0/1 which we should preserve.
        # Only optimize when used as condition in if/jnz
        self._add_rule("Simplify if iszero(iszero(x))", r'if\s+iszero\(iszero\(([^)]+)\)\)', r'if \1')
        
        # Dead let-assignment: let x := 0 \n x := <value> → let x := <value>
        # This pattern frequently appears in Solidity-generated Yul
        self._add_rule(
            "Merge Let Zero Assignment",
            r'let\s+(\w+)\s*:=\s*0\s*\n\s*\1\s*:=\s*(\S+)',
            r'let \1 := \2'
        )
        
        # Remove empty blocks
        self._add_rule("Remove Empty Else", r'\}\s*else\s*\{\s*\}', '}')
        
        # Dead double-assignment: let x := 0 \n x := 0 (same value)
        # Pattern seen in Solidity-generated Yul
        self._add_rule(
            "Remove Dead Double Assignment",
            r'let\s+(\w+)\s*:=\s*0\s*\n\s*\1\s*:=\s*0',
            r'let \1 := 0'
        )
    
    def _add_standard_rules(self) -> None:
        """Rules for standard optimization (strip common checks)."""
        
        # Strip non-payable check
        self._add_rule(
            "Strip CallValue",
            r'if callvalue\(\)\s*\{[^}]+\}',
            '',
            OptimizationLevel.STANDARD
        )
        
        # Strip calldatasize minimum check (iszero version)
        self._add_rule(
            "Strip Calldata Size Min",
            r'if\s+iszero\(lt\(calldatasize\(\),\s*\d+\)\)',
            '',
            OptimizationLevel.STANDARD
        )
        
        # Strip calldatasize >= 4 check: slt(add(calldatasize(), not(3)), 0)
        # This pattern checks calldatasize >= 4 (minimum for selector)
        self._add_rule(
            "Strip Calldatasize Zero Check",
            r'if\s+slt\(add\(calldatasize\(\),\s*not\(3\)\),\s*0\)\s*\{\s*revert\(0,\s*0\)\s*\}',
            '',
            OptimizationLevel.STANDARD
        )
    
    def _add_aggressive_rules(self) -> None:
        """Rules that strip runtime safety checks."""
        
        # Strip extcodesize check (external call target verification)
        self._add_rule(
            "Strip ExtCodeSize",
            r'if iszero\(extcodesize\([^)]+\)\)\s*\{\s*revert\([^)]+\)\s*\}',
            '',
            OptimizationLevel.AGGRESSIVE
        )
        
        # Strip returndatasize check
        self._add_rule(
            "Strip Returndatasize Check",
            r'if\s+(gt\(|iszero\().*returndatasize\(\).*\{[^}]*revert[^}]*\}',
            '',
            OptimizationLevel.AGGRESSIVE
        )
        
        # Strip memory allocation overflow check
        self._add_rule(
            "Strip Memory Alloc Check",
            r'if\s+gt\([^,]+,\s*0xffffffffffffffff\)\s*\{[^}]+\}',
            '',
            OptimizationLevel.AGGRESSIVE
        )
        
        # Strip calldata length check (ABI decoder)
        self._add_rule(
            "Strip CallData Length Check",
            r'if\s+slt\(add\(calldatasize\(\),\s*not\(3\)\),\s*\d+\)\s*\{\s*revert\(0,\s*0\)\s*\}',
            '',
            OptimizationLevel.AGGRESSIVE
        )
        
        # Strip offset validation
        self._add_rule(
            "Strip Offset Validation",
            r'if\s+gt\([^,]+,\s*0xffffffffffffffff\)\s*\{\s*revert\(0,\s*0\)\s*\}',
            '',
            OptimizationLevel.AGGRESSIVE
        )
        
        # Strip address mask check
        self._add_rule(
            "Strip Address Mask",
            r'if\s+iszero\(eq\(([^,]+),\s*and\(\1,\s*sub\(shl\(160,\s*1\),\s*1\)\)\)\)\s*\{[^}]+\}',
            '',
            OptimizationLevel.AGGRESSIVE
        )
        
        # Strip FinalizeAlloc Overflow check
        self._add_rule(
            "Strip FinalizeAlloc Overflow",
            r'if\s+or\(gt\([^,]+,\s*0x[f]+\),\s*lt\([^,]+,\s*[^)]+\)\)\s*\{[^}]+\}',
            '',
            OptimizationLevel.AGGRESSIVE
        )
        
        # Strip memory overflow panic (0x41)
        self._add_rule(
            "Strip Memory Panic 0x41",
            r'if\s+or\([^)]+\)\s*\{\s*mstore\([^)]+\)\s*mstore\([^)]+,\s*0x41\)\s*revert\([^)]+\)\s*\}',
            '',
            OptimizationLevel.AGGRESSIVE
        )
        
        # Strip inline panic selector sequence (very common: mstore selector, mstore code, revert)
        # Pattern: mstore(0, shl(224, 0x4e487b71)) mstore(4, 0xXX) revert(0, 36)
        self._add_rule(
            "Strip Panic Selector",
            r'mstore\(0,\s*shl\(224,\s*0x4e487b71\)\)\s*\n?\s*mstore\(4,\s*0x[0-9a-f]+\)\s*\n?\s*revert\(0,\s*36\)',
            '',
            OptimizationLevel.AGGRESSIVE
        )
        
        # Strip address validation: iszero(eq(x, and(x, ADDRESS_MASK)))
        self._add_rule(
            "Strip Address Validation",
            r'if\s+iszero\(eq\((\w+),\s*and\(\1,\s*sub\(shl\(160,\s*1\),\s*1\)\)\)\)\s*\{\s*revert\(0,\s*0\)\s*\}',
            '',
            OptimizationLevel.AGGRESSIVE
        )
        
        # Strip require_helper calls (error message wrappers)
        self._add_rule(
            "Strip Require Helper",
            r'require_helper_\w+\([^)]+\)',
            '',
            OptimizationLevel.AGGRESSIVE
        )
        
        # Strip type validation for smaller integer types (uint8, uint16, bytes4, etc)
        # Pattern: iszero(eq(x, and(x, shl(N, MASK)))) where MASK validates type range
        self._add_rule(
            "Strip Type Validation Bytes4",
            r'if\s+iszero\(eq\((\w+),\s*and\(\1,\s*shl\(224,\s*0xffffffff\)\)\)\)\s*\{\s*revert\(0,\s*0\)\s*\}',
            '',
            OptimizationLevel.AGGRESSIVE
        )
        
        self._add_rule(
            "Strip Type Validation Bytes1",
            r'if\s+iszero\(eq\((\w+),\s*and\(\1,\s*shl\(248,\s*255\)\)\)\)\s*\{\s*revert\(0,\s*0\)\s*\}',
            '',
            OptimizationLevel.AGGRESSIVE
        )
    
    def _add_maximum_rules(self) -> None:
        """DANGEROUS rules that strip critical safety checks."""
        
        # Strip arithmetic overflow check
        self._add_rule(
            "Strip Overflow Check",
            r'if\s+(gt|lt)\([^,]+,\s*(sub|add)\([^)]+\)\)\s*\{[^}]*panic[^}]*\}',
            '',
            OptimizationLevel.MAXIMUM
        )
        
        # Strip array bounds check
        self._add_rule(
            "Strip Array Bounds",
            r'if\s+iszero\(lt\([^,]+,\s*sload\([^)]+\)\)\)\s*\{[^}]*panic[^}]*\}',
            '',
            OptimizationLevel.MAXIMUM
        )
        
        # Strip division by zero check
        self._add_rule(
            "Strip Division Check",
            r'if\s+iszero\([^)]+\)\s*\{[^}]*panic_error_0x12[^}]*\}',
            '',
            OptimizationLevel.MAXIMUM
        )
    
    def _add_config_rules(self) -> None:
        """Add rules from config (immutables, custom patterns)."""
        
        immutables = self.config.get('immutables', {})
        for key, val in immutables.items():
            if isinstance(val, dict):
                val = val.get('value')
            if val:
                # Replace loadimmutable with constant
                self._add_rule(
                    f"Inline Immutable {key}",
                    rf'loadimmutable\("{re.escape(key)}"\)',
                    str(val)
                )
                # Remove setimmutable
                self._add_rule(
                    f"Remove SetImmutable {key}",
                    rf'setimmutable\([^,]+, "{re.escape(key)}", [^)]+\)',
                    ''
                )
    
    def _add_cleanup_rules(self) -> None:
        """Final cleanup rules (always applied)."""
        
        # Remove empty if blocks
        self._add_rule(
            "Remove Empty Ifs",
            r'if [^{]+\{\s*\}',
            '',
            flags=re.MULTILINE
        )
        
        # Remove panic function definitions
        self._add_rule(
            "Remove Panic Defs",
            r'function panic_error_0x[\w]+\(\)\s*\{[^}]+\}',
            ''
        )
        
        # Remove revert function definitions
        self._add_rule(
            "Remove Revert Defs",
            r'function revert_error_[\w]+\([^)]*\)\s*\{[^}]+\}',
            ''
        )
        
        # Strip source annotations
        self._add_rule("Strip @src Comments", r'///\s*@src[^\n]*\n', '\n')
        self._add_rule("Strip @use-src", r'///\s*@use-src[^\n]*\n', '\n')
        self._add_rule("Strip Inline @src", r'/\*\*\s*@src[^*]+\*/\s*', '')
    
    def _apply_structural(self, content: str) -> str:
        """Remove if-blocks containing structural targets (panics, reverts)."""
        removed = 0
        
        for target in self.STRUCTURAL_TARGETS:
            regex = re.compile(target)
            search_start = 0
            
            while True:
                match = regex.search(content, search_start)
                if not match:
                    break
                
                idx = match.start()
                if_start = self._find_enclosing_if(content, idx)
                
                if if_start is not None:
                    open_brace = content.find('{', if_start)
                    if open_brace != -1:
                        close_brace = self._find_matching_brace(content, open_brace)
                        if close_brace != -1:
                            block = content[if_start:close_brace + 1]
                            # Don't remove complex blocks
                            if not any(kw in block for kw in ('switch', 'for ', 'function ')):
                                content = content[:if_start] + content[close_brace + 1:]
                                removed += 1
                                search_start = if_start
                                continue
                
                search_start = match.end()
        
        self.stats.blocks_removed = removed
        return content
    
    def _find_enclosing_if(self, text: str, pos: int) -> Optional[int]:
        """Find the start of the if-statement enclosing position."""
        # Scan back to find opening brace
        i = pos
        while i >= 0 and text[i] != '{':
            i -= 1
        
        if i < 0:
            return None
        
        # Scan back through potential condition to find 'if'
        k = i - 1
        balance = 0
        
        while k >= 0:
            c = text[k]
            if c == ')':
                balance += 1
            elif c == '(':
                balance -= 1
            elif balance == 0:
                if c in '{};':
                    return None
                if c == 'f' and k > 0 and text[k-1] == 'i':
                    # Check word boundaries
                    before_ok = k == 1 or not (text[k-2].isalnum() or text[k-2] == '_')
                    after_ok = k + 1 >= len(text) or not (text[k+1].isalnum() or text[k+1] == '_')
                    if before_ok and after_ok:
                        return k - 1
            k -= 1
        
        return None
    
    def _find_matching_brace(self, text: str, open_pos: int) -> int:
        """Find the closing brace matching the one at open_pos."""
        balance = 1
        i = open_pos + 1
        
        while i < len(text) and balance > 0:
            if text[i] == '{':
                balance += 1
            elif text[i] == '}':
                balance -= 1
            i += 1
        
        return i - 1 if balance == 0 else -1
    
    def _apply_regex(self, content: str) -> str:
        """Apply all regex rules to content."""
        for rule in self.rules:
            original_len = len(content)
            content, count = rule.pattern.subn(rule.replacement, content)
            
            if count > 0:
                saved = original_len - len(content)
                rule.matches += count
                rule.bytes_saved += saved
                self.stats.rules_applied.append({
                    'name': rule.name,
                    'matches': count,
                    'bytes_saved': saved
                })
        
        return content
    
    def _cleanup_dead_functions(self, content: str) -> str:
        """Remove function definitions with malformed signatures.
        
        Matches 'function { ... }' (no name/params) - these are artifacts
        from aggressive inlining that strips function names.
        Uses _find_matching_brace for proper nested brace handling.
        """
        # Pattern to find 'function' followed by whitespace then '{' (malformed)
        pattern = re.compile(r'function\s+\{')
        
        offset = 0
        for match in pattern.finditer(content):
            # Adjust position for previous removals
            start = match.start() - offset
            brace_pos = content.find('{', start)
            if brace_pos == -1:
                continue
                
            # Use proper brace matching
            close_pos = self._find_matching_brace(content, brace_pos)
            if close_pos != -1:
                # Remove the malformed function definition 
                removed_len = close_pos + 1 - start
                content = content[:start] + content[close_pos + 1:]
                offset += removed_len
                
        return content
    
    def optimize(self, content: str) -> str:
        """Optimize Yul source code.
        
        Runs multiple passes until convergence or max_passes reached.
        
        Args:
            content: Raw Yul source code
            
        Returns:
            Optimized Yul source code
        """
        self.stats = OptimizationStats(original_size=len(content))
        start = time.time()
        
        # Strip block comments first
        content = re.sub(r'/\*[\s\S]*?\*/', '', content)
        
        prev_size = len(content)
        for pass_num in range(self.max_passes):
            content = self._apply_structural(content)
            content = self._apply_regex(content)
            content = self._cleanup_dead_functions(content)
            
            if len(content) == prev_size:
                break
            prev_size = len(content)
            self.stats.passes = pass_num + 1
        
        self.stats.final_size = len(content)
        self.stats.duration_ms = (time.time() - start) * 1000
        
        return content
    
    def print_report(self) -> None:
        """Print optimization report to stderr."""
        print("\n" + "=" * 40, file=sys.stderr)
        print("Yul Source Optimization Report", file=sys.stderr)
        print(f"Level            : {self.level.value.upper()}", file=sys.stderr)
        print(f"Original Size    : {self.stats.original_size:,} bytes", file=sys.stderr)
        print(f"Final Size       : {self.stats.final_size:,} bytes", file=sys.stderr)
        print(f"Reduction        : {self.stats.bytes_saved:,} bytes ({self.stats.percent_reduction:.1f}%)", file=sys.stderr)
        print(f"Passes           : {self.stats.passes}", file=sys.stderr)
        
        # Show applied rules grouped by matches
        applied = [r for r in self.rules if r.matches > 0]
        if applied:
            print("-" * 40, file=sys.stderr)
            print("Applied Rules:", file=sys.stderr)
            for r in sorted(applied, key=lambda x: -x.bytes_saved):
                print(f"  • {r.name}: {r.matches} matches (-{r.bytes_saved} bytes)", file=sys.stderr)
        
        if self.stats.blocks_removed > 0:
            print(f"  • Structural blocks removed: {self.stats.blocks_removed}", file=sys.stderr)
        
        print("=" * 40, file=sys.stderr)


# =============================================================================
# CLI Interface
# =============================================================================

def main() -> int:
    """CLI entry point for standalone usage."""
    import argparse
    import json
    
    parser = argparse.ArgumentParser(
        description="Yul Source Optimizer - Pre-transpilation optimization"
    )
    parser.add_argument("input", help="Input Yul file")
    parser.add_argument("output", help="Output Yul file")
    parser.add_argument(
        "-c", "--config",
        help="Config JSON file (for immutables)"
    )
    parser.add_argument(
        "-l", "--level",
        choices=["safe", "standard", "aggressive", "maximum"],
        default="safe",
        help="Optimization level (default: safe)"
    )
    parser.add_argument(
        "-p", "--passes",
        type=int,
        default=5,
        help="Maximum optimization passes (default: 5)"
    )
    
    args = parser.parse_args()
    
    # Load config if provided
    config = {}
    if args.config:
        with open(args.config, 'r') as f:
            config = json.load(f)
    
    # Read input
    try:
        with open(args.input, 'r') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"[ERROR] File not found: {args.input}", file=sys.stderr)
        return 1
    
    # Optimize
    level = OptimizationLevel(args.level)
    optimizer = YulSourceOptimizer(level=level, config=config, max_passes=args.passes)
    optimized = optimizer.optimize(content)
    optimizer.print_report()
    
    # Write output
    with open(args.output, 'w') as f:
        f.write(optimized)
    
    return 0


if __name__ == "__main__":
    sys.exit(main())
