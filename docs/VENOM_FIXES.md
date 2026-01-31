# Venom Backend Fixes

This document describes fixes made to the Venom IR backend that may be candidates for upstream contribution to Vyper.

---

## Fix 1: Liveness Analysis Phi Operand Ordering

### File
`vyper/venom/analysis/liveness.py`

### Issue
The `input_vars_from` method returns phi operands in an inconsistent order when multiple paths converge at a basic block with phi nodes. This causes stack layout mismatches when the assembler computes stack positions based on liveness sets.

### Root Cause
`OrderedSet.add()` does not reorder existing elements. When phi operands are already in the liveness set from previous fixed-point iterations, adding them again does not move them to their expected position according to phi definition order.

For example, with phis defined as:
```
%69 = phi @entry, %66, @backedge, %114   ; arrayPos
%70 = phi @entry, %67, @backedge, %115   ; length
%71 = phi @entry, %68, @backedge, %116   ; memPtr
%73 = phi @entry, %72, @backedge, %113   ; counter
```

The back-edge path should return operands in order: `[%114, %115, %116, %113]`

But due to `OrderedSet` behavior, the actual order was: `[%113, %116, %115, %114]`

This causes the assembler to compute incorrect DUP positions, leading to runtime errors.

### Reproduction
This issue manifests when:
1. A loop header has multiple phi nodes (4+ variables)
2. Some phi operands from the back-edge path are already in the liveness set from the entry path analysis
3. The order of phi operands from different paths does not match

### Fix
Modify `input_vars_from` to remove and re-add phi operands to force correct ordering:

```python
for label, var in inst.phi_operands:
    if label == source.label:
        # FIX: Remove and re-add to ensure phi operands are in
        # PHI DEFINITION ORDER. OrderedSet.add() doesn't reorder
        # existing elements, so we must remove first.
        # This is critical for nested loops where phi operands
        # may already be in liveness from previous iterations.
        if var in liveness:
            liveness.remove(var)
        liveness.add(var)
    else:
        if var in liveness:
            liveness.remove(var)
```

### Testing
- Verified fix doesn't break existing tests (simple loop still passes)
- Verified liveness now returns consistent ordering for both entry and back-edge paths

### Impact
This fix ensures stack layout consistency at basic blocks with multiple predecessor paths, which is essential for correct code generation in nested loop structures.

---

## Fix 2: Assign Instruction Stack Model Desync

### File
`vyper/venom/venom_to_assembly.py`

### Issue
Assign instructions (`%66 = %21`) were being processed through the normal instruction path which pops the source operand and pushes the destination. However, assigns are NOPs in EVM - no actual stack operations occur. This caused the stack model to become desynchronized from the physical EVM stack.

### Root Cause
The code generation for instructions follows this pattern:
1. Step 4: `stack.pop(len(operands))` then `stack.push(output)`
2. Step 5: Emit EVM instructions (for assign: `pass`)

For assign `%66 = %21`:
- Step 4 pops `%21` and pushes `%66`, moving `%66` to the top of the stack model
- Step 5 is a NOP - no actual EVM code emitted
- Physical EVM stack is unchanged (source value stays at its original depth)
- Stack model now thinks `%66` is at top, but physically it's still wherever `%21` was

This desync causes subsequent phi instructions to look for operands at wrong stack depths.

### Reproduction
This issue manifests in nested loops when:
1. Outer loop exit transitions to inner loop via assigns (blocks like `27_blk_loop_end`)
2. Assigns create aliases for outer-scope variables to become inner loop phi operands
3. The stack model shows correct variable names but wrong depths
4. Inner loop phi instructions compute incorrect DUP positions

Example IR:
```
27_blk_loop_end:
    %66 = %21       ; alias arrayPos
    %67 = %19       ; alias length  
    %68 = %51:1     ; alias memPtr
    %72 = 0         ; counter init
    jmp @30_blk_loop_start

30_blk_loop_start:
    %69:1 = phi @27_blk_loop_end, %66, ...  ; expects %66 at specific depth
```

### Fix
Handle assign as a special case BEFORE the normal pop+push path:

