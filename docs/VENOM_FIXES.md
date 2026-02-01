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

**Date:** 2026-01-30 to 2026-01-31  
**Status:** IN PROGRESS - ROOT CAUSE NARROWED  
**Test:** `LoopCheckCalldataTest::test_processStructs()`  
**Symptom:** Second struct returns `{id: 32, value: 2}` instead of `{id: 20, value: 201}`

---

#### 🎯 Key Finding: Values Match Return Buffer Header

The incorrect output `{id: 32, value: 2}` **exactly matches** the return buffer ABI header:
- `32` = ABI offset stored at return buffer start (`mstore %114, 32`)
- `2` = Array length stored at return buffer + 32 (`mstore %115, %116`)

**Conclusion**: `array[1]` pointer slot contains the return buffer address instead of `struct_1` pointer.

---

#### ✅ Definitively Ruled Out (Jan 31, 2026)

| Component | Status | Evidence |
|-----------|--------|----------|
| **Optimizer passes** | ✅ Ruled out | Bug persists with `-O none` (zero passes) |
| **Serialization loop IR** | ✅ Correct | Phi handling verified, SSA chains traced |
| **Serialization stack models** | ✅ Correct | Entry/exit values match phi expectations |
| **Serialization assembly** | ✅ Correct | Stack evolution: `[srcPtr+32, pos+64, ctr+1, len, memPos]` ✓ |
| **Population loop increment** | ✅ Correct | `%113 = add %66:1, 1` verified |
| **FMP sequence** | ✅ Correct | `mstore 64` in block 47 before jump to block 33 |
| **srcPtr initialization** | ✅ Correct | `%118 = add %32, 32` = outputArray + 32 |
| **Liveness phi fix** | ✅ In place | Lines 116-123 in liveness.py |
| **Assign stack fix** | ✅ In place | Lines 570-602 in venom_to_assembly.py |

---

#### 🔬 Exhaustive Verification Details

##### Stack Model Trace (Serialization Loop)

**Block 54 (Loop Header) Entry:**
```
Stack: [%114, %116, %119, %121, %123]
       memPos  len   ctr   pos  srcPtr
```

**Block 55 (Loop Body) Entry (after phi):**
```
Stack: [%114, %116, %120:1, %122:1, %124:1]
                    ctr     pos    srcPtr (phi outputs)
```

**Block 55 Exit:**
```
Stack: [%114, %116, %135, %136, %137]
                   newCtr newPos newSrcPtr
```

All values are in correct positions for back-edge phi.

##### Assembly Trace (Block 55 - Serialization Loop Body)

```asm
LABEL 55_blk_loop_body
DUP1            ; [srcPtr, srcPtr, pos, ctr, len, memPos]
MLOAD           ; [struct_ptr, srcPtr, pos, ctr, len, memPos]
DUP1            ; [struct_ptr, struct_ptr, srcPtr, pos, ctr, len, memPos]
MLOAD           ; [struct.id, struct_ptr, srcPtr, pos, ctr, len, memPos]
DUP4            ; Gets pos (correct)
MSTORE          ; mstore(pos, struct.id)
PUSH1 32
ADD             ; [struct_ptr+32, srcPtr, pos, ctr, len, memPos]
MLOAD           ; [struct.value, srcPtr, pos, ctr, len, memPos]
PUSH1 32
DUP4            ; Gets pos (correct)
ADD
MSTORE          ; mstore(pos+32, struct.value)
; ... compute new srcPtr, pos, ctr ...
JUMP @54        ; Back-edge with correct stack order
```

---

#### 🎯 Suspected Root Cause: Population Loop Struct Pointer Storage

Since serialization is verified correct, the bug must be in how `struct_1`'s pointer gets stored in `array[1]` during the **population loop**.

**Key IR (Population Loop - Block 48):**
```venom
48_inline_cleanup_memory_array_index_access_struct_Element_dyn:
    mstore %103, %94    ; Store struct ptr at array[i]
```

Where:
- `%103 = %32 + 32 + i*32` = array slot address (correct)
- `%94 = allocate_memory()` = struct pointer (should be fresh each iteration)

**Hypothesis**: `%94` may be incorrect in iteration 1 due to:
1. Stack corruption during population loop
2. FMP value not correctly read/updated between iterations
3. Backend emitting wrong DUP index for struct pointer retrieval

---

#### 📊 Memory Layout (Verified)

