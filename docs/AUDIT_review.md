# AUDIT Review (living document)

This document is updated **one claim at a time**. Each entry includes:
- Claim (source audit)
- Assessment: Confirmed / Not confirmed
- Evidence with code examples
- Suggested fix (where/how) with a minimal code sketch

## Structure (reorganized)
To keep the doc “living” and audit‑friendly, the detailed claim bodies remain in their original order below.  
This **header section** adds: (1) root‑cause chain, (2) prioritized fixes, (3) status index by category.

### Root‑cause chain (GuardedTrader)
**A0‑15 (VNM operand order mismatch)** → **A1‑7 (SHR wrong at runtime)** → **var_path = 0** → **empty array** → **Panic(0x32)**.  
This chain explains the failure without invoking cross‑object resolution or dispatcher errors.

### Fix order (must‑fix first)
**P0**
- **A0‑15** VNM operand order mismatch (breaks non‑commutative ops, causes SHR reversal)

**P1**
- **A2‑2** Multi‑return invoke in expression context drops outputs (stack corruption risk)
- **A2‑1** AssertOptimizer drops custom error revert data (semantic break)
- **A2‑5** allocate_memory only safe in `let` (expression use can clobber pointer)

**P2 (API/tooling correctness)**
- **U2** core/__init__.py imports missing pipeline module
- **U3** backend exposes CLI only; no programmatic run_venom_backend

### Status index (by category)
**Confirmed defects (runtime correctness)**
- A0‑15, A2‑2, A2‑1, A2‑5

**Confirmed manifestation / root‑cause signal**
- A1‑7 (SHR wrong at runtime; manifestation of A0‑15)

**Confirmed API/tooling defects**
- U2, U3

**Partially confirmed / latent risks**
- A0‑14, A2‑4, A2‑6

**Symptom‑only (downstream effects, not root cause)**
- A0‑4, A1‑2, A1‑3

**Not confirmed / needs evidence**
- A0‑1, A0‑2, A0‑3, A0‑5, A0‑8, A0‑9, A0‑10, A0‑11, A0‑12, A0‑13  
- A1‑1, A1‑4, A1‑5, A1‑6, A1‑8  
- A2‑3, U1

**Meta**
- A2‑0 (AUDIT_2 was empty at time of review; no claims)

---

## Claim A0-1: Dynamic selector dispatch misroutes 0x00000000 to callback
**Source:** `AUDIT_0.md` – "Dynamic Selector Dispatch Bug"

**Assessment:** **Not confirmed**

**Evidence / reasoning**
1) The transpiled runtime does reach the fallback path and performs the expected calldata-driven allocations before the panic. In the trace, execution reaches the fallback allocation/bitmask path (e.g. `PC=07f8 MSTORE(0x100, 0x0)` and later `PC=083d MSTORE(0x140, 0x160)`), which is consistent with the fallback body rather than a direct callback entry. The panic is triggered after a length-0 array is constructed, not from an immediate selector misroute.

2) The Yul switch lowering in the transpiler emits **explicit selector checks** even in hash-bucket mode. In `generator/venom_generator.py`, the bucket handlers use:
```
xor_result = xor(expected, selector)
jnz xor_result, fallback, handler
```
This ensures that a wrong selector (including `0x00000000`) hashing into a bucket still falls through to fallback. The code path exists in both the single-selector and multi-selector buckets.

**Code reference**
- `yul2venom/generator/venom_generator.py` (switch → bucket handlers)
  - Generates `xor` + `jnz` checks per selector, with `fallback_lbl` used on mismatch.

**Suggested fix (if this resurfaces)**
If any evidence later shows misrouting, tighten the switch lowering to **always** include a fallback branch, even for a bucket with a single selector, and verify table indexing:

```python
# generator/venom_generator.py (switch dispatch)
# Ensure each bucket handler ends with:
xor_result = self.current_bb.append_instruction1("xor", expected_sel, local_sel)
self.current_bb.append_instruction("jnz", xor_result, fallback_lbl, handler_lbl)
```

**Follow-up test**
Add a minimal regression test where the selector is `0x00000000` and the contract has at least one real selector in the same bucket. Assert that the fallback executes (not a callback).

---

## Claim A0-2: Fallback vs. Callback branch mis-evaluates IN_SWAP_SLOT
**Source:** `AUDIT_0.md` – "Fallback vs. Callback Branch Logic Error"

**Assessment:** **Not confirmed**

**Evidence / reasoning**
1) In the GuardedTrader optimized Yul, the fallback explicitly branches on `eq(origin(), caller())` and then performs the calldata‑bitmask path:
```
function fun_fallback() {
  if eq(origin(), caller()) { ... let usr$bitmask := calldataload(0) ... }
}
```
The failing trace executes the `usr$bitmask` logic (e.g. `shr 0x8a`, `shr 0x90`) and then allocates path memory. That is consistent with the **EOA branch** being taken, not the callback branch.

2) The panic occurs after `mstore(memPtr_1, var_path)` with `var_path == 0` and then `memory_array_index_access_*` on a zero-length array. That indicates **bad bitmask extraction** rather than `IN_SWAP_SLOT` being read as true.

**Code reference**
- `onchain-trader/output/GuardedTrader_opt.yul` (fallback body near the `origin()/caller()` check; `usr$bitmask` decoding at lines ~1954–1985).

**Suggested fix (if this ever reproduces)**
If a mis‑evaluation of `tload(IN_SWAP_SLOT)` is observed in traces, fix the **stack/liveness handling** around `assign` and `jnz` in the Venom backend so the conditional operand is preserved:

```python
# vyper/venom/venom_to_assembly.py
# Ensure the value used by JUMPI/retaining branches is duplicated
# when it's still live at the branch boundary.
if source in next_liveness:
    self.spiller.dup(assembly, stack, depth)
    stack.poke(0, dest)
```

And add a runtime test: EOA call should follow trade path; reentrant callback should follow callback path. A minimal harness can toggle `IN_SWAP_SLOT` via tstore/tload and assert the branch taken.

---

## Claim A0-3: Stack liveness/dup bug corrupts branch condition
**Source:** `AUDIT_0.md` – "Stack Liveness/Spill Issue"

**Assessment:** **Not confirmed (as root cause for GuardedTrader panic)**

**Evidence / reasoning**
1) The failing trace shows the EOA fallback path executing and then constructing a zero‑length array because `var_path` is 0. That indicates **bitmask extraction is wrong** (bad `shr` result), not a liveness‑based corruption of `IN_SWAP_SLOT`.

2) The Vyper fork *does* contain an `assign` liveness workaround (special‑case in `venom_to_assembly.py`), which implies this class of issue exists, but there is no direct evidence it flips the fallback/callback branch in this specific failure.

**Code reference**
- `vyper/vyper/venom/venom_to_assembly.py` (fork patch: assign handling)
- Trace: `PC=07f8 MSTORE(0x100, 0x0)` where the `shr(144, usr$bitmask)` result is zero.

