# Venom-Native IR Requirements

> **Purpose**: Define the exact IR format the transpiler must emit to work with the Vyper Venom backend correctly.
>
> **Last Updated**: 2026-01-28 (Deep Analysis Session)

---

## Current Problem: OutOfGas in All Tests

All `OpcodeTest` cases fail with `EvmError: OutOfGas` despite:
- ✅ `check_venom_ctx()` PASSES - IR is semantically valid
- ✅ `check_calling_convention()` PASSES - Arity matches
- ✅ Optimization passes run successfully

This indicates the bug is in **assembly generation** (`venom_to_assembly.py`), not IR generation.

---

## Deep Analysis Findings

### 1. Native Vyper Calling Convention (VALIDATED)

From studying `ir_node_to_venom.py`:

**Function Entry (`_handle_internal_func`, line 316-406)**:
```python
# Arguments are captured in FORWARD order, then return_pc LAST
for arg in func_t.arguments:
    param = bb.append_instruction("param")
    # ...

# Return address is the LAST param (TOP of runtime stack)
return_pc = bb.append_instruction("param")
symbols["return_pc"] = return_pc
```

**Function Call (`_handle_self_call`, line 227-287)**:
```python
# Args are appended in FORWARD order, target label is FIRST
stack_args: list[IROperand] = [IRLabel(str(target_label))]
for alloca in callsite_args:
    stack_args.append(stack_arg)

# Uses proper API
bb.append_invoke_instruction(stack_args, returns=returns_count)
```

**Key Insight**: Native Vyper uses `append_invoke_instruction()` method, NOT `append_instruction("invoke", ...)`.

### 2. StackModel and Assembly Generation

From `stack_model.py`:
- Stack is indexed with `depth <= 0` (0 = top, -1 = second from top, etc.)
- `push()` appends to stack (new item on TOP)
- `pop(n)` removes n items from TOP
- `poke(depth, op)` replaces item at depth

From `venom_to_assembly.py`:

**`_prepare_stack_for_function` (line 382-409)**:
```python
# At function entry, the stack model is built by pushing param outputs
for inst in fn.entry.instructions:
    if inst.opcode != "param":
        break
    stack.push(inst.output)  # Builds model to match runtime
```

**`invoke` handling (line 996-1019)**:
```python
# Emits: PUSHLABEL return_label, PUSHLABEL target, JUMP, return_label
assembly.extend(
    [PUSHLABEL(return_label), PUSHLABEL(_as_asm_symbol(target)), "JUMP", return_label]
)
```

**`ret` handling (line 789-796, 1018-1019)**:
```python
# Prunes dead items, keeps only operands (return vals + pc)
target_vars = set(operands)
to_prune = [v for v in stack._stack if v not in target_vars]
self.popmany(assembly, to_prune, stack)
# Then emits JUMP
assembly.append("JUMP")
```

### 3. Memory Layout (CRITICAL)

```
0x00-0x3F:  Scratch space (EVM convention)
0x40:       Free Memory Pointer (Yul convention)
0x60:       Zero slot
0x80-0x1000: Venom RESERVED for stack spill frame
0x1000+:    Safe heap start for Yul transpiled code
```

**FIX APPLIED**: `memoryguard()` now returns `0x1000` instead of `0x80` in `venom_generator.py`.

### 4. Validation Checks (NOW ENABLED)

`yul2venom.py` now runs:
```python
from vyper.venom.check_venom import check_calling_convention, check_venom_ctx

check_venom_ctx(ctx)        # All vars defined, BBs terminated
check_calling_convention(ctx) # ret arities match, invoke arities match
```

These pass, confirming IR is valid.

---

## Current Transpiler State

### ✅ Correct

1. **Operand order**: Non-commutative ops use natural order (no double-reversal)
2. **param emission**: Forward order for args, PC last (line 266-275 in `venom_generator.py`)
3. **ret emission**: `ret ret_val, pc_var` format (line 306)
4. **memoryguard**: Returns `0x1000` (safe above spill frame)
5. **Validation**: Both checks pass before optimization

### ❌ Potential Issues

