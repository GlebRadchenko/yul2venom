# Yul2Venom: AI Agent Context

> **Read FIRST. Condensed reference for AI agents.**

## Project Overview

**Yul2Venom**: Yul → Venom IR transpiler. Uses Vyper's backend for Solidity bytecode.

```
Solidity → solc --ir-optimized → Yul → Yul2Venom → Venom IR → Vyper backend → EVM
```

**Status**: 339/339 tests passing ✅ | Full init bytecode support | 15 benchmark contracts

---

## Package Structure (Priority Order)

| Package | Role | Modify When |
|---------|------|-------------|
| `yul2venom.py` (57KB) | CLI entry: `prepare`, `transpile` | Adding CLI features |
| `generator/venom_generator.py` (92KB) | **Core transpiler** (Yul AST → Venom IR) | Transpilation bugs |
| `generator/optimizations.py` (32KB) | Venom-level optimizations | Adding patterns |
| `optimizer/yul_source_optimizer.py` (21KB) | Pre-transpilation Yul optimization | Yul patterns |
| `parser/yul_parser.py` (14KB) | Yul → Python AST (lark-based) | Parser issues |
| `parser/yul_extractor.py` | Deployed object extraction | Extraction bugs |
| `backend/run_venom.py` | VNM → bytecode via Vyper | Backend invocation |
| `core/pipeline.py` | Orchestration, config loading | Pipeline changes |
| `ir/*.py` | Local IR types: BasicBlock, IRInstruction | Adding opcodes |

### Vyper Fork (`vyper/`) — Critical Patches

**Branch**: `yul2venom` (commit 798d288f)  
**Patches**: See [docs/VENOM_CHANGES.md](docs/VENOM_CHANGES.md) for full audit.

| File | Patch Purpose | Revert Risk |
|------|--------------|-------------| 
| `vyper/venom/analysis/liveness.py` | Phi operand ordering fix | ⚠️ Critical |
| `vyper/venom/effects.py` | Register log0-4 effects | ⚠️ Critical |
| `vyper/venom/venom_to_assembly.py` | Yul opcodes, duplicate literals, assign fix | ⚠️ Critical |
| `vyper/venom/parser.py` | **REVERSES OPERANDS** (read-only) | N/A |

---

## Commands

### Core Transpilation
```bash
# Prepare: Extract Yul from Solidity
python3.11 yul2venom.py prepare foundry/src/Contract.sol

# Transpile: Yul → Venom → Bytecode
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json

# Runtime-only (for vm.etch tests)
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json --runtime-only

# Full init bytecode (for deployment)
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json --with-init

# Yul optimizer levels: safe, standard, aggressive, maximum
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json --yul-opt-level=aggressive

# Venom IR levels: none, O0, O2 (default), O3, Os, native
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json -O native
```

### Testing

> **⚠️ CRITICAL: Always retranspile before testing!**
> 
> `forge test` loads bytecode from `output/*.bin` files. If you don't retranspile after code changes, you're testing stale binaries!

```bash
# CORRECT: Full pipeline (transpiles + tests) - ALWAYS USE THIS
python3.11 testing/test_framework.py --test-all

# Batch transpilation only (without tests)
python3.11 testing/test_framework.py --transpile-all

# If you must use forge directly, retranspile first:
python3.11 testing/test_framework.py --transpile-all && cd foundry && forge test

# Targeted testing
cd foundry && forge test --match-path "test/bench/*"     # Bench tests only
cd foundry && forge test --match-path "test/init/*"      # Init tests only
cd foundry && forge test --match-test "test_getValue"    # Single test
cd foundry && forge test --match-test "name" -vvvv       # Verbose
```

### Regression Testing Workflow

**When making changes to `venom_generator.py` or core transpiler code:**