**Suggested fix (general hardening)**
Reduce reliance on `assign` as a stack‑renaming primitive in the transpiler, and enforce unique operands:

```python
# generator/venom_generator.py
# Replace assign-based materialization with add(x,0) to force DUP-safe semantics.
temp = self.current_bb.append_instruction("add", val, IRLiteral(0))
```

And/or make backend liveness use **current instruction** liveness when deciding to `dup` values that are consumed by a branch:

```python
# vyper/venom/venom_to_assembly.py
# if source is still live at the branch boundary, dup before assign/consume
if source in next_liveness:
    self.spiller.dup(assembly, stack, depth)
```

**Follow-up test**
Create a minimal Venom IR that uses `assign` for a branch condition and verify that the branch outcome is stable across optimization levels.

---

## Claim A0-4: ABI data misinterpretation triggers Panic(0x32)
**Source:** `AUDIT_0.md` – "ABI Data Misinterpretation"

**Assessment:** **Partially confirmed (symptom), but not root cause**

**Evidence / reasoning**
1) The panic is an **array bounds check** on a zero‑length array (`mload(baseRef)==0`) inside `memory_array_index_access_struct_Data_dyn_*`. This implies the path array was decoded/constructed with length 0.

2) In the transpiled fallback path, `var_path` is derived from the calldata bitmask:
```
let usr$bitmask := calldataload(0)
let var_path := and(shr(138, usr$bitmask), 15)
mstore(memPtr_1, var_path)
```
If `shr` is wrong (operand order in SHR), `var_path` becomes 0 even for valid calldata. That leads to an **empty array**, and then the first index access panics.  
This matches the symptom but points to **bitmask decode** as the root cause rather than a wrong ABI layout.

**Code reference**
- `onchain-trader/output/GuardedTrader_opt.yul` (fallback; lines ~1979–1985 and ~1993–2003).
- Trace showing `mstore(0x160, 0x0)` and then `mload(0x160)==0`.

**Suggested fix**
Fix operand order for `shr` in Venom IR emission or backend stack scheduling so bitmask decode is correct:

```python
# venom_generator.py (intrinsic emission)
# Ensure SHR operands are emitted as (shift, value)
return self.current_bb.append_instruction1("shr", shift, value)
```

Then verify in VNM that `shr 144, %usr$bitmask` is preserved (not reversed) all the way to assembly.

**Follow-up test**
Add a micro‑test: compile a tiny Yul snippet containing `shr(144, calldataload(0))`, run on known calldata, and assert the result matches Solidity.

---

## Claim A0-5: Memory layout misalignment (FMP/spill) corrupts data
**Source:** `AUDIT_0.md` – "Memory Layout Misalignment"

**Assessment:** **Not confirmed**

**Evidence / reasoning**
1) The trace shows **FMP initialized to 0x100** at runtime entry (`PC=0005 MSTORE(0x40, 0x100)`), which matches the transpiler’s chosen `VENOM_MEMORY_START = 0x100`. This is consistent with the intended “Venom region” split and does not by itself explain the bitmask decode error.

2) The panic occurs due to a zero length at `0x160` after explicit `mstore(memPtr_1, var_path)` with `var_path==0`. That is *logical* data, not random corruption from a spill region. No evidence of overwriting that slot from the spill allocator appears in the trace.

**Code reference**
- `yul2venom/utils/constants.py` (VENOM_MEMORY_START = 0x100)
- Runtime trace: `PC=0005 MSTORE(0x40, 0x100)` and `PC=0813 MSTORE(0x160, 0x0)`.

**Suggested fix (general hardening)**
If spill corruption is observed in other cases, move spills far away from Yul heap and set FMP accordingly:

```python
# utils/constants.py
VENOM_MEMORY_START = 0x4000
SPILL_OFFSET = 0x4000
```

and ensure the runtime prologue sets `mstore(0x40, VENOM_MEMORY_START)` exactly once.

**Follow-up test**
Instrument a contract that does large dynamic allocations and stack spills; validate that memory between `0x80` and `VENOM_MEMORY_START` stays untouched (except scratch).

---

## Claim A1-1: Dispatcher misroutes EOA call into callback path
**Source:** `AUDIT_1.md` – "Dispatcher Branch Routing Failure (EOA vs Callback)"

**Assessment:** **Not confirmed**

**Evidence / reasoning**
1) The failing trace executes the **EOA branch** logic: it reads `usr$bitmask := calldataload(0)` and performs bitmask shifts (`shr 0x8a`, `shr 0x90`) before allocating the path array. Those operations are specific to the EOA fallback path in the Yul.

2) The panic arises from a zero `var_path` value, not from entering a callback‑specific decode path. This indicates the bitmask decode itself is wrong, not that the dispatcher skipped the EOA branch.

**Code reference**
- `onchain-trader/output/GuardedTrader_opt.yul` (EOA branch in `fun_fallback()` around lines ~1979–2003).
- Trace: `PC=07f8 MSTORE(0x100, 0x0)` followed by `PC=0813 MSTORE(0x160, 0x0)`.

**Suggested fix (if misrouting is later proven)**
Add explicit `return`/`stop` in the EOA branch to prevent any fallthrough even if inlining occurs:

```yul
if eq(origin(), caller()) {
    // trade path
    trade(...)
    stop()   // hard stop to prevent fallthrough
}
```

And in the transpiler, ensure inlined `trade()` emits a terminator when used as a top‑level branch body.

**Follow-up test**
Craft a minimal contract that mirrors the fallback/callback structure and verify via trace that EOA calls never execute callback code.

---

## Claim A1-2: “Ghost” array / uninitialized memory causes Panic(0x32)
**Source:** `AUDIT_1.md` – "Ghost Array and Uninitialized Memory Panic"

**Assessment:** **Partially confirmed (symptom), but not root cause**

**Evidence / reasoning**
1) The panic is triggered by `memory_array_index_access_*` on a baseRef whose length is zero (`mload(baseRef)==0`). This is consistent with an **empty array** (a “ghost array”).

2) The Yul shows that array length is written from `var_path`:
```
mstore(memPtr_1, var_path)
```
When `var_path` is zero (due to incorrect `shr` decoding), the array is **legitimately length 0**. That’s not an uninitialized pointer; it’s a valid but empty array. The out‑of‑bounds happens because code immediately indexes `[0]`.

So the “ghost array” symptom is real, but it is produced by the **bitmask decode bug**, not by skipping allocation or by using a null pointer.

**Code reference**
- `onchain-trader/output/GuardedTrader_opt.yul` lines ~1993–2003 (array allocation and `mstore(memPtr_1, var_path)`).
- Trace: `PC=0813 MSTORE(0x160, 0x0)` followed by bounds‑check panic.

**Suggested fix**
Fix the bitmask decode (operand order for `shr`) so `var_path` is correct. Additionally, add a guard to avoid indexing empty arrays:

```yul
if iszero(mload(memPtr_1)) { revert(0,0) }
// or handle empty path as a no‑op / error
```

**Follow-up test**
Add a unit test where `var_path == 0` and ensure the contract returns a **custom error** rather than a panic.

