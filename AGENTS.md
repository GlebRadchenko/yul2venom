# Yul2Venom: AI Agent Context

> **Read this FIRST when starting a session. Condensed reference for AI agents.**

## Project Overview

**Yul2Venom**: Yul → Venom IR transpiler. Uses Vyper's backend for Solidity bytecode generation.

```
Solidity → solc --ir-optimized → Yul → Yul2Venom → Venom IR → Vyper backend → EVM
```

## File Roles (Priority Order)

| File | Role | Modify When |
|------|------|-------------|
| `yul2venom.py` (47KB) | CLI entry. Commands: `prepare`, `transpile` | Adding CLI features |
| `venom_generator.py` (75KB) | **Core transpiler**. Yul AST → Venom IR | Fixing transpilation bugs |
| `yul_parser.py` (14KB) | Yul source → Python AST (lark-based) | Parser issues |
| `yul_extractor.py` | Extract deployed object from Yul | Deployment extraction |
| `optimizer.py` | Yul-level optimizations | Pre-transpile optimizations |
| `run_venom.py` | VNM text → bytecode via Vyper backend | Backend invocation |
| `ir/*.py` | Local IR types: BasicBlock, IRInstruction | Adding opcodes |

### Vyper Fork (`vyper/`)

| File | Role | Modify? |
|------|------|---------|
| `vyper/venom/parser.py` | VNM text → IRContext. **REVERSES OPERANDS** | Read-only |
| `vyper/venom/venom_to_assembly.py` | IR → EVM assembly | Avoid |
| `vyper/venom/passes/*.py` | Optimization passes | DCE disabled here |
| `vyper/venom/analysis/liveness.py` | Liveness analysis | Phi ordering fix here |

## Directory Structure

```
yul2venom/
├── *.py                    # Core transpiler (7 files)
├── ir/                     # Local IR types
├── vyper/                  # Vyper fork (submodule: GlebRadchenko/vyper@yul2venom)
├── foundry/                # Foundry project
│   ├── src/                # Solidity contracts (17)
│   ├── test/               # Forge tests (14 .t.sol)
│   └── foundry.toml        # solc 0.8.30, cancun, via_ir
├── configs/                # Contract configs (20 .yul2venom.json)
├── output/                 # Generated: *.yul, *.vnm, *.bin
├── testing/                # Test utilities (17 files)
│   ├── test_framework.py   # Batch transpilation
│   ├── inspect_bytecode.py # Bytecode disassembler
│   └── vyper_ir_helper.py  # Native Vyper IR (needs global vyper)
├── debug/                  # Debug artifacts
│   ├── raw_ir.vnm          # Pre-optimization IR
│   ├── opt_ir.vnm          # Post-optimization IR
│   └── research_package/   # Bug investigation
└── docs/                   # REFERENCE.md, STATUS.md
```

## Critical Concepts

### 1. Parser Operand Reversal (CRITICAL)

`vyper/venom/parser.py:262-263`:
```python
elif opcode not in ("jmp", "jnz", "djmp", "phi"):
    operands.reverse()
```

**Effect**: Text `add a, b` → internal `[b, a]`. Design for native Vyper path.

**Exceptions** (NOT reversed): `jmp`, `jnz`, `djmp`, `phi`

### 2. Memory Layout

| Zone | Address | Purpose |
|------|---------|---------|
| FMP Slot | `0x40` | Free Memory Pointer |
| FMP Value | `0x1000` | Memory Bridge offset |
| Venom | `0x00-0x1000` | Static allocations |
| Yul heap | `0x1000+` | Dynamic allocations |

**Memory Bridge**: `mstore(0x1000, 64)` initializes FMP above Venom region.

### 3. Function Calling Convention (invoke/ret)

```
Caller: PUSHLABEL ret_addr, PUSHLABEL func, JUMP
Callee: %arg = param, %pc = param (PC LAST)
Return: ret %pc, %result (PC first in text → last after reversal)
```

### 4. NO_OUTPUT_INSTRUCTIONS

`ir/basicblock.py` defines instructions that don't produce output:
`jmp`, `jnz`, `ret`, `revert`, `stop`, `return`, `selfdestruct`, `log*`, `mstore*`, `sstore`, `invoke`

## Commands

```bash
# Transpile
python3.11 yul2venom.py prepare foundry/src/Contract.sol
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json

# Tests
cd foundry && forge test
cd foundry && forge test --match-test "test_name" -vvvv

# Batch transpile
python3.11 testing/test_framework.py --transpile-all

# Debug
cat debug/raw_ir.vnm    # Before optimization
cat debug/opt_ir.vnm    # After optimization
```

