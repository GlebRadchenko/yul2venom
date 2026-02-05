I dug deeper locally (no edits/checkouts). The GuardedTrader panic does not look like cross‑object resolution; it looks like a bitmask decode bug that zeroes var_path, and that propagates into a zero-length array → Panic(0x32).

High‑confidence root cause direction (GuardedTrader)

In the transpiled runtime, the line mstore(memPtr, shr(144, usr$bitmask)) stores 0, but it should store 0x751f5612 for your calldata. That implies the SHR computation is wrong (operand order or stack scheduling).
I verified this with the local tracer using your calldata + caller/origin match. At:
PC=07f8 MSTORE(0x100, 0x0)
This corresponds to mstore(memPtr, shr(144, usr$bitmask)) and shows shr result = 0.
Because var_path = and(shr(138, usr$bitmask), 0x0f), if shr is wrong, var_path becomes 0. Then:
mstore(memPtr_1, var_path) stores array length 0 at 0x160, and
memory_array_index_access_* panics on length 0.
That exactly matches your trace.
Why this matters: it means the failure is upstream of array access (bitmask extraction), not a wrong function call. The function identity in the Yul file is likely a red herring.

Debug vectors to confirm

Disassemble around the SHR (shift 144 and 138)
Use your runtime bytecode and confirm the operand order:

Correct EVM order should push value then shift, then SHR.
If it pushes shift then value, shr returns 0.
Example:
python3.11 testing/inspect_bytecode.py /Users/gleb/Developer/evm/onchain-trader/output/GuardedTrader_opt_runtime.bin --limit 4000 | grep -n "SHR" -n
Then inspect the pushes immediately before each SHR (0x90 and 0x8a).

Raw VNM check (best signal)
Re‑transpile with --dump-ir and inspect VNM around the fallback path:

Look for shr 144, %usr$bitmask vs shr %usr$bitmask, 144.
If the operands are reversed in VNM, that explains the EVM result.
Optimization isolation
Re‑run transpile with -O none and again with -O native.
If SHR becomes correct in -O none, the bug is in Vyper passes (stack reorder / assign / dedup).

Tracer logging at PC=07f6
Modify the tracer temporarily to log every instruction or to log stack when PC==07f6 (SHR). That will show the true operand order at runtime.

Deeper audit: additional real issues I found (not exhaustive)

A) AssertOptimizer drops custom error data

File: optimizations.py
AssertOptimizer._is_simple_revert_body treats revert_error_* as “simple” and converts it to assert.
This removes revert data (custom error selector), which is a semantic bug.
Fix: only treat revert(0,0) as assertable. revert_error_* should remain a revert.
B) Multi‑return invoke in expression context leaks stack

File: venom_generator.py
In _visit_expr, for non‑inlined functions:
if f_def.returns:
    ret = self.current_fn.get_next_variable()
    self.current_bb.append_instruction("invoke", ..., ret=ret)
This captures only one return value even if the function returns multiple values.
Result: extra return values remain on stack, corrupting stack layout.
Fix: allocate dummy outputs for all returns, even if expression only uses the first.
C) Inline function locals can clobber caller variables

Inlining does not rename local variables inside inlined functions. If a local name matches a caller variable, the caller’s mapping is overwritten and not restored.
Fix: mangle local names per inline instance (e.g., prefix %inlN_) or use a scoped var_map stack for inline bodies.
D) Duplicate literal operands rely on Vyper fork patch

revert(0,0) and similar are emitted as duplicate literals.
Upstream Vyper stack model asserts on duplicate operands; your fork patch masks it.
Fix: materialize duplicate literals via a temp (add 0,0 or assign) so operands are unique.
This is required to be “venom‑native”.
E) allocate_memory safety only handled in let

Special-case only exists for let x := allocate_memory(...).
If allocate_memory is used inside expressions (e.g., nested in mstore), the pointer can be clobbered by stack operations.
Fix: apply the same preservation logic in _visit_expr for allocate_memory calls or normalize to a temp first.
F) Yul parser ignores data sections

The parser consumes data tokens but does not load raw data.
That breaks datasize("...")/dataoffset("...") semantics for data segments.
Fix: capture data sections into the AST and wire them into data_map.
How this ties back to GuardedTrader
The trace shows usr$bitmask is on stack but both:

shr(144, usr$bitmask) → 0
shr(138, usr$bitmask) → 0
This strongly suggests an operand‑order bug or stack reorder bug around SHR. That is exactly the kind of issue the Vyper fork patches are papering over (assign/duplicate literals), so I’d focus there first.
If you want, I can:

Pull the exact VNM for GuardedTrader runtime and point to the SHR opcode order in that IR.
Compare the same sequence in original Solidity bytecode to show the operand order mismatch.