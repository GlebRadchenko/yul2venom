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
| `yul2venom.py` (49KB) | CLI entry. Commands: `prepare`, `transpile` | Adding CLI features |
| `venom_generator.py` (79KB) | **Core transpiler**. Yul AST → Venom IR | Fixing transpilation bugs |
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
│   ├── src/                # Solidity contracts
│   │   └── bench/          # 8 benchmark contracts (Arithmetic, ControlFlow, etc.)
│   ├── test/               # Forge tests
│   │   └── bench/          # Benchmark test suites
│   └── foundry.toml        # solc 0.8.30, cancun, via_ir
├── configs/                # Contract configs
│   └── bench/              # Benchmark configs (8 files)
├── tools/                  # Benchmark & debug tools
│   ├── benchmark.py        # Production benchmark tool
│   ├── benchmark.sh        # Quick benchmark script
│   ├── benchmark.example.yaml  # Config template
│   └── evm_tracer.py       # Step-by-step EVM tracer
├── testing/                # Test utilities (18 files)
│   ├── test_framework.py   # Batch transpilation/testing
│   ├── inspect_bytecode.py # Bytecode disassembler
│   ├── debug_liveness.py   # Liveness analysis debug
│   ├── trace_stack.py      # Stack state tracing
│   ├── trace_memory.py     # Memory operation tracing
│   └── *.vy                # Vyper reference contracts
├── output/                 # Generated: *.yul, *.vnm, *.bin
│   └── bench/              # Benchmark outputs
├── debug/                  # Debug artifacts
│   ├── raw_ir.vnm          # Pre-optimization IR
│   ├── opt_ir.vnm          # Post-optimization IR
│   └── assembly.asm        # Generated assembly
└── docs/                   # REFERENCE.md, STATUS.md
```

## Commands

### Core Transpilation

```bash
# Prepare: Extract Yul from Solidity
python3.11 yul2venom.py prepare foundry/src/Contract.sol

# Transpile: Yul → Venom → Bytecode
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json

# Transpile with runtime-only output (for testing via vm.etch)
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json --runtime-only

# Optimization levels: none, O0, O2 (default), O3, Os, native, debug
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json --optimize native
```

### Testing

```bash
# Run all tests
cd foundry && forge test

# Run specific test with verbose output
cd foundry && forge test --match-test "test_name" -vvvv

# Run tests excluding benchmarks
cd foundry && forge test --no-match-path "test/bench/*"

# Batch transpile all configs
cd testing && python3.11 test_framework.py --transpile-all

# Full pipeline (transpile + test)
cd testing && python3.11 test_framework.py --full
```

### Benchmarking

```bash
# Run benchmark with default settings (8 contracts, default/ir_optimized modes)
python3.11 tools/benchmark.py

# Use custom config
python3.11 tools/benchmark.py --config tools/benchmark.yaml

# Specify contracts and modes
python3.11 tools/benchmark.py --contracts "Arithmetic,ControlFlow" --modes "default,ir_optimized"

# With gas benchmarking (slower, runs Forge tests)
python3.11 tools/benchmark.py --gas

# Output options
python3.11 tools/benchmark.py --output my_report.md --json my_data.json
```

### Debugging

```bash
# Inspect debug IR
cat debug/raw_ir.vnm    # Before optimization
cat debug/opt_ir.vnm    # After optimization
cat debug/assembly.asm  # Generated assembly

# EVM tracer - step through bytecode execution
python3.11 tools/evm_tracer.py output/Contract_opt_runtime.bin [calldata_hex]

# Bytecode disassembler
python3.11 testing/inspect_bytecode.py output/Contract_opt.bin --limit 100

# Stack tracing
python3.11 testing/trace_stack.py debug/raw_ir.vnm --blocks "loop_start,loop_end"

# Memory tracing
python3.11 testing/trace_memory.py debug/raw_ir.vnm
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
| FMP Value | `0x1000` | Memory Bridge offset |
| Venom | `0x00-0x1000` | Static allocations |
| Yul heap | `0x1000+` | Dynamic allocations |

**Memory Bridge**: `mstore(0x1000, 64)` initializes FMP above Venom region.

### 3. Loop Continue Statement Handling

For loops with `continue` statements require special phi handling:

```
Loop Structure:
  loop_start:     phi nodes for loop-carried variables
  loop_body:      ... if condition { continue } ...
  loop_post:      phi nodes to merge body-end + continue paths
  → back to loop_start
```