```python
if opcode == "assign":
    source = inst.operands[0]
    dest = inst.output
    
    if not isinstance(source, IRVariable):
        # Source is constant - let normal path handle (push constant)
        pass
    else:
        # Source is variable - rename in-place using poke (like phi does)
        depth = stack.get_depth(source)
        if depth is StackModel.NOT_IN_STACK:
            # Source already dead - push placeholder
            assembly.append("PUSH0")
            stack.push(dest)
        else:
            if source in next_liveness:
                # Source still needed - DUP then rename copy
                self.spiller.dup(assembly, stack, depth)
                stack.poke(0, dest)
            else:
                # Just rename the stack slot
                stack.poke(depth, dest)
        return apply_line_numbers(inst, assembly)
```

### Testing
- Verified nested loop test case now produces correct assembly
- Stack model correctly shows `[%66, %67, %68, %72]` instead of mismatched values
- Inner loop phis find operands at correct stack depths

### Impact
This fix ensures assign instructions keep the stack model synchronized with the physical EVM stack, which is essential for correct phi instruction code generation in nested loop structures where transition blocks use assigns to set up inner loop entry values.

---

## Additional Notes

### Transpiler Fixes (Not Backend Issues)

In addition to the liveness fix above, the following transpiler-level changes were made to work with Venom's optimization passes:

1. **Invariant phi nodes for nested loops**: Inner loops need phi nodes for outer-scope variables to ensure liveness correctly tracks them across the inner loop back-edge.

2. **Non-assign identity operations**: Using `add %var, 0` instead of `assign %var` for back-edge invariant values prevents `PhiEliminationPass` from collapsing multi-origin phis into single-origin phis. The phi elimination pass traces through assign chains but treats arithmetic operations as roots.

These are patterns required by how Venom's optimization passes work, not bugs in the backend itself.

---

## Transpiler Fix 3: Recursive Function Call Return Operand Order

**Date:** 2026-01-31  
**Status:** FIXED  
**File:** `venom_generator.py`

### Issue
Recursive function calls (using `invoke`/`ret`) caused `InvalidJump` errors at runtime. The `ret` instruction was not correctly returning to the caller's PC.

### Root Cause
The Venom parser reverses operands for most instructions (except `jmp`, `jnz`, `djmp`, `phi`). The `ret` instruction was not in the exclusion list, so its operands get reversed.

The transpiler generated:
```
ret result, pc    ; source order: [result, pc]
```

After parser reversal: `[pc, result]`

The backend uses `operands[-1]` to get the return PC, which returned `result` instead of `pc`.

### Fix
Changed the transpiler to generate `ret` with PC **first** so that after parser reversal, PC ends up **last** as the backend expects:

```python
# Before (wrong):
self.current_bb.append_instruction("ret", *ret_vals, self.var_map['$pc'])

# After (correct):
self.current_bb.append_instruction("ret", self.var_map['$pc'], *ret_vals)
```

### Key Insight
**Always prefer transpiler fixes over backend patches.** The backend is designed to work with native Vyper IR which builds `IRContext` directly without going through the text parser. The transpiler must account for the parser's operand reversal behavior.

### Testing
```bash
forge test --match-test "test_recursiveCall"  # PASS
```

### Impact
This fix enables proper recursive function calls between Yul functions using the `invoke`/`ret` pattern. Test count: 52 → 53 passing.

---

## Transpiler Fix 4: Invoke Instruction Output Capture

**Date:** 2026-01-31  
**Status:** FIXED  
**File:** `venom_generator.py`

### Issue
Recursive function calls using `invoke` did not capture return values. Functions that should return values were returning 0.

### Root Cause
The `invoke` opcode is in the `NO_OUTPUT_INSTRUCTIONS` set in `basicblock.py`:
```python
NO_OUTPUT_INSTRUCTIONS = frozenset([
    ...
    "invoke",  # invoke has multi-return handled specially
    ...
])
```

When `append_instruction` is called without an explicit `ret=` parameter, it checks if the opcode is in `NO_OUTPUT_INSTRUCTIONS`. If so, it returns `None` instead of auto-allocating an output variable.