## Common Issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| `InvalidJump` | ret operand order | PC first in text: `ret %pc, %val` |
| Return always 0 | invoke output not captured | Use `ret=variable` |
| Variable not in stack | SSA/assign issue | Check assign handling |
| Loop exits early | lt/gt operand order | Verify comparison operand order |
| Stack underflow | Param count mismatch | Check invoke param count |

## Test Pattern

```solidity
// foundry/test/ContractTest.t.sol
function setUp() public {
    bytes memory code = vm.readFileBinary("output/Contract_opt_runtime.bin");
    target = address(0x1234);
    vm.etch(target, code);  // Deploy transpiled bytecode
}
```

## 🎯 Goal: Venom-Native IR

**The goal is to generate IR that looks like native Vyper IR.**

The Vyper backend is designed for IR produced by Vyper's own `ir_node_to_venom.py`. Our transpiler must produce IR that matches those patterns exactly.

### ⚠️ CRITICAL: Transpiler Fixes Over Backend Patches

```
❌ WRONG: Bug in transpiler → patch backend to handle buggy IR
✅ RIGHT: Bug in transpiler → fix transpiler to emit correct IR
```

**Why this matters:**
- Backend patches mask transpiler bugs
- Masked bugs compound over time
- Eventually backend becomes unmaintainable
- Native Vyper contracts may break from our patches

**Rule**: If backend produces wrong output, the bug is almost always in `venom_generator.py`. Fix the transpiler, not the backend.

---

## Key Rules

1. **Transpiler fixes > Backend patches** - Backend designed for native Vyper
2. **Check parser reversal** - Most bugs are operand order
3. **Debug files exist** - `debug/raw_ir.vnm`, `debug/opt_ir.vnm` for inspection
4. **Config paths are relative** - All paths relative to yul2venom root
5. **Python 3.11+ required** - Uses match/case syntax
6. **Never hardcode bytecode** - Always `vm.readFileBinary()`
7. **One function at a time** - Focus, verify, move on

---

## Test Status

40/40 tests passing ✅

---

## Development Workflow (Self-Prompting)

### Session Start Protocol

1. **Read docs first**: This file, `docs/REFERENCE.md`, `docs/STATUS.md`
2. **Check Vyper internals**: Understand `vyper/venom/parser.py` operand reversal
3. **Diff local fork**: `cd vyper && git diff origin/master -- vyper/venom/`
4. **Understand pipeline**: `yul2venom.py` → `venom_generator.py` → `run_venom.py`

### Incremental Development Loop

**Principle**: Slow complexity increase → verify → test → fix → repeat

```
1. RANK contracts from simple → complex
2. FOR EACH contract (simplest first):
   a. Generate Yul:     python3.11 yul2venom.py prepare foundry/src/X.sol
   b. Transpile:        python3.11 yul2venom.py transpile configs/X.yul2venom.json
   c. INSPECT VNM:      Check debug/raw_ir.vnm - does it make sense?
   d. UPDATE test:      Use vm.readFileBinary() - NEVER hardcode bytecode
   e. RUN test:         cd foundry && forge test --match-contract X -vvvv
   f. IF FAIL:
      - Check debug/raw_ir.vnm (pre-opt)
      - Check debug/opt_ir.vnm (post-opt)  
      - Check venom_generator.py for transpilation bug
      - Check parser operand reversal
   g. FIX TRANSPILER (not backend)
   h. REPEAT from step b
3. MOVE to next contract
```

### Complexity Ranking

| Rank | Contract | Features |
|------|----------|----------|
| 1 | SimpleAdd | Pure arithmetic |
| 2 | ConstantTest | Constants, returns |
| 3 | OpcodeBasics | All EVM opcodes |
| 4 | LoopCheck | For loops |
| 5 | StorageMemory | Storage + memory |
| 6 | MegaTest | All features combined |

### Debug Investigation Order

1. **Yul source** → Is the Yul correct?
2. **debug/raw_ir.vnm** → Is transpilation correct?
3. **debug/opt_ir.vnm** → Did optimization break it?
4. **Bytecode execution** → What's the runtime behavior?

### Two Vyper Installations

| Installation | Use For |
|--------------|---------|
| Local fork (`vyper/`) | Backend modifications, pass changes |
| Global (`pipx install vyper`) | Reference IR from native Vyper contracts |

```bash
# Generate reference IR from native Vyper
vyper -f ir testing/vyper_test.vy > debug/native_vyper/reference.ir
```

### Focus: Runtime Only

Current strategy: **Skip init bytecode, focus on runtime transpilation.**

- Init bytecode has separate complexities (constructor args, immutables)
- Runtime is the core value - contract logic
- Future: Add init bytecode support after runtime is robust