```bash
# 1. Start from clean state (stash or commit current changes)
git stash --include-untracked

# 2. Verify baseline: All 339 tests should pass
python3.11 testing/test_framework.py --test-all

# 3. Apply changes ONE AT A TIME and test
git stash pop  # or apply your changes incrementally

# 4. Test after EACH change
python3.11 testing/test_framework.py --test-all

# 5. If tests fail, investigate immediately - don't stack changes
```

**Config/Test counts:**
- `configs/` = 21 core configs
- `configs/bench/` = 15 bench configs  
- `configs/init/` = 10 init configs
- **Total: 46 configs, 339 tests**

### Debugging
```bash
cat debug/raw_ir.vnm    # Pre-optimization IR
cat debug/opt_ir.vnm    # Post-optimization IR
cat debug/assembly.asm  # Generated assembly
python3.11 tools/evm_tracer.py output/Contract_opt_runtime.bin [calldata]
python3.11 testing/inspect_bytecode.py output/Contract_opt.bin --limit 100
```

---

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
| FMP Value | `0x100` | Memory Bridge offset |
| Venom | `0x00-0x100` | Static allocations |
| Yul heap | `0x100+` | Dynamic allocations |

**Memory Bridge**: `mstore(0x100, 64)` initializes FMP above Venom region.

### 3. Loop Continue Statement Handling

For loops with `continue` require special phi handling:
```
loop_start:   phi nodes for loop-carried variables
loop_body:    ... if condition { continue } ...
loop_post:    phi nodes to merge body-end + continue paths
→ back to loop_start
```
The `loop_stack` tracks continue sources as 5-tuple: `(start, end, post, continue_sources[], phi_results)`

### 4. NO_OUTPUT_INSTRUCTIONS

`ir/basicblock.py` defines instructions without output:
`jmp`, `jnz`, `ret`, `revert`, `stop`, `return`, `selfdestruct`, `log*`, `mstore*`, `sstore`, `invoke`

### 5. Yul Optimizer Levels

| Level | Effect |
|-------|--------|
| `safe` | Remove validators, empty blocks, algebraic simplifications |
| `standard` | + Strip callvalue, calldatasize checks |
| `aggressive` | + Strip extcodesize, returndatasize, memory allocation checks |
| `maximum` | + Strip overflow, bounds checks (**DANGEROUS**) |

---

## Common Issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| `InvalidJump` | ret operand order | PC first in text: `ret %pc, %val` |
| Return always 0 | invoke output not captured | Use `ret=variable` |
| Variable not in stack | SSA/assign issue | Check assign handling |
| Loop exits early | lt/gt operand order | Verify comparison operand order |
| Stack underflow | Param count mismatch | Check invoke param count |
| Undefined var in loop | Continue skips definition | Check continue_sources handling |
| Semantic error in check_venom_ctx | Phi incomplete | Check phi back-patching |

---

## Directory Structure

```
yul2venom/
├── yul2venom.py           # Main CLI
├── parser/                # YulParser, YulExtractor
├── generator/             # VenomIRBuilder, optimizations
├── optimizer/             # YulSourceOptimizer
├── backend/               # run_venom (Vyper backend)
├── core/                  # Pipeline, errors
├── ir/                    # IRContext, BasicBlock, etc.
├── utils/                 # Constants, logging
├── tools/                 # benchmark.py, evm_tracer.py
├── testing/               # test_framework.py, debug utils
├── configs/               # Contract configs
│   ├── *.yul2venom.json   # Core (21 configs)
│   ├── bench/             # Benchmark (15 configs)
│   └── init/              # Init bytecode (10 configs)
├── foundry/               # Solidity contracts and tests
│   ├── src/bench/         # 15 benchmark contracts
│   ├── src/init/          # 10 init test contracts
│   └── test/              # Forge tests
├── output/                # Generated: *.yul, *.vnm, *.bin
├── debug/                 # raw_ir.vnm, opt_ir.vnm, assembly.asm
└── vyper/                 # Vyper fork (submodule)
```

---

## Tools Reference

### benchmark.py
Compares transpiled bytecode against Solc configurations.
```bash
python3.11 tools/benchmark.py --output report.md --json data.json
python3.11 tools/benchmark.py --contracts "Arithmetic,ControlFlow"
```