The transpiler code was:
```python
ret = self.current_bb.append_instruction("invoke", IRLabel(func_name), *arg_vals)
result_vals = [ret] if ret else []  # ret is None!
```

### Fix
Explicitly allocate a return variable for functions that return values:

```python
f_def = self.functions_ast.get(func_name)
if f_def and f_def.returns:
    ret = self.current_fn.get_next_variable()
    self.current_bb.append_instruction("invoke", IRLabel(func_name), *arg_vals, ret=ret)
    result_vals = [ret]
else:
    self.current_bb.append_instruction("invoke", IRLabel(func_name), *arg_vals)
    result_vals = []
```

### Impact
Functions using `invoke` now correctly capture return values, enabling proper recursive call chains like `A → B → C → A`.

---

# Ongoing Investigations

---

## Investigation: LoopCheckCalldata `32 != 20` Bug

**Date:** 2026-01-30  
**Status:** IN PROGRESS  
**Test:** `LoopCheckCalldataTest::test_processStructs()`  
**Symptom:** Second struct returns `{id: 32, value: 2}` instead of `{id: 20, value: 201}`

### Root Cause Identification

The bug is in the **loop condition operand order**. The serialization loop condition computes `(length < i_1)` instead of `(i_1 < length)`.

---

### ✅ Confirmed Correct (Do NOT Re-Investigate)

#### 1. Memory Allocation and Layout
- **memPos** (return buffer): Address 704
- **memPtr** (source array): Address 480  
- **memPtr + 64** (second struct slot): Address 544
- **No overlap** between return buffer and source data
- **MemoryLayoutTest.t.sol** confirmed this - test passed

#### 2. Stack Reordering at JMP Instructions
- `_stack_reorder` in `venom_to_assembly.py` works correctly
- Both paths to loop header (initial entry and back-edge) produce consistent relative order
- Debug output confirmed:
  ```
  Initial entry: [%125, %131, %130, %128, %129]  (phi order: 1,2,3,4)
  Back-edge:     [%125, %146, %147, %148, %149]  (phi order: 1,2,3,4)
  ```

#### 3. Phi Node Structure
- Phi nodes are correctly defined in the IR
- Phi operand chains trace back to correct source values:
  - `srcPtr` chain: phi → add(memPtr, 32) ✓
  - `pos` chain: phi → add(memPos, 64) ✓
  - `i_1` chain: phi → 0 (initial), add(i_1, 1) (back-edge) ✓
  - `length` chain: phi → mload(memPtr) ✓

#### 4. Liveness Analysis Order
- `input_vars_from()` in `liveness.py` correctly returns phi operands in PHI DEFINITION ORDER
- The "FIX" comment (lines 116-120) addresses re-adding for proper ordering
- Both initial entry and back-edge paths return consistent relative order

#### 5. Loop Body Data Operations (First Iteration)
- `DUP1 MLOAD` correctly loads from srcPtr
- `DUP4 MSTORE` correctly stores to pos
- First struct `{id: 10, value: 101}` is correctly output

#### 6. Invariant Phi Removal (NOT the root cause)
- Tested removing loop invariant phis (matching native Vyper behavior)
- Test still failed with same `32 != 20` error
- **Reverted** this change - invariant phis are not the cause

---

### ❌ Confirmed Bug: Loop Condition Operand Order

#### The Problem

**IR Display:**
```
%380 = %133:1     ; length
%381 = %132:1     ; i_1  
%136 = lt %381, %380
```

**What This Actually Computes:**

1. Parser reverses operands for display (parser.py line 262-263)
2. Display `lt %381, %380` → Internal operands `[%380, %381]`
3. With "rightmost on top" convention: stack = `[..., %380, %381]` = `[..., length, i_1]`
4. i_1 is on top
5. EVM LT pops `[a=i_1, b=length]`, computes `(b < a)` = `(length < i_1)`

**Expected:** `i_1 < length`  
**Actual:** `length < i_1`

This causes the loop to exit on the SECOND iteration (when i_1=1, length=2):
- Expected: `1 < 2` = true → continue
- Actual: `2 < 1` = false → exit

#### Key Evidence

