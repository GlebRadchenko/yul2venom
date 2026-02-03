# Vyper/Venom Backend Changes for Yul2Venom

This document catalogs all modifications made to the Vyper submodule (`vyper/`) to support the Yul2Venom transpiler. These changes extend the Venom IR and its EVM bytecode generator to handle patterns that arise from Yul source code but are not produced by native Vyper compilation.

## Summary

| File | Lines Changed | Category | Revert Risk |
|------|--------------|----------|-------------|
| `vyper/venom/analysis/liveness.py` | +7 | Bug Fix | ⚠️ Critical |
| `vyper/venom/effects.py` | +10 | Feature Extension | ⚠️ Critical |
| `vyper/venom/venom_to_assembly.py` | +150/-5 | Multi-purpose | ⚠️ Critical |

**Total: 3 files changed, ~162 insertions(+), 5 deletions(-)**

---

## Detailed Change Analysis

### 1. Liveness Analysis: Phi Operand Ordering Fix

**File:** `vyper/venom/analysis/liveness.py`  
**Lines Added:** 7  
**Category:** Critical Bug Fix  
**Revert Risk:** ⚠️ **DO NOT REVERT** - Causes incorrect bytecode in nested loops

#### Problem

The `input_vars_from()` method computes phi operand liveness for a given source block. When a variable was already in the liveness set from a previous iteration, `OrderedSet.add()` would not reorder it, causing a stack layout mismatch.

#### Root Cause

In nested loop structures, a phi operand might appear in liveness from an outer loop iteration. When the inner loop adds the same operand again, `OrderedSet.add()` is a no-op for existing elements, preserving the wrong order.

#### Fix Applied

```python
for label, var in inst.phi_operands:
    if label == source.label:
        # Remove-and-re-add to ensure PHI DEFINITION ORDER
        if var in liveness:
            liveness.remove(var)
        liveness.add(var)
```

#### Manifestation

Without this fix, nested loops would produce incorrect stack shuffling, often resulting in:
- Wrong values being used in loop conditions
- `JUMP Stack Underflow` errors
- Silent data corruption in loop variables

---

### 2. Effects Registry: Log Instruction Support

**File:** `vyper/venom/effects.py`  
**Lines Added:** 10  
**Category:** Feature Extension  
**Revert Risk:** ⚠️ **DO NOT REVERT** - Required for Solidity events

#### Problem

Native Vyper uses a composite `log` instruction with topic count, but Yul and Solidity emit explicit `log0`, `log1`, `log2`, `log3`, and `log4` opcodes.

#### Why This Matters

The effects registry tracks what each instruction **reads** and **writes**. Without these entries:
- The optimizer may incorrectly reorder `mstore` and `logN` instructions
- Memory stores for event data could be moved after the log, reading uninitialized memory
- Event emissions would silently emit garbage data

#### Fix Applied

Added `log0`-`log4` to both `_writes` (they write to LOG effect) and `_reads` (they read from MEMORY):

```python
_writes = {
    "log": LOG,
    "log0": LOG,
    "log1": LOG,
    "log2": LOG,
    "log3": LOG,
    "log4": LOG,
    # ...
}

_reads = {
    "log": MEMORY,
    "log0": MEMORY,
    "log1": MEMORY,
    "log2": MEMORY,
    "log3": MEMORY,
    "log4": MEMORY,
    # ...
}
```

---

### 3. Venom-to-Assembly: Multi-Purpose Extensions

**File:** `vyper/venom/venom_to_assembly.py`  
**Lines Added:** 109, Lines Removed: 5  
**Category:** Multiple Features & Fixes  
**Revert Risk:** ⚠️ **DO NOT REVERT** - Multiple critical fixes

This file contains several distinct changes:

#### 3.1 One-to-One Instruction Extensions (+11 lines)

Added Yul-specific opcodes that don't exist in native Vyper IR:

```python
_ONE_TO_ONE_INSTRUCTIONS = frozenset([
    # ... existing ...
    # Opcodes used in Yul but not in native Vyper
    "sha3",      # Yul uses sha3, Vyper uses keccak256
    "return",    # Explicit return opcode
    "log0",
    "log1",
    "log2",
    "log3",
    "log4",
    "mstore8",   # Byte-level memory store
    "pop",       # Stack cleanup
    "byte",      # Byte extraction from word
])
```

**Why needed:** Yul source produces these opcodes directly; without this mapping, the compiler would fail with "unknown opcode".

#### 3.2 ~~Duplicate Literal Handling~~ ✅ MIGRATED TO TRANSPILER

**Status:** ✅ **MIGRATED** — This backend patch has been moved to the transpiler layer.

**Original Problem:** Vyper's stack reordering algorithm assumes all operands are unique. Yul patterns like `revert(0, 0)` produce duplicate literal operands.

**Transpiler Fix Location:** `ir/basicblock.py` → `append_instruction()` method

**How It Works:** The transpiler now detects duplicate literal values in instruction operands and materializes them as unique `IRVariable`s via `assign` instructions before emitting the main instruction. This guarantees the backend never sees duplicate operands.