### evm_tracer.py
Step-by-step EVM execution tracer (PC, opcode, stack, memory).
```bash
python3.11 tools/evm_tracer.py output/Contract_opt_runtime.bin 0x12345678
```

### test_framework.py
Batch transpilation and testing.
```bash
--test-all         # Transpile all + run Forge tests
--transpile-all    # Transpile all configs
--init-all         # Transpile init configs with --with-init
--test-init        # Run init bytecode tests
--analyze <vnm>    # Analyze VNM file
--compare <a> <b>  # Compare two VNM files
```

---

## Development Workflow (Self-Prompting)

### Session Start Protocol

1. **Read docs**: This file, `docs/REFERENCE.md`, `docs/VENOM_CHANGES.md`
2. **Check status**: `python3.11 testing/test_framework.py --test-all`
3. **Check Vyper**: Understand parser operand reversal and Vyper patches
4. **Verify branch**: `cd vyper && git log -1 --oneline` (expect `yul-optimization`)

### Incremental Development Loop

**Principle**: Slow complexity increase → verify → test → fix → repeat

```
1. FOR EACH contract (simplest first):
   a. Generate Yul:     python3.11 yul2venom.py prepare foundry/src/X.sol
   b. Transpile:        python3.11 yul2venom.py transpile configs/X.yul2venom.json
   c. INSPECT VNM:      cat debug/raw_ir.vnm - does it make sense?
   d. RUN test:         cd foundry && forge test --match-contract X -vvvv
   e. IF FAIL:
      - Check debug/raw_ir.vnm (pre-opt)
      - Check debug/opt_ir.vnm (post-opt)
      - Check generator/venom_generator.py for transpilation bug
      - Check parser operand reversal
   f. FIX TRANSPILER (not backend)
   g. REPEAT from step b
2. MOVE to next contract
```

### Complexity Ranking

| Rank | Contract | Features |
|------|----------|----------|
| 1 | SimpleAdd | Pure arithmetic |
| 2 | ConstantTest | Constants, returns |
| 3 | OpcodeBasics | All EVM opcodes |
| 4 | LoopCheck | For loops |
| 5 | StorageMemory | Storage + memory |
| 6 | MegaTest | All features |
| 7 | Benchmark Suite | 15 contracts |
| 8 | Init Bytecode | 10 constructor patterns |

### Debug Investigation Order

1. **Yul source** → Is the Yul correct?
2. **debug/raw_ir.vnm** → Is transpilation correct?
3. **debug/opt_ir.vnm** → Did optimization break it?
4. **tools/evm_tracer.py** → Bytecode execution trace

### Two Vyper Installations

| Installation | Use For |
|--------------|---------|
| Local fork (`vyper/`) | Backend mods, pass changes |
| Global (`pipx install vyper`) | Reference IR from native Vyper |

```bash
vyper -f ir testing/vyper_test.vy > debug/native_vyper/reference.ir
```

---

## 🎯 Goal: Venom-Native IR

**Generate IR that looks like native Vyper IR.**

### ⚠️ CRITICAL: Transpiler Fixes Over Backend Patches

```
❌ WRONG: Bug in transpiler → patch backend to handle buggy IR
✅ RIGHT: Bug in transpiler → fix transpiler to emit correct IR
```

**Rule**: If backend produces wrong output, bug is almost always in `generator/venom_generator.py`.

---

## Key Rules

1. **Transpiler fixes > Backend patches** — Backend designed for native Vyper
2. **Check parser reversal** — Most bugs are operand order
3. **Debug files exist** — `debug/raw_ir.vnm`, `debug/opt_ir.vnm`
4. **Config paths are relative** — All paths relative to yul2venom root
5. **Python 3.11+ required** — Uses match/case syntax
6. **Never hardcode bytecode** — Always `vm.readFileBinary()`
7. **One function at a time** — Focus, verify, move on
