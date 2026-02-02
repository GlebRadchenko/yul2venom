# Yul2Venom Tooling Overview

Complete reference for all Yul2Venom tools, utilities, and debugging aids.

---

## Table of Contents

1. [Core CLI](#core-cli)
2. [Test Framework](#test-framework)
3. [Benchmark Tool](#benchmark-tool)
4. [Debug Tools](#debug-tools)
5. [Utility Modules](#utility-modules)
6. [Workflow Examples](#workflow-examples)

---

## Core CLI

### yul2venom.py

Main entry point for transpilation.

#### Commands

```bash
# Prepare: Compile Solidity → Yul + create config template
python3.11 yul2venom.py prepare foundry/src/Contract.sol

# Transpile: Yul → Venom IR → EVM bytecode
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json
```

#### Transpile Options

| Flag | Description |
|------|-------------|
| `--runtime-only` | Output runtime bytecode only (for `vm.etch` testing) |
| `--with-init` | Output full init+runtime bytecode (for deployment) |
| `-O LEVEL` | Venom optimization: `none`, `O0`, `O2` (default), `O3`, `Os`, `native` |
| `--yul-opt` | Enable Yul source optimizer |
| `--yul-opt-level LEVEL` | Yul optimizer level: `safe`, `standard`, `aggressive`, `maximum` |
| `--dump-ir` | Dump intermediate Venom IR to `debug/` |
| `-o DIR` | Output directory (default: `output/`) |

#### Yul Optimizer Levels

| Level | Effect |
|-------|--------|
| `safe` | Remove dead validators, empty blocks, algebraic simplifications |
| `standard` | + Strip callvalue, calldatasize checks |
| `aggressive` | + Strip extcodesize, returndatasize, memory allocation checks |
| `maximum` | + Strip overflow, bounds checks (**DANGEROUS** - removes safety) |

#### Examples

```bash
# Standard transpilation
python3.11 yul2venom.py transpile configs/Arithmetic.yul2venom.json

# Runtime-only for vm.etch testing
python3.11 yul2venom.py transpile configs/Arithmetic.yul2venom.json --runtime-only

# Full init bytecode for deployment
python3.11 yul2venom.py transpile configs/init/InitCodeTest.yul2venom.json --with-init

# Aggressive optimization
python3.11 yul2venom.py transpile configs/Arithmetic.yul2venom.json --yul-opt-level=aggressive -O native

# Debug mode with IR dump
python3.11 yul2venom.py transpile configs/Arithmetic.yul2venom.json --dump-ir -O O0
```

---

## Test Framework

### testing/test_framework.py

Batch transpilation, analysis, and testing.

#### Commands

| Flag | Description |
|------|-------------|
| `--prepare-all` | Compile all Solidity → Yul |
| `--transpile-all` | Transpile all configs (core + bench) |
| `--init-all` | Transpile init configs with `--with-init` |
| `--test-all` | Full pipeline: transpile + run Forge tests |
| `--test-core` | Run core tests only (exclude bench) |
| `--test-bench` | Run benchmark tests only |
| `--test-init` | Run init bytecode tests |
| `--analyze <vnm>` | Analyze a Venom IR file |
| `--compare <a> <b>` | Compare two VNM files |
| `--full` | Full pipeline with verbose output |

#### Examples

```bash
# Full pipeline (transpile all + test all)
python3.11 testing/test_framework.py --test-all

# Just transpile all configs
python3.11 testing/test_framework.py --transpile-all

# Transpile init bytecode configs
python3.11 testing/test_framework.py --init-all

# Run only init tests
python3.11 testing/test_framework.py --test-init

# Analyze a specific VNM file
python3.11 testing/test_framework.py --analyze debug/opt_ir.vnm

# Compare two VNM files for differences
python3.11 testing/test_framework.py --compare debug/raw_ir.vnm debug/opt_ir.vnm
```

#### Analysis Output

When using `--analyze`, you get:
- Block count
- Phi node count and details
- Memory operations (mstore/mload counts)
- Loop detection
- Identity operations (potential bugs)

---

## Benchmark Tool

### tools/benchmark.py

Production-grade benchmarking comparing transpiled bytecode against Solc.

#### Basic Usage

```bash
# Run with defaults (all 15 benchmark contracts)
python3.11 tools/benchmark.py

# Specific contracts only
python3.11 tools/benchmark.py --contracts "Arithmetic,ControlFlow,StateManagement"

# Custom optimization runs
python3.11 tools/benchmark.py --runs 200,20000,1000000

# Output to specific files
python3.11 tools/benchmark.py --output report.md --json data.json

# Use a profile
python3.11 tools/benchmark.py --config tools/profiles/aggressive.yaml
```

#### Profile System

YAML profiles in `tools/profiles/`:

| Profile | Description |
|---------|-------------|
| `safe.yaml` | Minimal contracts, basic comparison |
| `full.yaml` | All contracts, all optimization runs |
| `aggressive.yaml` | With Yul optimizer, all modes |

#### Example Profile

```yaml
# tools/profiles/full.yaml
contracts:
  - Arithmetic
  - ControlFlow
  - StateManagement
  - DataStructures
  - Functions
  - Events
  - Encoding
  - Edge

optimization_runs:
  - 0
  - 200
  - 20000
  - 1000000

solc_modes:
  - default
  - via_ir

baseline: default_200
report_file: benchmark_report.md
json_file: benchmark_data.json
```

#### Output

Generates:
1. **Markdown report** - Size comparison tables, deltas vs baseline
2. **JSON data** - Raw numbers for further analysis

---

## Debug Tools

### tools/evm_tracer.py

Step-by-step EVM execution tracer.

```bash
# Basic execution trace
python3.11 tools/evm_tracer.py output/Contract_opt_runtime.bin

# With calldata
python3.11 tools/evm_tracer.py output/Contract_opt_runtime.bin 0x12345678

# Limit steps
python3.11 tools/evm_tracer.py output/Contract_opt.bin --max-steps 100
```

**Output includes:**
- Program counter
- Opcode name
- Stack state (before/after)
- Memory writes
- Storage operations

### testing/inspect_bytecode.py

EVM bytecode disassembler.

```bash
# Disassemble with default output
python3.11 testing/inspect_bytecode.py output/Contract_opt.bin

# Limit instructions
python3.11 testing/inspect_bytecode.py output/Contract_opt.bin --limit 100

# Hex-encoded input file
python3.11 testing/inspect_bytecode.py output/Contract.hex --hex
```

**Output:**
```
Disassembling 2163 bytes from output/Contract_opt.bin
--------------------------------------------------
0000: PUSH1 0x80
0002: PUSH1 0x40
0004: MSTORE
0005: CALLVALUE
0006: DUP1
...
```

### testing/trace_stack.py

Analyze stack state through Venom IR basic blocks.

```bash
# Default patterns (loop, end_if, then, else)
python3.11 testing/trace_stack.py debug/opt_ir.vnm

# Custom block patterns
python3.11 testing/trace_stack.py debug/opt_ir.vnm --blocks "loop,merge,exit"

# Quiet mode (just summary)
python3.11 testing/trace_stack.py debug/opt_ir.vnm --quiet
```

**Use case:** Debugging loop variable liveness across control flow edges.

### testing/trace_memory.py

Analyze memory operations in Venom IR.

```bash
# Full analysis
python3.11 testing/trace_memory.py debug/raw_ir.vnm

# Quiet mode
python3.11 testing/trace_memory.py debug/raw_ir.vnm --quiet
```

**Output includes:**
- Block count
- Memory store operations (mstore)
- Phi nodes
- Identity operations (`add x, 0` patterns)
- Increment operations

### testing/debug_liveness.py

Variable liveness analysis for Venom IR debugging.

```bash
# Analyze first function
python3.11 testing/debug_liveness.py debug/opt_ir.vnm

# Specific function
python3.11 testing/debug_liveness.py debug/opt_ir.vnm --function fun_checkConfig
```

**Output:**
- Live-in variables per block
- Live-out variables per block
- Edge-specific liveness

### testing/export_bytecode.py

Compile Yul directly to bytecode via solc standard-json.

```bash
# Basic compilation
python3.11 testing/export_bytecode.py output/Contract.yul output/Contract_solc.bin

# Custom optimizer runs
python3.11 testing/export_bytecode.py output/Contract.yul output/Contract_solc.bin --optimizer-runs 200
```

**Use case:** Compare Yul2Venom output against direct solc compilation.

### testing/vyper_ir_helper.py

Compile Vyper contracts for Venom IR research.

```bash
# Basic IR output
python3.11 testing/vyper_ir_helper.py testing/vyper_test.vy

# With Venom IR (experimental codegen)
python3.11 testing/vyper_ir_helper.py testing/vyper_test.vy --venom

# All formats
python3.11 testing/vyper_ir_helper.py testing/vyper_test.vy --all
```

**Use case:** Compare native Vyper Venom IR against transpiled IR.

### testing/memory_layout_calc.py

Debug memory allocation patterns for struct/array issues.

```bash
# Calculate layout for 2-element struct array
python3.11 testing/memory_layout_calc.py 2

# Calculate layout for 5-element struct array
python3.11 testing/memory_layout_calc.py 5
```

**Use case:** Debug memory overlap issues in complex data structure handling.

---

## Utility Modules

### utils/constants.py

Centralized constants for the transpiler.

```python
from utils.constants import (
    # Memory Layout
    VENOM_MEMORY_START,  # 0x100 - Venom backend memory start
    SPILL_OFFSET,        # 0x4000 - Stack spill region
    YUL_FMP_SLOT,        # 0x40 - Solidity free memory pointer slot
    YUL_HEAP_START,      # 0x80 - Solidity heap start
    
    # Panic Codes
    PANIC_CODES,         # Dict of Solidity panic codes
    PANIC_ASSERT,        # 0x01
    PANIC_ARITHMETIC_OVERFLOW,  # 0x11
    
    # Opcode Categories
    VOID_OPS,            # Operations with no return value
    COPY_OPS,            # Memory copy operations
    NON_COMMUTATIVE_OPS, # Order-sensitive operations
    SIMPLE_OPS,          # Commutative binary operations
    MEMORY_OPS,          # Memory load operations
    ENV_OPS,             # Environment operations
    CALL_OPS,            # Call-like operations
    
    # Paths
    PROJECT_ROOT,        # Path to yul2venom root
    sanitize_paths,      # Convert absolute → relative paths
)
```

### utils/logging_config.py

Logging configuration utilities.

```python
from utils.logging_config import setup_logging

# Setup with default settings
setup_logging()

# With custom level
setup_logging(level=logging.DEBUG)
```

---

## Workflow Examples

### Standard Development Flow

```bash
# 1. Create new contract in foundry/src/
vim foundry/src/MyContract.sol

# 2. Prepare (extract Yul + create config)
python3.11 yul2venom.py prepare foundry/src/MyContract.sol

# 3. Edit config if needed (constructor args, deployer, etc.)
vim configs/MyContract.yul2venom.json

# 4. Transpile
python3.11 yul2venom.py transpile configs/MyContract.yul2venom.json

# 5. Create test
vim foundry/test/MyContract.t.sol

# 6. Run test
cd foundry && forge test --match-contract MyContract -vvvv
```

### Debugging a Failing Test

```bash
# 1. Transpile with debug IR
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json --dump-ir -O O0

# 2. Inspect pre-optimization IR
cat debug/raw_ir.vnm

# 3. Inspect post-optimization IR
cat debug/opt_ir.vnm

# 4. Disassemble bytecode
python3.11 testing/inspect_bytecode.py output/Contract_opt.bin --limit 200

# 5. Trace execution
python3.11 tools/evm_tracer.py output/Contract_opt_runtime.bin 0x12345678

# 6. Analyze liveness if variable issues
python3.11 testing/debug_liveness.py debug/opt_ir.vnm

# 7. Compare against native Vyper (if applicable)
python3.11 testing/vyper_ir_helper.py testing/vyper_test.vy --venom
```

### Full Benchmark Suite

```bash
# 1. Ensure all contracts are transpiled
python3.11 testing/test_framework.py --transpile-all

# 2. Run full benchmark
python3.11 tools/benchmark.py --config tools/profiles/full.yaml

# 3. View report
cat benchmark_report.md
```

### Init Bytecode Development

```bash
# 1. Create init test contract in foundry/src/init/
vim foundry/src/init/InitMyTest.sol

# 2. Prepare
python3.11 yul2venom.py prepare foundry/src/init/InitMyTest.sol

# 3. Move config to init directory
mv configs/InitMyTest.yul2venom.json configs/init/

# 4. Transpile with init bytecode
python3.11 yul2venom.py transpile configs/init/InitMyTest.yul2venom.json --with-init

# 5. Create init test
vim foundry/test/init/InitMyTest.t.sol

# 6. Run init tests
python3.11 testing/test_framework.py --test-init
```

---

## Debug Files

After transpilation with `--dump-ir`:

| File | Description |
|------|-------------|
| `debug/raw_ir.vnm` | Pre-optimization Venom IR |
| `debug/opt_ir.vnm` | Post-optimization Venom IR |
| `debug/assembly.asm` | Generated EVM assembly |

---

## CI/CD Integration

```bash
# Full CI pipeline simulation
python3.11 testing/test_framework.py --prepare-all
python3.11 testing/test_framework.py --transpile-all
python3.11 testing/test_framework.py --init-all
cd foundry && forge test
python3.11 tools/benchmark.py --output report.md
```

---

*Last updated: 2026-02-02*