**Assembly at loop header (lines 328-331):**
```
LABEL 46_blk_loop_start
DUP3        ; gets position 3 = length (%133:1)
DUP5        ; gets position 5 = i_1 (after DUP3)
LT          ; computes (length < i_1) - WRONG!
```

**Stack after phi processing:**
```
Position 1 (top): %135:1 (srcPtr)
Position 2: %134:1 (pos)
Position 3: %133:1 (length)  ← DUP3 gets this
Position 4: %132:1 (i_1)     ← DUP5 gets this (after DUP3 pushes)
Position 5: %125 (memPos)
```

---

### 🔍 Still Under Investigation: 32 != 20 Serialization Loop Bug

**Status:** Root cause narrowed down to backend assign/DUP handling (Jan 31, 2026)

#### Symptom
Second element in serialized struct array returns incorrect data:
- Expected: `{id: 20, value: 201}`
- Actual: `{id: 32, value: 2}` (ABI header values)

Debug test output:
```
Word 0 : 32    ← ABI offset
Word 1 : 2     ← length
Word 2 : 10    ← id[0] ✓
Word 3 : 101   ← value[0] ✓
Word 4 : 32    ← id[1] ← WRONG! (should be 20)
Word 5 : 2     ← value[1] ← WRONG! (should be 201)
```

#### Investigation Findings (Jan 31, 2026)

##### Hypothesis 1: Loop Counter Increment Bug ❌ REJECTED
- Checked if loop 33 increments by 1 instead of 32
- **Finding:** Intentional! Counter increments by 1, pointer offset computed as `counter * 32` via `shl(5, counter)`
- Both population loop (33) and serialization loop (54) use unit-incrementing counters with 32-byte offset mapping

##### Hypothesis 2: Stack Order Mismatch at Phi ❌ REJECTED
- Checked liveness analysis vs assembly stack order
- **Finding:** Liveness correctly returns `['%31', '%21', '%19', '%counter']` (leftmost=deepest)
- Assembly DUP indices correctly access expected stack positions

##### Hypothesis 3: Incorrect DUP Index for GT Operands ❌ REJECTED
- Traced GT instruction: `gt(%19, counter)` = `gt(length, counter)`
- **Finding:** Assembly correctly does `DUP1, DUP3, GT` which computes `length > counter`
- EVM GT semantics verified: pops (a=top, b=second), pushes a > b

##### Hypothesis 4: srcPtr Not Updated in Serialization Loop ❌ REJECTED
- Traced loop body stack manipulations
- **Finding:** `PUSH1 32, ADD` correctly computes new srcPtr = srcPtr + 32
- Back-edge correctly sends `[new_srcPtr, new_pos, new_i, length, base]` to loop start

##### Hypothesis 5: Pointer at 0x1040 Contains Wrong Value ✓ CONFIRMED
- Debug output shows Words 4-5 identical to Words 0-1
- **Conclusion:** mload(srcPtr) on second iteration returns the same address as first iteration
- The pointer array slot at 0x1040 contains wrong value (output buffer base instead of struct[1] address)

##### Hypothesis 6: Backend Assign Handling Bug ✓ NARROWED DOWN
IR block `47_end_if` has:
```
%278 = %80           ; assign struct addr to alias
mstore %278, %69     ; store id
%280 = %80           ; assign struct addr to another alias
%86 = add %280, 32   ; compute offset for value
mstore %86, %77      ; store value
```

**Debug Output from Backend:**
```
DEBUG assign: %476 = %80
  depth=0, source_in_liveness=True
  stack_before: [..., %80]
  stack_after_dup_poke: [..., %80, %476]  ← %80 preserved!

DEBUG assign: %474 = %80
  depth=-1, source_in_liveness=True   ← depth=-1 means %80 one below top
  stack_before: [..., %80, %476]
  stack_after_dup_poke: [..., %80, %476, %474]  ← %80 still preserved!
```

Backend claim: Stack model shows correct DUP behavior, `%80` is preserved.