---

## Claim A1-3: Memory flow / population errors (array not filled)
**Source:** `AUDIT_1.md` – "Memory Flow and Population Errors"

**Assessment:** **Partially confirmed (symptom), but not root cause**

**Evidence / reasoning**
1) The observed memory region for the path array is zeroed because the path length is zero, not because the allocation/copy loop failed. In the Yul, the loop bounds for filling the array use `var_path` as length. If `var_path == 0`, the loop body is skipped by design.

2) The execution trace shows `mstore(memPtr_1, var_path)` followed by `mstore` of element pointers inside a loop. The loop is skipped because `_5` is derived from `array_allocation_size_array_struct_Data_dyn(var_path)` and `var_path` is zero. That matches “no population” as a downstream effect.

**Code reference**
- `onchain-trader/output/GuardedTrader_opt.yul` lines ~1993–2003:
  - `let _5 := add(array_allocation_size_array_struct_Data_dyn(var_path), not(31))`
  - loop `for { } lt(i, _5) ... { mstore(add(add(memPtr_1, i), 32), allocate_and_zero_memory_struct_struct_Data()) }`

**Suggested fix**
Fix the upstream bitmask decode. If you want additional safety, add explicit checks before using `var_path`:

```yul
if iszero(var_path) { revert(0,0) }  // or return a custom error
```

**Follow-up test**
Run with `var_path` set to a valid nonzero value and verify the loop populates element pointers (e.g., by tracing the `mstore` at `memPtr_1 + 32`).

---

## Claim A1-4: Function deduplication / label merging misroutes control flow
**Source:** `AUDIT_1.md` – "Function Deduplication and Label Merging Risks"

**Assessment:** **Not confirmed**

**Evidence / reasoning**
1) In `GuardedTrader_opt.yul`, functions are unique within each object; the transpiler **sanitizes** names but does not deduplicate functions across objects. A scan of GuardedTrader_150_deployed shows no collisions after sanitization.

2) The runtime panic is explained by incorrect `shr` operand order, not by a wrong function call target. The trace jumps to the bounds‑check helper after a zero‑length array is constructed, which is expected behavior.

**Code reference**
- `yul2venom/generator/venom_generator.py`: `sanitize()` and function emission.
- Local scan: no function name collisions within `GuardedTrader_150_deployed` after sanitization.

**Suggested fix (if this ever appears)**
If cross‑object symbol collisions are observed, namespace functions by object and enforce a global prefix:

```python
# venom_generator.py
fname = f\"{object_name}_{self.sanitize(f_def.name)}\"
```

And only allow jumps within the current object’s namespace.

**Follow-up test**
Construct two objects with identical helper function names and assert that their emitted labels are distinct and calls remain local.

---

## Claim A1-5: Stack and allocation pointer handling corrupts values
**Source:** `AUDIT_1.md` – "Stack and Allocation Handling"

**Assessment:** **Not confirmed (for GuardedTrader), but plausible elsewhere**

**Evidence / reasoning**
1) In the GuardedTrader trace, FMP is updated cleanly (0x100 → 0x160 → 0x180), and the pointer used for the array is derived via `mload(0x40)` then stored and reused. There is no evidence of pointer loss between `mload(0x40)` and subsequent `mstore(memPtr_1, var_path)`.

2) However, the transpiler contains special‑case logic for `allocate_memory` that explicitly warns about pointer loss due to stack manipulation. This indicates known fragility:
```
# venom_generator.py
# Use add(x,0) to force DUP handling
```

So the class of issue is real in the codebase, just not evidenced in this particular panic.

**Code reference**
- `yul2venom/generator/venom_generator.py` (allocate_memory special case; `_materialize_literal` uses add/assign to preserve stack semantics).

**Suggested fix**
Generalize the “allocate_memory preservation” to all calls returning pointers, and avoid assign for pointer materialization:

```python
# After any call returning a pointer used later:
preserved = self.current_bb.append_instruction("add", ret_ptr, IRLiteral(0))
```

**Follow-up test**
Create a Yul snippet that allocates memory then immediately uses the pointer after several stack‑heavy ops; verify pointer remains valid in generated bytecode.

---

## Claim A1-6: Optimizer removed critical bounds checks (panic 0x32)
**Source:** `AUDIT_1.md` – "Optimization/Deduplication Oversights"

**Assessment:** **Not confirmed**

**Evidence / reasoning**
1) The panic **did occur**, which implies bounds checks were **not removed** in this build. If the optimizer had stripped the panic checks, we would see out‑of‑bounds memory reads without the Panic(0x32) revert.

2) The configuration in this case used safe/standard optimization (per config), which is intended to preserve bounds checks. The Yul shows the explicit panic code emitted in the array access helper.

**Code reference**
- `onchain-trader/output/GuardedTrader_opt.yul` (helper `memory_array_index_access_*` contains the panic sequence).

**Suggested fix (guardrails)**
Make optimizer level explicit in `yul2venom.py` output and refuse to run “maximum” without an explicit `--unsafe` flag:

```python
if level == OptimizationLevel.MAXIMUM and not args.unsafe:
    raise RuntimeError("Maximum optimization is unsafe; pass --unsafe to continue")
```

**Follow-up test**
Compile the same Yul at safe vs maximum and assert that the panic helper still exists in safe mode.

---

## Claim A1-7: Bitmask decode uses wrong SHR operand order (root cause)
**Source:** `AUDIT_0.md` + direct trace analysis (not explicitly stated in audits)

**Assessment:** **Confirmed**

**Evidence / reasoning**
1) The fallback path computes:
```
usr$bitmask := calldataload(0)
var_path := and(shr(138, usr$bitmask), 15)
```
Given your calldata, `var_path` should be 2, not 0. But in trace, `mstore(0x160, 0x0)` is observed, showing `var_path==0`.

2) The trace shows `mstore(memPtr, shr(144, usr$bitmask))` results in **0** at `PC=07f8`. That should be `0x751f5612` for your calldata. This indicates `shr` is receiving operands in the **wrong order** at runtime (shift and value swapped).

3) Therefore, the length field is computed from a bad decode, leading to a valid but empty array and an immediate bounds‑check panic on index 0.

**Code reference**
- `onchain-trader/output/GuardedTrader_opt.yul`: `var_path := and(shr(138, usr$bitmask), 15)`
- Runtime trace: `PC=07f8 MSTORE(0x100, 0x0)` and `PC=0813 MSTORE(0x160, 0x0)`

**Suggested fix**
Ensure `shr` operand order is preserved end‑to‑end:

1) **IR emission**: always emit `shr(shift, value)` in that order.
2) **Backend**: avoid reversing operands for non‑jmp ops if the IR already reflects EVM order.

Concrete fix sketch (choose one direction):

```python
# Option A: fix frontend — always emit operands in EVM order
# shr expects [shift, value] in IR (top-of-stack is first operand)
return self.current_bb.append_instruction1("shr", shift, value)
```

