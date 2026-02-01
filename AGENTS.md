# Yul2Venom: AI Agent Context

> **Read FIRST. Condensed reference for AI agents.**

## Project Overview

**Yul2Venom**: Yul → Venom IR transpiler. Uses Vyper's backend for Solidity bytecode.

```
Solidity → solc --ir-optimized → Yul → Yul2Venom → Venom IR → Vyper backend → EVM
```

**Status**: 223/223 tests passing ✅ | 9/9 benchmark contracts smaller than Solc (with `--yul-opt-level=aggressive`)

---

## File Roles (Priority Order)

| File | Role | Modify When |
|------|------|-------------|
| `yul2venom.py` (51KB) | CLI entry: `prepare`, `transpile` | Adding CLI features |
| `venom_generator.py` (79KB) | **Core transpiler** (Yul AST → Venom IR) | Transpilation bugs |
| `yul_source_optimizer.py` (19KB) | Pre-transpilation Yul optimization | Adding patterns |
| `yul_parser.py` (14KB) | Yul → Python AST (lark-based) | Parser issues |
| `run_venom.py` | VNM → bytecode via Vyper | Backend invocation |
| `ir/*.py` | Local IR types: BasicBlock, IRInstruction | Adding opcodes |

### Vyper Fork (`vyper/`) — Avoid Modifying

| File | Role | Modify? |
|------|------|---------| 
| `vyper/venom/parser.py` | VNM text → IRContext. **REVERSES OPERANDS** | Read-only |
| `vyper/venom/venom_to_assembly.py` | IR → EVM assembly | Avoid |
| `vyper/venom/passes/*.py` | Optimization passes | DCE disabled here |
| `vyper/venom/analysis/liveness.py` | Liveness analysis | Phi ordering fix here |

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

# Yul optimizer levels: safe, standard, aggressive, maximum
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json --yul-opt-level=aggressive

# Venom IR levels: none, O0, O2 (default), O3, Os, native
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json -O native
```

### Testing
```bash
python3.11 testing/test_framework.py --test-all   # Full pipeline
cd foundry && forge test                          # Run Forge tests
cd foundry && forge test --match-test "name" -vvvv  # Verbose single test
```

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

## Benchmark Results (2026-02-01)

With `--yul-opt-level=aggressive` vs Solidity O3:

| Contract | Solc | Yul2Venom | Delta |
|----------|------|-----------|-------|
| Arithmetic | 1660 | 1596 | **-4%** |
| ControlFlow | 1223 | 998 | **-18%** |
| StateManagement | 4434 | 2690 | **-39%** |
| DataStructures | 2072 | 1874 | **-10%** |
| Functions | 3640 | 2705 | **-26%** |
| Events | 1066 | 778 | **-27%** |
| Encoding | 1421 | 1412 | **-1%** |
| Edge | 4476 | 2801 | **-37%** |

---

## 🎯 Goal: Venom-Native IR

**Generate IR that looks like native Vyper IR.**

### ⚠️ CRITICAL: Transpiler Fixes Over Backend Patches

```
❌ WRONG: Bug in transpiler → patch backend to handle buggy IR
✅ RIGHT: Bug in transpiler → fix transpiler to emit correct IR
```

**Rule**: If backend produces wrong output, bug is almost always in `venom_generator.py`.

---

## Key Rules

1. **Transpiler fixes > Backend patches** — Backend designed for native Vyper
2. **Check parser reversal** — Most bugs are operand order
3. **Debug files exist** — `debug/raw_ir.vnm`, `debug/opt_ir.vnm`
4. **Config paths are relative** — All paths relative to yul2venom root
5. **Python 3.11+ required** — Uses match/case syntax
6. **Never hardcode bytecode** — Always `vm.readFileBinary()`
7. **One function at a time** — Focus, verify, move on

---

## Directory Structure

```
yul2venom/
├── *.py                    # Core transpiler (7 files)
├── ir/                     # Local IR types
├── vyper/                  # Vyper fork (submodule)
├── foundry/src/            # Solidity contracts
│   └── bench/              # 8 benchmark contracts
├── foundry/test/           # Forge tests
├── configs/bench/          # Benchmark configs
├── tools/                  # benchmark.py, evm_tracer.py
├── testing/                # test_framework.py, debug utils
├── output/                 # Generated: *.yul, *.vnm, *.bin
└── debug/                  # raw_ir.vnm, opt_ir.vnm, assembly.asm
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
--analyze <vnm>    # Analyze VNM file
--compare <a> <b>  # Compare two VNM files
```

---

## Development Workflow (Self-Prompting)

### Session Start Protocol

1. **Read docs**: This file, `docs/REFERENCE.md`, `docs/STATUS.md`
2. **Check status**: `python3.11 testing/test_framework.py --test-all`
3. **Check Vyper**: Understand `vyper/venom/parser.py` operand reversal
4. **Diff fork**: `cd vyper && git diff origin/master -- vyper/venom/`

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
      - Check venom_generator.py for transpilation bug
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
| 7 | Benchmark Suite | 8 contracts |

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

### Focus: Runtime Only

Current strategy: **Skip init bytecode, focus on runtime transpilation.**
- Init has separate complexities (constructor args, immutables)
- Runtime is the core value - contract logic
- Future: Add init support after runtime is robust