**But Generated Assembly Shows:**
```
LABEL 47_end_if
PUSH1 64
MSTORE        ; bump FMP - consumes top 2 values
DUP1          ; DUPs whatever is NOW on top (NOT %80!)
SWAP3 SWAP1
MSTORE        ; store id
PUSH1 32
DUP3          ; Gets WRONG value for struct addr + 32 computation
ADD
MSTORE        ; store value at WRONG address
```

**Root Cause:** The stack model claims `%80` is preserved via DUP, but the actual emitted assembly does NOT include the expected DUP instructions. There's a mismatch between what the backend's stack model thinks is happening and what's actually being emitted.

#### Memory Layout (Verified Correct)
```
0x1000: Input array base (length)
0x1020: Pointer[0] → should point to struct[0]
0x1040: Pointer[1] → should point to struct[1]
0x1060: Struct[0] allocated memory
0x10A0: Struct[1] allocated memory
0x10E0: Output buffer base
```

#### Next Steps

1. **Investigate Stack Model vs Assembly Mismatch:** Why does backend claim DUP happens but assembly shows no DUP?
2. **Check `_emit_input_operands`:** May not be emitting expected DUPs for consumed variables
3. **Trace Full Instruction Emission:** Add debug to see exact assembly emitted per IR instruction
4. **Consider IR Transform:** Pre-process assigns to explicit DUPs before backend codegen

#### Key Insight
The bug manifests because struct[1]'s pointer slot (0x1040) contains the output buffer base address (0x10E0) instead of struct[1]'s actual address (0x10A0). This happens because the `mstore` to store struct[1]'s pointer uses the wrong source value from the corrupted stack.

---

### Debug Logging Added

#### In `liveness.py` (`input_vars_from`):
```python
is_debug = "46_blk_loop" in target.label.value or "blk_loop_start" in target.label.value
if is_debug:
    print(f"DEBUG input_vars_from: {source.label.value} -> {target.label.value}")
    print(f"  Initial liveness: {list(liveness)}")
    # ... after each phi ...
    print(f"  After phi {inst.output}: added {var}, liveness now: {list(liveness)}")
    print(f"  Final liveness order: {list(liveness)}")
```

#### In `venom_to_assembly.py` (JMP reorder):
```python
is_debug = "46_blk_loop" in next_bb.label.value or "blk_loop_start" in next_bb.label.value
if is_debug:
    print(f"DEBUG JMP reorder: {inst.parent.label.value} -> {next_bb.label.value}")
    print(f"  Current stack: {stack._stack}")
    print(f"  Target order: {list(target_stack)}")
    print(f"  After reorder: {stack._stack}")
```

---

### Files Modified (Debug Only)

| File | Lines | Purpose |
|------|-------|---------|
| `vyper/venom/analysis/liveness.py` | 98-140 | Debug logging for input_vars_from |
| `vyper/venom/venom_to_assembly.py` | 639-650 | Debug logging for JMP stack reorder |

---

### Next Steps

1. **Verify generator operand order:** Check if `append_instruction1("lt", i_1, length)` produces the correct internal operand order
2. **Test operand swap fix:** Try swapping lt/gt operand order in venom_generator.py
3. **Compare with native Vyper:** Generate native Vyper IR for equivalent loop and compare operand order

---

### Key Files Reference

| File | Purpose |
|------|---------|
| `venom_generator.py:1597` | Where `lt`/`gt` instructions are generated |
| `vyper/venom/parser.py:262-263` | Operand reversal during parsing |
| `vyper/venom/basicblock.py:231` | "Rightmost on top" convention |
| `vyper/venom/basicblock.py:467-468` | Print reversal for display |
| `vyper/venom/venom_to_assembly.py:626-650` | JMP stack reorder logic |
| `vyper/venom/analysis/liveness.py:96-128` | `input_vars_from` for stack order |

---

### Test Commands

```bash
# Run transpile
python3.11 yul2venom.py transpile configs/LoopCheckCalldata.yul2venom.json

# Run test
forge test --match-contract "LoopCheckCalldata" -vvv

# View IR
cat yul2venom/debug/opt_ir.vnm | grep -A10 "46_blk_loop_start:"

# View assembly
grep -A10 "LABEL 46_blk_loop_start" yul2venom/debug/assembly.asm
```