```python
# Option B: fix backend — do NOT reverse operands for arithmetic ops
# if IR already matches EVM order
if opcode not in ("jmp", "jnz", "djmp", "phi", "invoke"):
    operands = inst.operands  # no reverse
```

**Follow-up test**
Add a one‑line Yul contract:
```
function f() -> r { r := shr(144, calldataload(0)) }
```
Compile with yul2venom and compare to Solidity output on known calldata.

---

## Claim A0-8: PHI handling in loops can add non‑predecessor operands
**Source:** `AUDIT_0.md` – "PHI Node Handling" (transpiler/backend audit section)

**Assessment:** **Plausible bug (needs confirmation)**

**Evidence / reasoning**
In the loop lowering, back‑edge operands are **always appended** to the loop‑header phi, even if the post block does **not** jump back to the header:

```python
# venom_generator.py (loop lowering)
if not self.current_bb.is_terminated:
    self.current_bb.append_instruction("jmp", loop_start_bb.label)

# back‑patch phis unconditionally
phi_inst.operands.append(post_block_label)
phi_inst.operands.append(post_val_reg)
```

If the post block terminates early (e.g., `leave`, `revert`, or an explicit `break` inside post), it is **not** a CFG predecessor of `loop_start_bb`. The phi then contains a label/value for a non‑predecessor, which violates SSA rules and can confuse stack reordering.

**Code reference**
- `yul2venom/generator/venom_generator.py` lines ~1541–1569 (unconditional phi back‑patch).

**Suggested fix**
Only append the back‑edge phi operand if the post block actually jumps to `loop_start_bb`:

```python
post_jumps_back = not self.current_bb.is_terminated
if post_jumps_back:
    self.current_bb.append_instruction("jmp", loop_start_bb.label)
    phi_inst.operands.append(post_block_label)
    phi_inst.operands.append(post_val_reg)
```

**Follow-up test**
Create a Yul `for` loop whose post block contains a `leave` or a conditional `break`, and verify SSA validation (check_venom_ctx) passes and generated bytecode matches Solidity behavior.

---

## Claim A0-9: Function return/invoke mismatch corrupts control flow
**Source:** `AUDIT_0.md` – "Function Return/Invoke Mismatch"

**Assessment:** **Not confirmed**

**Evidence / reasoning**
1) The calling convention is explicitly implemented and consistent across frontend + backend. In `generator/venom_generator.py`, non‑halting functions capture args then **PC last** and emit `ret` with return values followed by `$pc`:
```
# venom_generator.py
pc_var = self.current_bb.append_instruction("param")
self.var_map['$pc'] = pc_var
...
self.current_bb.append_instruction("ret", *ret_vals, self.var_map['$pc'])
```

2) The backend emits `invoke` as `PUSHLABEL(return_label)`, `PUSHLABEL(target)`, `JUMP`, and uses `ret` as a plain `JUMP`. The stack reorder logic for `ret` expects the **PC as the last operand**, matching the generator:
```
# venom_to_assembly.py
elif opcode == "invoke": assembly.extend([PUSHLABEL(return_label), PUSHLABEL(target), "JUMP", return_label])
elif opcode == "ret": assembly.append("JUMP")
```

3) `check_venom.py` validates the calling convention: for each function, `ret` arity is computed as `len(operands) - 1` (PC is required), and `invoke` output arity must match. If the pipeline runs `check_venom_ctx`, inconsistent ret/invoke arities are flagged early.

**Code reference**
- `yul2venom/generator/venom_generator.py` (non‑halting function entry + `ret` with `$pc`)
- `yul2venom/vyper/vyper/venom/venom_to_assembly.py` (invoke/ret emission)
- `yul2venom/vyper/vyper/venom/check_venom.py` (`_collect_ret_arities`, `find_calling_convention_errors`)

**Suggested fix (guardrail)**
Make calling‑convention checks **mandatory** in the transpilation pipeline to catch any future regressions:
```python
# yul2venom.py (after IR generation)
from vyper.venom.check_venom import check_calling_convention, check_venom_ctx
check_venom_ctx(ctx)
check_calling_convention(ctx)
```
Additionally, assert that any function emitting `ret` has `$pc` in scope:
```python
assert '$pc' in self.var_map, "ret without PC param"
```

**Follow-up test**
Add a minimal IR test with a multi‑return `invoke` and verify that `check_calling_convention` passes and the assembled bytecode returns to the caller (e.g., `test_invoke_multi_return.py`).

---

## Claim A0-10: Selector decoding is wrong (shr/short-calldata edge cases)
**Source:** `AUDIT_0.md` – "Selector Decoding"

**Assessment:** **Not confirmed (IR shows correct pattern), but at‑risk if SHR ordering bug is global**

**Evidence / reasoning**
1) The generated IR for `__main_entry` uses the standard selector decode pattern:
```
%2 = calldataload 0
%3 = shr 224, %2
%4 = mod %3, 22
...
djmp %8, @fallback, @bucket_1, ...
```
This matches Solidity/Vyper: `calldataload(0)` zero‑pads short calldata, and `shr 224` extracts the first 4 bytes. For empty calldata, `%3` is zero and the dispatcher should fall back.

2) Each bucket contains explicit `xor` checks against full selectors; mismatches fall through to fallback. This guards against hash collisions and avoids misrouting.

3) The confirmed SHR operand‑order bug (Claim A1‑7) could also break selector decode if it applies uniformly. If `shr` operands are reversed in assembly, `%3` becomes zero for most calls, collapsing dispatch to fallback. We do **not** yet observe this because the failing test uses empty selector (0x00000000), which still maps to fallback even with a broken SHR.

**Code reference**
- `onchain-trader/output/GuardedTrader_150_deployed.vnm` lines 1–15 (dispatch and `shr 224`)
- `onchain-trader/output/GuardedTrader_150_deployed.vnm` bucket blocks show `xor` + `jnz` checks.

**Suggested fix (validation + guardrail)**
If SHR ordering is fixed (Claim A1‑7), also add a **dispatcher regression test** to ensure non‑zero selectors route correctly:
```yul
object "C" {
  code {
    switch shr(224, calldataload(0))
    case 0x12345678 { mstore(0, 1) return(0, 32) }
    default { mstore(0, 2) return(0, 32) }
  }
}
```
Compile through yul2venom and assert selector `0x12345678` yields `1`, while empty calldata yields `2`.

**Follow-up test**
Add a minimal E2E test that calls a **non‑fallback external function** on a transpiled contract and verifies the correct branch, to catch selector decode regressions immediately.

---

## Claim A0-11: Transient storage (tload/tstore) unsupported or miscompiled
**Source:** `AUDIT_0.md` – "Transient Storage Usage"

**Assessment:** **Not confirmed (environment supports it; backend emits 1:1 opcodes)**

**Evidence / reasoning**
1) The test environment explicitly targets **Cancun**, which includes EIP‑1153 transient storage support:
```
# onchain-trader/base-config.toml
evm_version = "cancun"
```
So `TLOAD`/`TSTORE` are valid opcodes under the configured EVM.