1. **invoke construction**: Uses `append_instruction("invoke", ...)` instead of `append_invoke_instruction()`
2. **Stack state tracking**: The stack model in `venom_to_assembly.py` may not be correctly synchronized with the actual EVM stack during `invoke` emission
3. **Assembly debug.asm shows infinite loops**: Suggests control flow corruption, likely from stack misalignment after `invoke`/`ret`

---

## Investigation Status

### What We Know
- All 8 tests fail with same pattern: `OutOfGas` (exhausts 30M gas)
- This happens immediately on entering internal function calls
- The `debug.asm` shows correct structure but execution loops infinitely

### Hypothesis: Stack Misalignment in invoke/ret

When `invoke` is emitted:
1. Operands are pushed to real stack via `_emit_input_operands`
2. Stack MODEL is updated (pops operands, pushes return vars)
3. Assembly emits `PUSHLABEL return, PUSHLABEL target, JUMP`
4. **PROBLEM**: The return_label is on real stack but NOT in stack model

When callee executes `ret`:
1. Return values are arranged on stack
2. PC (from param) should be on TOP
3. `JUMP` pops PC and returns to caller

**But if stack model is wrong, the PC might not be where JUMP expects it!**

---

## Safe Backend Optimization Passes

```python
PASSES_YUL_O2 = [
    FloatAllocas,           # ✅ Safe
    AssignElimination,      # ✅ Safe
    RevertToAssert,         # ✅ Safe
    SimplifyCFGPass,        # ✅ Safe
    MemMergePass,           # ✅ Safe
    LowerDloadPass,         # ✅ Safe
    ConcretizeMemLocPass,   # ✅ Safe
    Mem2Var,                # ✅ Safe
    MakeSSA,                # ✅ Safe
    RemoveUnusedVariablesPass, # ✅ Safe
    LoadElimination,        # ✅ Safe
    BranchOptimizationPass, # ✅ Safe
    RemoveUnusedVariablesPass, # ✅ Safe (again, post-optimization)
    PhiEliminationPass,     # ✅ Safe
    RemoveUnusedVariablesPass, # ✅ Safe (again, post-phi)
    CFGNormalization,       # ✅ Safe - REQUIRED for assembly emission
]
# EXCLUDED (Proven Unsafe for Yul-transpiled code):
# - SCCP
# - AlgebraicOptimizationPass
# - DeadStoreElimination
# - SingleUseExpansion
# - DFTPass
```

---

## Next Steps

1. **Trace stack state during invoke/ret**:
   - Add debug prints in `venom_to_assembly.py` showing stack model at invoke entry/exit
   - Compare against actual EVM trace

2. **Use native `append_invoke_instruction`**:
   - Refactor `venom_generator.py` to use `bb.append_invoke_instruction()`

3. **Examine `checked_sub_uint256` in debug.asm**:
   - This is the first internal function called
   - Look at stack arrangement before `JUMP` and after entry

4. **Consider regression to simpler baseline**:
   - Run with debug optimization level to isolate if passes cause the issue

---

## Files Modified in Local Fork

| File | Modification | Status |
|------|-------------|--------|
| `yul2venom.py` | Added `check_venom_ctx`, `check_calling_convention` | ✅ Valid |
| `venom_generator.py` | `memoryguard` returns 0x1000 | ✅ Valid |
| `venom_to_assembly.py` | Debug prints, JUMPDEST emission | 🔍 Under investigation |
| `__init__.py` | DCE disabled for callbacks | ✅ Valid |
| `memory_allocator.py` | FN_START = 0x1000 | ✅ Valid |

---

## Reference: Native Venom Instruction Format

From `README.md`:

| Instruction | Format | Description |
|------------|--------|-------------|
| `invoke` | `%out = invoke @label, args...` | Call internal function |
| `param` | `%out = param` | Pop argument from stack |
| `ret` | `ret values..., %pc` | Return with PC on top |
| `alloca` | `%out = alloca size, offset, id` | Allocate memory |
| `phi` | `%out = phi @lab1, %v1, @lab2, %v2` | SSA merge |

---

## Summary

The transpiler generates **semantically valid** Venom IR that passes all validation checks. The OutOfGas issue is in assembly generation, specifically in how the stack model tracks state across `invoke`/`ret` boundaries. The next debugging focus should be on `venom_to_assembly.py`'s handling of these instructions.