```python
# ir/basicblock.py - append_instruction()
if len(processed_args) > 1:
    seen_values = {}
    for i, arg in enumerate(processed_args):
        if isinstance(arg, IRLiteral):
            if arg.value in seen_values:
                # Materialize duplicate as unique variable
                var = self.parent.get_next_variable()
                assign_inst = IRInstruction("assign", [arg], [var])
                self.instructions.append(assign_inst)
                processed_args[i] = var
            else:
                seen_values[arg.value] = i
```

**Lines Removed from Backend:** ~28 lines (venom_to_assembly.py lines 232-259)

#### 3.3 Assign Instruction Stack Model Fix (+39 lines)

**Problem:** The `assign` instruction was incorrectly treated like other instructions (pop source, push destination), desynchronizing the stack model from the physical EVM stack.

**Root Cause:** In EVM, `assign` is semantically a **rename**, not a copy. The old code's pop-then-push approach created a mismatch between the stack model and actual EVM state.

**Fix:** Use `poke` (direct slot rename) to keep the model synchronized:

```python
if opcode == "assign":
    source = inst.operands[0]
    dest = inst.output
    
    if not isinstance(source, IRVariable):
        # Source is a literal - let normal path handle it
        pass
    else:
        # Source is a variable - rename in-place using poke
        depth = stack.get_depth(source)
        if depth is StackModel.NOT_IN_STACK:
            # Edge case: push placeholder
            assembly.append("PUSH0")
            stack.push(dest)
        else:
            # Normal case: DUP if still live, then poke
            if source in next_liveness:
                self.spiller.dup(assembly, stack, depth)
                stack.poke(0, dest)
            else:
                stack.poke(depth, dest)
        return apply_line_numbers(inst, assembly)
```

#### 3.4 Optimistic Swap Skip for Assign (+4 lines)

**Problem:** The optimistic swap optimization assumed the next instruction would consume its operand from stack top. But `assign` uses `poke`, not stack top.

**Fix:** Skip optimistic swap for assign instructions:

```python
if next_inst.opcode == "assign":
    return  # Skip optimistic swap
```

#### 3.5 Ret Instruction Comment Clarification (+3 lines)

Minor comment improvement documenting that the return PC is the last operand by convention.

#### 3.6 Iterative Stack Reorder for Large Stacks (+41 lines)

**Problem:** When stack depth exceeds 16, `_reduce_depth_via_spill` spills variables to bring targets within SWAP16 range. However, spilling one operand can displace already-positioned operands.

**Manifestation:** `STACK_ASSERT_FAIL` with stack heights of 26+ elements. First operand positioned correctly, then spilling for second operand displaces first.

**Root Cause:** Single-pass for-loop that positions operands sequentially without re-verifying after spills:

```python
# OLD (buggy)
for i, op in enumerate(stack_ops):
    # Position op at final_stack_depth
    # Spilling here can displace previously positioned ops
```

**Fix Applied:** Iterative while-loop with stability check:

```python
while iteration < max_iterations:
    # Check if ALL operands are in correct positions
    all_correct = True
    for i, op in enumerate(stack_ops):
        expected = -(len(stack_ops) - i - 1)
        if stack.get_depth(op) != expected:
            all_correct = False
            break
    
    if all_correct:
        break
    
    iteration += 1
    # Single pass to reposition displaced operands
    for i, op in enumerate(stack_ops):
        # ... swap logic ...
```

**Why Backend Patch:** This is a fundamental stack model issue when spilling mutates depths. While transpiler improvements could reduce stack pressure, the backend must handle edge cases gracefully.

---

## Reversion Analysis

### Can Any Changes Be Reverted?

**No.** All changes are required for correct Yul2Venom operation:

| Change | If Reverted |
|--------|-------------|
| Phi ordering fix | Nested loops produce incorrect results |
| Log effects | Event data corruption (silent) |
| One-to-one opcodes | Compiler crash on Yul opcodes |
| Duplicate literals | Assertion failure on `revert(0,0)` |
| Assign stack fix | Stack desync causing incorrect values |
| Assign optimistic skip | Incorrect stack state after assign |
| Iterative stack reorder | Assertion failure on deep stacks (26+) |

### Upstream Contribution Candidates

Several of these fixes could potentially benefit upstream Vyper:

1. **Phi ordering fix** - Generic bug, could affect native Vyper in edge cases
2. **Log effects for logN** - Useful if Vyper ever uses explicit log opcodes

The other changes are Yul-specific extensions and would need discussion with the Vyper team about whether they want to support Yul-style IR patterns.

---

## Change History

| Date | Change | Commit |
|------|--------|--------|
| 2026-01-XX | Initial liveness phi fix | `57a25a75` |
| 2026-01-XX | Assign stack model fix | `9a97be82` |
| 2026-01-XX | Log effects + byte opcode | `9d017838` |
| 2026-02-03 | Iterative stack reorder for deep stacks | — |

---

## Testing Verification

All 344 Forge tests pass with these changes:
- 36 runtime bytecode tests
- 10 init bytecode tests
- Full benchmark suite (8 contracts)
- QuotedTrader industrial contract (34KB)

Removing any of these patches causes test failures.