2) The Venom backend treats `tload` and `tstore` as **one‑to‑one opcodes**:
```
# vyper/vyper/venom/venom_to_assembly.py
_ONE_TO_ONE_INSTRUCTIONS = { ..., "tload", "tstore", ... }
```
Meaning the transpiler does not lower them into something else; the opcodes are emitted directly.

**Code reference**
- `onchain-trader/base-config.toml` (EVM version)
- `yul2venom/vyper/vyper/venom/venom_to_assembly.py` (opcode mapping)

**Suggested fix (guardrail)**
Add a hard assertion in the transpilation pipeline that the configured EVM supports EIP‑1153 when any `tload`/`tstore` is present:
```python
# yul2venom.py (before backend)
if ctx.uses_opcode("tload") or ctx.uses_opcode("tstore"):
    assert config.evm_version in ("cancun", "prague"), "EIP-1153 required"
```

**Follow-up test**
Add a tiny contract using transient storage and ensure it round‑trips through yul2venom and runs under Foundry with `evm_version=cancun`.

---

## Claim A0-12: Stack model desync causes wrong operands on EVM stack
**Source:** `AUDIT_0.md` – "Stack Depth and Model Consistency"

**Assessment:** **Not confirmed as a concrete bug, but there is a real fragility around duplicate literals**

**Evidence / reasoning**
1) The backend stack reorder logic explicitly **asserts there are no duplicate operands** for any instruction:
```
# vyper/vyper/venom/venom_to_assembly.py
assert len(stack_ops) == len(set(stack_ops)), f"duplicated stack {stack_ops}"
```
If duplicates exist, this fails fast (compile‑time), not a silent runtime miscompile.

2) The yul2venom IR builder **materializes duplicate literals** into unique temps to avoid that assertion:
```
# yul2venom/ir/basicblock.py
if isinstance(arg, IRLiteral) and arg.value in seen_values:
    var = self.parent.get_next_variable()
    assign_inst = IRInstruction("assign", [arg], [var])
    self.instructions.append(assign_inst)
    processed_args[i] = var
```
So for instructions produced by the transpiler, this specific desync vector is mitigated.

3) However, after parsing into Vyper’s Venom IR, **optimizer passes can emit new instructions** using plain literals via `vyper/venom/basicblock.py`, which does **not** perform duplicate‑literal materialization. That means the backend can still encounter duplicate operands and assert, or if the assertion is bypassed later, reorder incorrectly. This is a fragility but not evidenced in the GuardedTrader failure.

**Code reference**
- `yul2venom/ir/basicblock.py` (duplicate literal materialization)
- `yul2venom/vyper/vyper/venom/venom_to_assembly.py` (`_stack_reorder` assertion)
- `yul2venom/vyper/vyper/venom/basicblock.py` (no duplicate‑literal handling in append_instruction)

**Suggested fix (hardening)**
Ensure duplicate‑literal materialization is applied **post‑optimization** too. Two options:
1) **Backend fix** (defensive): detect duplicates in `_stack_reorder` and auto‑materialize:
```python
# venom_to_assembly.py
if len(stack_ops) != len(set(stack_ops)):
    # create temps for duplicate literals before reorder
    stack_ops = self._materialize_duplicate_literals(inst, assembly, stack)
```
2) **Pass fix**: add a small cleanup pass after all Venom optimizations to rewrite any instruction with duplicate literals into equivalent temps using `assign`.

**Follow-up test**
Add a unit test that intentionally produces an instruction with duplicate literals (e.g., `add 0, 0` or `revert(0,0)`) *after* an optimization pass, and ensure it assembles without assertion and produces correct bytecode.

---

## Claim A0-13: Optimization level mismatches remove critical safety checks
**Source:** `AUDIT_0.md` – "Optimization Level Mismatches"

**Assessment:** **Not confirmed for GuardedTrader (panic check still present), but risk exists if unsafe levels are used**

**Evidence / reasoning**
1) The Yul source optimizer is configured to **safe** in the project config:
```
# yul2venom.config.yaml
yul_optimizer:
  level: safe
```
This level is documented to avoid removing structural checks such as Panic(0x32).

2) The Venom IR optimization pipeline in `yul2venom.py` includes passes like `RevertToAssert` and `AssertEliminationPass`, but these are only supposed to remove **provably true** asserts. The GuardedTrader output still contains the array‑bounds panic helpers, indicating the checks were **not** eliminated in this build (we observe Panic(0x32) at runtime).

3) Therefore the observed panic is **incompatible** with “checks removed by optimizer” in this case; the check was present and fired. The more plausible root cause is bad input data (shr operand order) producing length 0.

**Code reference**
- `yul2venom/yul2venom.config.yaml` (safe Yul optimizer level)
- `yul2venom/yul2venom.py` (O2 pipeline includes `RevertToAssert`, `AssertEliminationPass`)
- `onchain-trader/output/GuardedTrader_opt.yul` contains `memory_array_index_access_*` with panic code.

**Suggested fix (guardrail)**
Make unsafe optimization levels explicit and refuse to run “maximum/aggressive” without a flag:
```python
if level in {"aggressive", "maximum"} and not args.unsafe:
    raise RuntimeError("Unsafe optimization requires --unsafe")
```
Also expose a `--no-assert-elim` option for debugging safety regressions.

**Follow-up test**
Compile the same Yul at safe vs maximum and assert that the panic helper still exists in safe mode (and disappears only when unsafe is explicitly requested).

---

## Claim A1-8: Pointer defaulted to 0 is later used outside its guarded branch
**Source:** `AUDIT_1.md` – "Root Cause: pointer initialized to zero then used unconditionally"

**Assessment:** **Not confirmed for GuardedTrader fallback**

**Evidence / reasoning**
1) In the fallback Yul, `var_params_mpos` is indeed initialized to `0`, but it is **assigned to a real memory pointer (`memPtr`) before it is used**:
```
let var_params_mpos := 0
...
mstore(offset, memPtr_1)
var_params_mpos := memPtr
var_length := var_path
let _mpos := mload(memory_array_index_access_struct_Data_dyn_22269(mload(offset)))
```
This shows the pointer is populated before the subsequent dereference path.

2) The panic occurs when `memory_array_index_access_struct_Data_dyn_*` checks the array length (stored at `memPtr_1`) and finds `0`. That is a **data‑dependent empty array**, not a null pointer use.

3) Therefore the “default pointer used outside branch” scenario does **not** explain this specific panic. The root cause remains incorrect `var_path` computation (shr operand order).

**Code reference**
- `onchain-trader/output/GuardedTrader_opt.yul` lines ~1958–2105 (fallback body shows `var_params_mpos := memPtr` before use).
- `onchain-trader/output/GuardedTrader_opt.yul` lines ~2105–2110 (first dereference after assignment).

**Suggested fix (if this pattern appears elsewhere)**
Where a pointer is initialized to 0 then conditionally set, ensure **all uses are dominated by the assignment**, or guard with an explicit check:
```yul
if iszero(var_params_mpos) { revert(0, 0) }
```

