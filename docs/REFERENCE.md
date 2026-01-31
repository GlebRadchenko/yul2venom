# Yul2Venom Reference

> **Last Verified**: 2026-01-27 against `vyper/venom/` codebase

## Operand Reversal Rule

**ALL standard EVM intrinsics require operands REVERSED from Yul order.**

| Yul | EVM Stack (Top→Bottom) | Venom IR | Action |
|-----|------------------------|----------|--------|
| `sub(a, b)` | `a, b` | `sub b, a` | **REVERSE** |
| `div(a, b)` | `a, b` | `div b, a` | **REVERSE** |
| `mstore(o, v)` | `o, v` | `mstore v, o` | **REVERSE** |
| `codecopy(d,o,s)` | `d, o, s` | `codecopy s, o, d` | **REVERSE** |
| `return(o, s)` | `o, s` | `return s, o` | **REVERSE** |

**Why**: Venom IR `op A, B` → PUSH A, PUSH B → Stack `[B, A]` (Top=B). EVM pops Top first.

**Exceptions**: Commutative ops (`add`,`mul`,`eq`), single-arg ops, labels.

---

## Safe Yul O2 Pipeline (Verified Jan 2026)

The standard Vyper O2 pipeline causes regressions with Yul input. We use a **Safe Subset**:

```
SimplifyCFGPass → Mem2Var → MakeSSA → PhiEliminationPass →
RemoveUnusedVariablesPass → CFGNormalization →
FloatAllocas → AssignElimination → RevertToAssert →
MemMergePass → LowerDloadPass → ConcretizeMemLocPass →
BranchOptimizationPass → CSE → LoadElimination
```

**Excluded Passes (Unsafe for Yul)**:
| Pass | Reason |
|------|--------|
| `SCCP` | Corrupts revert strings and logic (e.g., `updateState` failure) |
| `AlgebraicOptimization` | Incorrect simplification of math/logic |
| `DeadStoreElimination` | Corrupts transient storage / memory writes |
| `SingleUseExpansion` | Causes crashes during SSA reconstruction |
| `DFTPass` | Backend crashes (stack ordering issues) |

**Key Passes**:
| Pass | Purpose |
|------|---------|
| `Mem2Var` | Promotes `alloca`→registers (only if local, analyzable) |
| `MakeSSA` | Converts to SSA form (phi nodes) |
| `BranchOptimization` | Optimizes jump targets |
| `LoadElimination` | Removes redundant Loads |


---

## Venom IR Structure

```
IRContext
  └─ IRFunction (multiple)
      └─ IRBasicBlock (multiple)
          └─ IRInstruction
              ├─ opcode (string)
              ├─ operands (list[IROperand])
              └─ outputs (list[IRVariable])
```

**Key Instructions**:
| Instruction | Format | Notes |
|-------------|--------|-------|
| `param` | `%x = param` | Function parameter (pseudo, eliminated) |
| `invoke` | `%ret = invoke @fn, argN, ..., arg1` | Args reversed |
| `ret` | `ret val1, val2, ..., pc` | PC on top for JUMP |
| `alloca` | `%ptr = alloca size` | Memory allocation |

---

## Memory Layout

| Zone | Address | Purpose |
|------|---------|---------|
| Scratch | `0x00-0x3F` | Temp ops |
| FMP | `0x40` | Yul Free Memory Pointer |
| Zero Slot | `0x60` | Must be 0 |
| Yul Heap | `0x80+` | `memoryguard(0x80)` |
| Globals | `0x3000+` | Init code globals |
| Spill | `0x4000+` | Register spill area |
| Invoke Scratch | `0x80+` | Caller frame save during invoke |

**FN_START** (from `memory_allocator.py`): Default = `MemoryPositions.RESERVED_MEMORY`

---

## One-to-One EVM Opcodes

From `venom_to_assembly.py` `_ONE_TO_ONE_INSTRUCTIONS` (70+ opcodes):

```
revert, coinbase, calldatasize, calldatacopy, mcopy, calldataload, gas,
gasprice, gaslimit, chainid, address, origin, number, extcodesize, extcodehash,
codecopy, extcodecopy, returndatasize, returndatacopy, callvalue, selfbalance,
sload, sstore, mload, mstore, tload, tstore, timestamp, caller, blockhash,
selfdestruct, signextend, stop, shr, shl, sar, and, xor, or, add, sub, mul,
div, smul, sdiv, mod, smod, exp, addmod, mulmod, eq, iszero, not, lt, gt,
slt, sgt, create, create2, msize, balance, call, staticcall, delegatecall,
codesize, basefee, blobhash, blobbasefee, prevrandao, difficulty, invalid
```

---

## Void Instructions (Double Pop Fix)

Venom backend assumes all instructions typically return a value (to be PUSHed).
For **Void Instructions** (those that produce no output), they must be whitelisted in `basicblock.py::NO_OUTPUT_INSTRUCTIONS`.

**List of Void Ops**:
- `stop`, `jump`, `jumpi`, `pop`, `mstore`, `mstore8`, `sstore`, `jumpdest`
- `return`, `revert`, `selfdestruct`, `invalid`
- `log0`, `log1`, `log2`, `log3`, `log4`, `tstore`

**Impact**: If a void op is NOT whitelisted, Venom emits an extra `POP` instruction, causing stack underflow.


## Transpiler Variable Model

**Register-Based (Current)**:
- `YulVariableDeclaration` → `var_map[name] = IRVariable | IRLiteral`
- `YulAssignment` → `var_map[name] = new_value`
- `_visit_expr` → Return `var_map[name]` directly

**Memory ONLY for**:
- ✅ Solidity memory arrays
- ✅ ABI encoding/decoding
- ✅ Explicit Yul `mload`/`mstore`
- ✅ Global variables

---

## Vyper Fork Changes

From `VYPER_CHANGES_AUDIT.md` (91 additions, 37 deletions):

| Change | Upstream? |
|--------|-----------|
| DCE disabled for external callbacks | ✅ Add callback heuristic |
| Operand reversal disabled in parser | ❌ Keep local |
| FN_START @ 0x4000 | ⚠️ Make configurable |
| Float Allocas improvements | ✅ General improvement |
| Recursion safety in concretize_mem_loc | ✅ Prevents crashes |

---

## Invoke Calling Convention

From `venom_to_assembly.py` lines 619-723:

1. **Spill caller vars** to memory (`0x80 + i*32`)
2. **PUSH return label, PUSH target, JUMP**
3. **Return label**: JUMPDEST
4. **Cleanup**: SWAP + POP to preserve return value
5. **Restore caller vars** from memory (reverse order)

---

## Test Status

| Test | Status |
|------|--------|
| OpcodeBasics | ✅ PASS |
| DebugRevert | ✅ PASS |
| MinimalCall | ❌ StackOverflow |
| RuntimeOnlyTest | ❌ StackOverflow |

See `BUG_STATUS.md` for current investigation.