The `loop_stack` tracks continue sources as a 5-tuple:
`(start_label, end_label, post_label, continue_sources[], phi_results)`

### 4. NO_OUTPUT_INSTRUCTIONS

`ir/basicblock.py` defines instructions that don't produce output:
`jmp`, `jnz`, `ret`, `revert`, `stop`, `return`, `selfdestruct`, `log*`, `mstore*`, `sstore`, `invoke`

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

## Test Pattern

```solidity
// foundry/test/ContractTest.t.sol
function setUp() public {
    bytes memory code = vm.readFileBinary("output/Contract_opt.bin");
    target = address(0x1234);
    vm.etch(target, code);  // Deploy transpiled bytecode
}
```

---

## Tools Reference

### benchmark.py

Production-grade benchmarking tool comparing transpiled bytecode against Solc configurations.

**Features:**
- Compares Yul2Venom output vs Solc (default, via_ir, ir_optimized)
- Multiple optimization run counts (0, 200, 20000, 1000000)
- Bytecode size comparison with delta percentages
- Optional gas usage benchmarking via Forge tests
- Markdown + JSON output

**Configuration (`benchmark.example.yaml`):**
```yaml
contracts:
  - Arithmetic
  - ControlFlow
  - StateManagement
  - DataStructures
  - Functions
  - Events
  - Encoding
  - Edge

optimization_runs: [0, 200, 20000, 1000000]
solc_modes: [default, via_ir]
baseline: default_200
```

### evm_tracer.py

Minimal EVM tracer for debugging bytecode execution step-by-step.

**Output includes:**
- Program counter
- Opcode name
- Stack state (before/after)
- Memory writes

**Usage:**
```bash
python3.11 tools/evm_tracer.py output/Contract_opt_runtime.bin
python3.11 tools/evm_tracer.py output/Contract_opt_runtime.bin 0x12345678  # with calldata
```

### test_framework.py

Batch transpilation and testing framework.

**Commands:**
```bash
--transpile-all    # Transpile all configs
--verify-all       # Run Forge tests
--analyze <vnm>    # Analyze VNM file
--compare <a> <b>  # Compare two VNM files
--full             # Full pipeline test
```

---

## Benchmark Contracts (foundry/src/bench/)

| Contract | Features |
|----------|----------|
| `Arithmetic.sol` | Safe/unsafe math, comparisons, bitwise ops |
| `ControlFlow.sol` | Loops, conditionals, break/continue, switch |
| `StateManagement.sol` | Storage, memory, constants, immutables, transient |
| `DataStructures.sol` | Arrays, structs, nested structs, mappings |
| `Functions.sol` | Calls, recursion, inheritance, delegatecall |
| `Events.sol` | Simple, indexed, complex events |
| `Encoding.sol` | ABI encode/decode, hashing |
| `Edge.sol` | Enums, reverts, try-catch, create/create2 |

---

## 🎯 Goal: Venom-Native IR

**The goal is to generate IR that looks like native Vyper IR.**

### ⚠️ CRITICAL: Transpiler Fixes Over Backend Patches

```
❌ WRONG: Bug in transpiler → patch backend to handle buggy IR
✅ RIGHT: Bug in transpiler → fix transpiler to emit correct IR
```

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

**79/79 tests passing ✅**

- 19/19 configs transpile successfully
- All benchmark contracts supported
- Continue statement handling fixed (2026-01-31)

---

## Development Workflow (Self-Prompting)

### Session Start Protocol

1. **Read docs first**: This file, `docs/REFERENCE.md`, `docs/STATUS.md`
2. **Check test status**: `cd testing && python3.11 test_framework.py --transpile-all`
3. **Check Vyper internals**: Understand `vyper/venom/parser.py` operand reversal
4. **Diff local fork**: `cd vyper && git diff origin/master -- vyper/venom/`
5. **Understand pipeline**: `yul2venom.py` → `venom_generator.py` → `run_venom.py`

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
| 7 | Benchmark Suite | 8 contracts, all features |

### Debug Investigation Order

1. **Yul source** → Is the Yul correct?
2. **debug/raw_ir.vnm** → Is transpilation correct?
3. **debug/opt_ir.vnm** → Did optimization break it?
4. **Bytecode execution** → Use `tools/evm_tracer.py`

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