**Follow-up test**
Search for variables initialized to `0` and later used (especially pointers), then compile a small fuzz test that forces the “not‑assigned” path and verifies it reverts cleanly rather than panicking.

---

## Claim A0-14: FMP initialization ignores memoryguard argument (potential layout mismatch)
**Source:** `AUDIT_0.md` – "Memory Layout Misalignment" (detail: FMP init)

**Assessment:** **Partially confirmed (design choice), low risk for GuardedTrader but could break contracts that rely on larger memoryguard**

**Evidence / reasoning**
1) The transpiler **intercepts** `mstore(64, memoryguard(...))` and **replaces** it with `mstore(fmp_slot, venom_start)`:
```
# generator/venom_generator.py
if is_fmp_slot and is_memguard:
    fmp_slot = self.config.memory.fmp_slot
    venom_start = self.config.memory.venom_start
    self.current_bb.append_instruction("mstore", IRLiteral(fmp_slot), IRLiteral(venom_start))
    return
```
This discards the actual `memoryguard` argument.

2) In GuardedTrader’s Yul, the memoryguard argument is the standard `0x80`:
```
mstore(64, memoryguard(0x80))
```
With `venom_start=0x100`, the transpiler **moves the FMP up**, which is safe (allocations start later) and avoids overlap with Venom’s spill region. So for this contract, it’s **not a bug**.

3) However, if a contract emits `memoryguard(0x120)` (or any value **higher than `venom_start`**), forcing FMP to `0x100` would **move the heap backward**, possibly overlapping memory that the Yul assumed reserved. That is a real mismatch risk for other contracts.

**Code reference**
- `yul2venom/generator/venom_generator.py` (memoryguard interception around the `YulExpressionStmt` handler).
- `onchain-trader/output/GuardedTrader_opt.yul` line ~281 (`mstore(64, memoryguard(0x80))`).
- `yul2venom/yul2venom.config.yaml` (venom_start default 0x100).

**Suggested fix**
Respect the `memoryguard` argument by setting:
```
FMP = max(memoryguard_arg, venom_start)
```
Implementation sketch:
```python
# generator/venom_generator.py
guard_arg = val_arg.args[0]  # memoryguard(x)
guard_val = self._visit_expr(guard_arg)
venom_start = IRLiteral(self.config.memory.venom_start)
is_lt = self.current_bb.append_instruction("lt", guard_val, venom_start)
new_fmp = self.current_bb.append_instruction("select", is_lt, venom_start, guard_val)
self.current_bb.append_instruction("mstore", IRLiteral(fmp_slot), new_fmp)
```
If `select` is not available, implement with `jnz` + phi to pick the max.

**Follow-up test**
Create a tiny Yul object with `memoryguard(0x200)` and verify the transpiler sets FMP to `0x200` (not `0x100`).

---

## Claim U1: Yul `invalid()` lowered to `STOP` (changes semantics)
**Source:** User finding (review note), not explicitly in AUDIT_0/1

**Assessment:** **Not confirmed (current pipeline emits `INVALID`)**

**Evidence / reasoning**
1) The Yul intrinsic `invalid` is explicitly mapped to the Venom opcode `invalid`:
```
# generator/venom_generator.py
if func == "invalid":
    return self.current_bb.append_instruction("invalid")
```

2) The backend treats `invalid` as a one‑to‑one opcode and emits EVM `INVALID` (0xFE):
```
# vyper/vyper/venom/venom_to_assembly.py
_ONE_TO_ONE_INSTRUCTIONS = { ..., "invalid", ... }
```

There is no conversion to `stop` in either stage, so the reported behavior does not match the current code.

**Code reference**
- `yul2venom/generator/venom_generator.py` (intrinsic mapping)
- `yul2venom/vyper/vyper/venom/venom_to_assembly.py` (opcode emission)

**Suggested fix (if this shows up in output)**
If you observe `STOP` in actual bytecode, add a targeted unit test with:
```yul
{
  invalid()
}
```
and assert the generated bytecode contains `0xFE` (not `0x00`). If it doesn’t, track the opcode rewriting stage and block `invalid → stop` rewrites.

**Follow-up test**
Add a tiny Yul fixture using `invalid()` and compare disassembly between solc and yul2venom output.

---

## Claim A0-15: VNM serialization uses wrong operand order (breaks non‑commutative ops)
**Source:** Derived from audit evidence + code inspection (root cause for SHR bug)

**Assessment:** **Confirmed (serialization mismatch)**

**Evidence / reasoning**
1) The yul2venom IR serializer **does not reverse operands** for display:
```
# yul2venom/ir/basicblock.py
# NOTE: Local IR does NOT reverse operands
ops = self.operands
if self.opcode == "invoke":
    ops = [ops[0]] + list(reversed(ops[1:]))
# DO NOT reverse - local convention is different from Vyper's
```

2) The Vyper Venom text format **expects display‑order operands**, and its `__repr__` reverses operands for most opcodes:
```
# vyper/vyper/venom/basicblock.py
if self.opcode not in ("jmp", "jnz", "djmp", "phi"):
    operands = reversed(operands)
```
This means VNM text should be in **display order** (top‑of‑stack first). `parse_venom` does not re‑order operands; it uses the textual order as‑is.

3) Because yul2venom emits VNM in **internal order** but Vyper expects **display order**, operands are effectively reversed when parsed. This directly explains the SHR bug: `shr(shift, value)` becomes `shr(value, shift)` after the round‑trip.

**Code reference**
- `yul2venom/ir/basicblock.py` (no operand reversal in `__repr__`)
- `yul2venom/vyper/vyper/venom/basicblock.py` (operand reversal for display)
- `yul2venom/vyper/vyper/venom/parser.py` (no operand re‑ordering on parse)

**Suggested fix**
Emit VNM in the **same display order** that Vyper expects. Either:
1) **Fix serializer** to reverse operands for non‑control ops (match Vyper’s `__repr__`), or  
2) **Bypass parse_venom** and construct Vyper IR directly without a text round‑trip.

Minimal fix sketch (option 1):
```python
# yul2venom/ir/basicblock.py
ops = self.operands
if self.opcode == "invoke":
    ops = [ops[0]] + list(reversed(ops[1:]))
elif self.opcode not in ("jmp", "jnz", "djmp", "phi"):
    ops = list(reversed(ops))
```

**Follow-up test**
Add a regression fixture with a non‑commutative op (e.g., `shr(144, calldataload(0))` and `sub(5, 3)`) and assert the parsed VNM still yields the same result as Yul. This should catch operand order regressions early.

---

## Claim A2-0: AUDIT_2 contains no findings to assess
**Source:** `AUDIT_2.md`

**Assessment:** **Confirmed (file is empty)**

**Evidence / reasoning**
`AUDIT_2.md` is empty (`0` lines), so there are no claims to validate or refute in this audit.

**Code reference**
- `yul2venom/docs/AUDIT_2.md`

**Suggested fix**
None. If new claims are added to AUDIT_2 later, we can append assessments here.

**Follow-up**
Add a short placeholder section in `AUDIT_2.md` describing the intended scope to avoid confusion.