```
Population phase writes:
  array[0] @ %32+32:  ptr → struct_0 @ freshFMP_iter0 → {10, 101}
  array[1] @ %32+64:  ptr → struct_1 @ freshFMP_iter1 → {20, 201}  ← SHOULD BE

Serialization phase reads:
  srcPtr(%32+32):  mload → ptr_to_struct_0 → {10, 101} ✓
  srcPtr(%32+64):  mload → WRONG VALUE → {32, 2} ✗

Return buffer @ %114:
  +0:   32 (ABI offset)
  +32:  2 (length)
```

**If array[1] contains %114 (return buffer address):**
- `mload(%114)` = 32 (ABI offset)  
- `mload(%114+32)` = 2 (length)

This matches the observed output exactly!

---

#### 🔧 Status Update (Jan 31, 2026 - continued)

**New Test Results with Variable Iteration Counts:**
| Elements | Result | Gas | Notes |
|----------|--------|-----|-------|
| 0 | ✅ PASS | 7192 | Loop never executes |
| 1 | ❌ OOG | 1056944009 | **Infinite loop** - `InvalidOperandOOG` |
| 2 | ❌ FAIL | 13204 | `32 != 20` assertion |
| 3 | ❌ FAIL | 14414 | `32 != 20` assertion |

**Critical Insight:** The 1-element case causes an *infinite loop* (different failure mode than 2+ elements), suggesting:
- Counter never increments past 0, OR
- GT condition always evaluates to true despite correct counter value

**Stack Model Verification (Confirmed Correct):**
- Block 33 (loop header): Stack correctly shows `[%32, %21, %19, %66:1]` after phi, with proper DUP/GT sequence
- Block 53 (back-edge): Counter incremented via `%113 = %66:1 + 1`, stack correctly shows `[%32, %21, %19, %113]` before jmp
- Block 36 (loop exit): `clean_stack_from_cfg_in` correctly identifies 4 variables to pop: `['%21', '%19', '%66:1', '%67']`

**Next Investigative Steps:**
1. **Use Foundry interactive debugger** (`forge test --debug`) to step through EVM execution
2. **Trace actual stack values** during runtime to find where model diverges from reality
3. **Examine loop body blocks (34→39→42→44→47→48→53)** for stack-corrupting operations
4. **Compare runtime stack depth** at loop header on first vs second iteration

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

---

## Fix 6: FMP Initialization Operand Order (Generator Bug)

### File
`venom_generator.py`

### Issue
The Free Memory Pointer (FMP) was not being initialized correctly, causing array allocations to start at address 0x0 instead of 0x1000. This led to memory corruption where struct data overwrote the array length, causing infinite loops in serialization code.

### Symptoms
- 1-element array tests resulted in infinite loops (OOG)
- 2+ element tests failed with assertion errors (e.g., `32 != 20`)
- Array length (stored at address 0) was overwritten by struct id values

### Root Cause
The FMP initialization `mstore` had swapped operands:

```python
# WRONG: mstore(address=0x1000, value=64)
self.current_bb.append_instruction("mstore", IRLiteral(0x1000), IRLiteral(64))

# CORRECT: mstore(address=64, value=0x1000)  
self.current_bb.append_instruction("mstore", IRLiteral(YUL_FMP_SLOT), IRLiteral(VENOM_MEMORY_START))
```

This stored value 64 at address 0x1000 instead of storing value 0x1000 at address 64 (the FMP slot).

### Fix
Corrected the operand order and refactored to use constants from `utils/constants.py`:

```python
from utils.constants import VENOM_MEMORY_START, YUL_FMP_SLOT

# Initialize FMP: store 0x1000 at address 0x40
self.current_bb.append_instruction("mstore", IRLiteral(YUL_FMP_SLOT), IRLiteral(VENOM_MEMORY_START))
```

### Testing
All 4 LoopCheckCalldata tests now pass:
- 0 elements: PASS
- 1 element: PASS (was: OOG infinite loop)
- 2 elements: PASS (was: 32 != 20 assertion)
- 3 elements: PASS (was: 32 != 20 assertion)

### Impact
This was a critical bug that caused memory corruption in any contract using dynamic memory allocation (arrays, structs). The fix ensures Yul's dynamic allocations start at address 0x1000, above Venom's reserved region.

---

## Fix 7: Log Instruction Effects Registration

**Date:** 2026-02-01  
**Status:** FIXED  
**File:** `vyper/vyper/venom/effects.py`