---

## Claim U2: Public pipeline import is broken (core/__init__.py imports missing module)
**Source:** User finding + code inspection

**Assessment:** **Confirmed**

**Evidence / reasoning**
1) `yul2venom/core/__init__.py` imports `from .pipeline import ...`, but **there is no `core/pipeline.py`** in the repo:
```
core/
  __init__.py
  errors.py
```
Attempting `import yul2venom.core` will raise `ModuleNotFoundError: No module named 'yul2venom.core.pipeline'`.

2) There *are* `core/__pycache__/pipeline.cpython-*.pyc` artifacts, which implies the file existed previously but is missing now. That means the public API is stale.

**Code reference**
- `yul2venom/core/__init__.py` (imports `.pipeline`)
- `yul2venom/core/` directory listing (no `pipeline.py`)

**Suggested fix**
Either restore `core/pipeline.py` or update `core/__init__.py` to re‑export the actual pipeline entrypoint (likely `yul2venom.py` or `transpiler.py`):
```python
# core/__init__.py
from yul2venom import transpile  # or from yul2venom.transpiler import ...
```
If you want a stable API, add a thin wrapper in `core/pipeline.py` that forwards to the current implementation.

**Follow-up test**
Add a tiny import test: `python -c "import yul2venom.core"` should succeed and expose `transpile` / `TranspilationPipeline`.

---

## Claim A2-1: AssertOptimizer drops custom error revert data
**Source:** `AUDIT_2.md` section “A) AssertOptimizer drops custom error data”

**Assessment:** **Confirmed (semantic change)**

**Evidence / reasoning**
1) The optimizer treats **any** `revert_error_*` call as a “simple revert” and converts it into `assert`:
```
# generator/optimizations.py
elif stmt.function.startswith("revert_error_"):
    return True
```
This causes `if cond { revert_error_FO() }` to be lowered into `assert` with **no revert data**, discarding the custom error selector and arguments.

2) The optimizer is invoked during `YulIf` handling in `venom_generator.py`; when it matches, it **bypasses** the original revert body:
```
if self.optimizer.try_optimize_stmt(stmt, opt_ctx):
    return
```
So the loss of revert data is systematic wherever this pattern occurs.

**Code reference**
- `yul2venom/generator/optimizations.py` (`AssertOptimizer._is_simple_revert_body`)
- `yul2venom/generator/venom_generator.py` (`YulIf` handler calls optimizer)

**Suggested fix**
Only treat `revert(0,0)` as assertable. **Do not** fold `revert_error_*`:
```python
elif stmt.function.startswith("revert_error_"):
    return False  # keep custom error data
```
If you still want a size optimization, add a configurable flag `optimize_custom_reverts=False` and default it off.

**Follow-up test**
Add a regression test where a contract reverts with a custom error on a simple condition. Verify the revert selector is preserved in bytecode and runtime output after transpilation.

---

## Claim A2-2: Multi‑return invoke in expression context drops outputs (stack corruption risk)
**Source:** `AUDIT_2.md` section “B) Multi‑return invoke in expression context leaks stack”

**Assessment:** **Confirmed**

**Evidence / reasoning**
1) In expression context (`_visit_expr`), non‑inlined function calls with multiple returns allocate **only one** output variable:
```
# venom_generator.py
if f_def.returns:
    ret = self.current_fn.get_next_variable()
    self.current_bb.append_instruction("invoke", ..., ret=ret)
    return ret
```
This ignores additional return values defined in the callee signature.

2) The calling convention checker expects the number of `invoke` outputs to match the callee’s return arity. When a function returns multiple values, this will cause an **InvokeArityMismatch** (the pipeline logs it but continues).

3) At runtime, the extra return values remain on the EVM stack but are **not represented in the IR stack model**, so subsequent stack reordering/pops can become incorrect. This is exactly the kind of silent stack corruption that later manifests as wrong operands.

**Code reference**
- `yul2venom/generator/venom_generator.py` (`_visit_expr` handling of `invoke`)
- `yul2venom/vyper/vyper/venom/check_venom.py` (`InvokeArityMismatch` validation)

**Suggested fix**
Always allocate outputs for **all** return values, even if only the first is used. Return the first as the expression result:
```python
# venom_generator.py (inside _visit_expr for invoke)
ret_vars = [self.current_fn.get_next_variable() for _ in f_def.returns]
invoke_inst = IRInstruction("invoke", [IRLabel(self.sanitize(func))] + arg_vals, outputs=ret_vars)
self.current_bb.instructions.append(invoke_inst)
return ret_vars[0]
```
Optionally, add a strict mode that raises if a multi‑return function is used in an expression context without explicit assignment targets.

**Follow-up test**
Create a Yul function returning two values (e.g., `function f() -> a,b`) and call it in an expression context (`let x := f()`). Verify that `check_calling_convention` passes and the generated bytecode produces correct results.

---

## Claim A2-3: Inline function locals can clobber caller variables
**Source:** `AUDIT_2.md` section “C) Inline function locals can clobber caller variables”

**Assessment:** **Not confirmed (generator restores caller scope), but there is a narrower risk around shadowed params/returns inside inlined body**

**Evidence / reasoning**
1) The inliner **saves and restores** the caller’s `var_map` after inlining:
```
# venom_generator.py
saved_var_map = self.var_map.copy()
...
for var_name, var_val in saved_var_map.items():
    self.var_map[var_name] = var_val
```
This prevents permanent clobbering of caller variables after the inline body finishes.

2) During inlining, the inlined function’s locals and params **do** overwrite entries in `self.var_map` while the body executes. That is intentional, but it means any reference to a caller variable with the same name **inside** the inlined function body will resolve to the local, not the caller. In Yul, this is correct scoping, provided the function’s locals are meant to shadow outer names.

3) The more subtle risk is when the inline body uses a variable name that exists in caller scope but was **not declared inside the function** (e.g., due to missing local declaration in Yul). In that case, the inliner would resolve it to the caller’s variable (because it is in `var_map`), which may be unintended. This is a Yul authoring bug, but the inliner will **not** catch it.

**Code reference**
- `yul2venom/generator/venom_generator.py` (`_inline_function_call`, save/restore of `var_map`)

**Suggested fix**
Add a defensive scope check: while inlining, treat any variable reference not declared as a local/arg/return within the function as an error (or warn). This prevents accidental capture of caller variables:
```python
# During inlining, build a set of allowed locals
allowed = set(f_def.args) | set(f_def.returns) | locals_declared_in_body
if yul_identifier not in allowed:
    raise TranspilationError("Undeclared local in inlined function")
```

**Follow-up test**
Create a Yul function that intentionally references an outer variable without declaring it. Verify the transpiler flags it in inline mode.

---

## Claim A2-4: Duplicate literal operands rely on Vyper fork patch
**Source:** `AUDIT_2.md` section “D) Duplicate literal operands rely on Vyper fork patch”

**Assessment:** **Partially confirmed (fragility remains post‑optimization)**

**Evidence / reasoning**
1) The yul2venom IR builder **does** materialize duplicate literals to avoid backend assertions:
```
# yul2venom/ir/basicblock.py
if isinstance(arg, IRLiteral) and arg.value in seen_values:
    var = self.parent.get_next_variable()
    assign_inst = IRInstruction("assign", [arg], [var])
    self.instructions.append(assign_inst)
```

2) However, after parsing into Vyper IR, optimizer passes can emit new instructions (using `vyper/venom/basicblock.py`) which **do not** perform duplicate literal materialization. The backend `_stack_reorder` asserts on duplicates, so this is a real latent failure if a pass emits e.g. `revert 0, 0` or `add 0, 0`.

So the fragility is confirmed at the pipeline level, even if some inputs are protected by the initial IR builder.

**Code reference**
- `yul2venom/ir/basicblock.py` (duplicate literal handling in transpiler IR)
- `yul2venom/vyper/vyper/venom/basicblock.py` (no duplicate literal handling)
- `yul2venom/vyper/vyper/venom/venom_to_assembly.py` (`_stack_reorder` duplicate‑operand assertion)

**Suggested fix**
Add a **post‑optimization cleanup pass** in the Vyper pipeline to materialize duplicate literals, or add a defensive transform in `_stack_reorder` (see Claim A0‑12). This ensures the pipeline is “venom‑native” and not reliant on fork‑specific behavior.

**Follow-up test**
Add a minimal Venom IR pass that emits `revert 0, 0` and verify assembly succeeds in both the fork and upstream Vyper (no assertion).

---

## Claim A2-5: `allocate_memory` safety only handled in `let` (expression use can clobber pointer)
**Source:** `AUDIT_2.md` section “E) allocate_memory safety only handled in let”

**Assessment:** **Confirmed as a general risk; not observed in GuardedTrader output**

**Evidence / reasoning**
1) The special‑case preservation for `allocate_memory` exists **only** in `YulVariableDeclaration`:
```
# venom_generator.py (YulVariableDeclaration)
if func_name == 'allocate_memory' and func_name in self.inlinable_functions:
    ... result_vals = _inline_function_call(...)
    preserved_ptr = self.current_bb.append_instruction("add", IRLiteral(0), ptr)
```
There is **no corresponding special case** in `_visit_expr` for `allocate_memory()` calls used as sub‑expressions.

2) In GuardedTrader Yul, `allocate_memory()` is only used in `let` statements (e.g., `let expr_7525_mpos := allocate_memory()`), so this specific contract is not affected. But any Yul that uses `mstore(allocate_memory(), ...)` or `foo(allocate_memory())` could lose the pointer due to later stack reordering.

**Code reference**
- `yul2venom/generator/venom_generator.py` (special‑case inside `YulVariableDeclaration`)
- `yul2venom/generator/venom_generator.py` (`_visit_expr` has no allocate_memory handling)
- `onchain-trader/output/GuardedTrader_opt.yul` (only `let ... := allocate_memory()` occurrences)

**Suggested fix**
Normalize `allocate_memory()` **everywhere** to a temp before use:
```python
# in _visit_expr
if func == "allocate_memory" and func in self.inlinable_functions:
    tmp = self._inline_function_call(func, arg_vals)[0]
    tmp2 = self.current_bb.append_instruction("add", IRLiteral(0), tmp)
    return tmp2
```
Or introduce a pass that rewrites any `allocate_memory()` expression into a `let tmp := allocate_memory()` prelude.

**Follow-up test**
Add a Yul snippet with `mstore(allocate_memory(), 0x1234)` and verify pointer remains valid (no stack corruption) after transpilation.

---

## Claim A2-6: Yul parser ignores data sections (datasize/dataoffset wrong)
**Source:** `AUDIT_2.md` section “F) Yul parser ignores data sections”

**Assessment:** **Partially confirmed (parser ignores data), but not impacting GuardedTrader’s dataoffset/datasize uses**

**Evidence / reasoning**
1) The Yul parser explicitly **skips** `data` sections:
```
# parser/yul_parser.py
elif token == 'data':
    # Skip data sections for now, or capture if needed
    self.consume()  # name
    self.consume()  # format
    self.consume()  # value
```
So raw data blobs (e.g., metadata) are never placed into the AST.

2) However, GuardedTrader’s Yul only uses `dataoffset`/`datasize` for **object names** (sidecars), not for raw `data` blobs. The only `data` sections are `.metadata`, and there are **zero** `dataoffset(".metadata")` or `datasize(".metadata")` uses in the Yul.

3) Thus the parser omission is real, but it does **not** explain the GuardedTrader failure. It *will* break contracts that rely on explicit data blobs via `dataoffset/datasize` of a `data` section.

**Code reference**
- `yul2venom/parser/yul_parser.py` (data sections skipped)
- `onchain-trader/output/GuardedTrader_opt.yul` (only `.metadata` data sections; no `dataoffset(".metadata")` usage)

**Suggested fix**
Extend the parser AST to capture data sections into `YulObject`, and plumb them into `data_map` so `datasize/dataoffset` can resolve raw blobs:
```python
# yul_parser.py: collect data entries into object.data_items
# venom_generator.py: if obj_name is a data blob, use its length/offset
```
Alternatively, if raw `data` is not required in your pipeline, explicitly reject it with a clear error when encountered.

**Follow-up test**
Add a minimal Yul object that defines `data "blob" hex"deadbeef"` and uses `datasize("blob")`. Verify yul2venom returns the correct size (4) and offset.

---

## Claim U3: Backend exposes only CLI; no programmatic `run_venom_backend`
**Source:** User finding (missing backend API)

**Assessment:** **Confirmed**

**Evidence / reasoning**
1) `backend/run_venom.py` defines `load_immutables()` and a CLI `main()`, but no reusable function that takes a Venom IR string/context and returns bytecode.

2) `backend/__init__.py` only exports `load_immutables` and `main`:
```
from .run_venom import load_immutables, main
```
So any pipeline expecting a `run_venom_backend` helper will fail with `ImportError`.

**Code reference**
- `yul2venom/backend/run_venom.py` (only `load_immutables`, `main`)
- `yul2venom/backend/__init__.py` (exports `load_immutables`, `main`)

**Suggested fix**
Add a small programmatic entrypoint that mirrors the CLI logic:
```python
# backend/run_venom.py
def run_venom_backend(source: str, immutables: dict | None = None) -> bytes:
    ctx = parse_venom(source)
    for fn in ctx.functions.values():
        ctx.mem_allocator.fn_eom[fn] = SPILL_OFFSET
    if immutables:
        ctx.immutables = immutables
    flags = VenomOptimizationFlags(level=OptimizationLevel.default(), disable_mem2var=True)
    run_passes_on(ctx, flags)
    asm = generate_assembly_experimental(ctx)
    bytecode, _ = generate_bytecode(asm)
    return bytecode
```
Then export it in `backend/__init__.py`.

**Follow-up test**
Add a unit test that feeds a small VNM string into `run_venom_backend` and asserts the returned bytecode matches a known value.