### Issue
Event emission (`log1`, `log2`, etc.) returned all-zero data. The optimizer was reordering `mstore` and `log1` instructions, causing `log1` to read uninitialized memory.

### Root Cause
The effects system only registered the generic `"log"` opcode but not the specific `log0`-`log4` opcodes used in actual IR:

```python
# effects.py only had:
_writes = { "log": LOG, ... }
_reads = { "log": MEMORY, ... }

# But IR uses specific opcodes:
log1 %ptr, 32, 0x12d199...
```

Without effects registration, the optimizer treated `log1` as having no memory dependencies. It reordered:

```venom
# Correct order (raw IR):
mstore %154, %155    ; Store value to memory
log1 %154, 32, topic ; Emit log reading from %154

# Incorrect order (optimized IR):
log1 %154, 32, topic ; Emit log BEFORE value stored!
mstore %154, %155    ; Value stored AFTER log emitted
```

### Fix
Added `log0`-`log4` to both `_reads` and `_writes` dictionaries:

```python
_writes = {
    ...
    "log": LOG,
    "log0": LOG,
    "log1": LOG,
    "log2": LOG,
    "log3": LOG,
    "log4": LOG,
    ...
}

_reads = {
    ...
    "log": MEMORY,
    "log0": MEMORY,
    "log1": MEMORY,
    "log2": MEMORY,
    "log3": MEMORY,
    "log4": MEMORY,
    ...
}
```

### Testing
All Events tests now pass:
- `test_emitSimple()`: PASS (was FAIL: got 0 instead of 42)
- `test_emitIndexed()`: PASS
- `test_emitBytes()`: PASS
- `test_emitString()`: PASS
- `test_emitComplex()`: PASS
- `test_emitMultiIndexed()`: PASS
- `test_emitMultiple()`: PASS

### Impact
This fix ensures the optimizer respects memory dependencies for all log instructions, preventing incorrect instruction reordering. Test count: 100 → 105 passing.

---

## Optimization 1: Assign for Literals

**Date:** 2026-02-01  
**Status:** IMPLEMENTED  
**File:** `venom_generator.py`

### Change
Modified `_materialize_literal` to use `assign` for IRLiterals instead of `add val, 0`.

### Rationale
- `assign` instructions are eliminated by `AssignElimPass`
- `add val, 0` generates 3 extra bytes and 3 gas per use
- Literals don't have the liveness issues that require the `add 0` workaround

### Before
```python
block.append_instruction("add", val, IRLiteral(0), outputs=[new_var])
```

### After
```python
if isinstance(val, IRVariable):
    # Variables still need add x,0 for DUP handling
    block.append_instruction("add", val, IRLiteral(0), outputs=[new_var])
else:
    # Literals use assign (eliminated by AssignElimPass)
    block.append_instruction("assign", val, outputs=[new_var])
```

### Impact
~1% bytecode reduction across benchmark contracts.

---

## Fix 8: Fallback/Receive Function Support

**Date:** 2026-02-01  
**Status:** FIXED  
**File:** `venom_generator.py`

### Issue
Contracts with `fallback()` or `receive()` functions reverted on unknown selectors instead of executing the fallback code.

### Root Cause
The transpiler's selector dispatch was incorrectly emitting `revert 0, 0` in the fallback block when no default case existed in the switch statement. However, Solidity's fallback/receive code appears **after** the switch statement as sibling statements, not as a `default` case.

```yul
// Yul pattern for contracts with fallback:
switch selector
    case 0x... { ... }
    case 0x... { ... }
// END of switch
if iszero(calldatasize()) { stop() }  // receive
stop()                                 // fallback
```

The transpiler was terminating the fallback block with `revert` instead of flowing to the post-switch statements.

### Fix
Removed automatic `revert` insertion in fallback blocks. The fallback block now flows to the switch end, where post-switch statements (or implicit function termination) handle the fallback behavior:

```python
# Before (bug):
if not self.inline_exit_stack and default_case is None:
    self.current_bb.append_instruction("revert", zero, zero)

# After (fix):
# DON'T revert - let post-switch statements handle fallback behavior
# (e.g., Solidity's fallback() or receive() functions)
```

### Testing
- `test_fallback()`: PASS (was FAIL)
- All 106 bench tests: PASS

### Impact
Enables proper support for Solidity contracts with `fallback()` and `receive()` functions. Test count: 105 → 106 passing.

