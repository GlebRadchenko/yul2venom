# Yul2Venom

**Yul-to-Venom IR transpiler** enabling Vyper's optimization pipeline for Solidity contracts.

```
Solidity → solc --ir-optimized → Yul → Yul2Venom → Venom IR → Vyper backend → EVM Bytecode
```

## Quick Start

```bash
# Requirements: Python 3.11+, solc 0.8.x, forge (Foundry)

# Install dependencies
pip install -r requirements.txt

# Full pipeline
python3.11 yul2venom.py prepare foundry/src/SimpleAdd.sol
python3.11 yul2venom.py transpile configs/SimpleAdd.yul2venom.json

# Run tests
cd foundry && forge test
```

---

## Pipeline

| Step | Command | Output |
|------|---------|--------|
| **1. Prepare** | `yul2venom.py prepare foundry/src/Contract.sol` | `output/Contract.yul` + config |
| **2. Configure** | Edit `configs/Contract.yul2venom.json` | Set deployer address |
| **3. Transpile** | `yul2venom.py transpile configs/Contract.yul2venom.json` | `output/Contract_opt.bin` |
| **4. Test** | `cd foundry && forge test` | Run Foundry tests |

---

## Transpiler Architecture

### Core Components

| File | Purpose |
|------|---------|
| `yul2venom.py` | Main CLI with `prepare` and `transpile` commands |
| `yul_parser.py` | Parses Yul assembly into AST nodes |
| `yul_extractor.py` | Extracts deployed runtime object from compiler output |
| `optimizer.py` | Yul-level regex and structural optimizations |
| `venom_generator.py` | Converts Yul AST → Venom IR (the core transpilation logic) |
| `run_venom.py` | Compiles `.vnm` files to EVM bytecode via Vyper backend |

### Transpilation Flow

```
┌─────────────────┐     ┌───────────────┐     ┌─────────────────┐
│  yul_parser.py  │────►│  optimizer.py │────►│venom_generator.py│
│  Parse Yul AST  │     │ Optimize Yul  │     │ Build Venom IR  │
└─────────────────┘     └───────────────┘     └─────────────────┘
                                                      │
                                                      ▼
┌─────────────────┐     ┌───────────────┐     ┌─────────────────┐
│   Vyper Passes  │◄────│  run_venom.py │◄────│   .vnm output   │
│ SSA, DCE, SCCP  │     │ Backend Invoke│     │ Venom IR text   │
└─────────────────┘     └───────────────┘     └─────────────────┘
         │
         ▼
   EVM Bytecode (.bin)
```

---

## Configuration Files

Configs are stored in `configs/*.yul2venom.json`. Each config defines:

```json
{
  "version": "1.0",
  "contract": "foundry/src/SimpleAdd.sol",
  "yul": "output/SimpleAdd.yul",
  "deployment": {
    "deployer": "0x1234567890123456789012345678901234567890",
    "nonce": 0
  },
  "constructor_args": {},
  "auto_predicted": {}
}
```

> **Note**: All paths in configs are **relative to the yul2venom root directory**. Never use absolute paths.

| Field | Description |
|-------|-------------|
| `contract` | Path to source Solidity file (relative to project root) |
| `yul` | Path to extracted Yul IR (relative to project root) |
| `deployment.deployer` | Address that will deploy (for CREATE address prediction) |
| `deployment.nonce` | Deployer nonce at deployment time |
| `constructor_args` | Named constructor arguments for immutable resolution |
| `auto_predicted` | Auto-filled predicted addresses (child contracts) |

---

## Project Structure

```
yul2venom/
├── yul2venom.py           # Main CLI
├── venom_generator.py     # Core transpiler (Yul AST → Venom IR)
├── yul_parser.py          # Yul grammar parser
├── yul_extractor.py       # Deployed object extraction
├── optimizer.py           # Yul-level optimizations
├── run_venom.py           # VNM → bytecode compiler
│
├── utils/                 # Shared utilities
│   ├── constants.py       # Memory layout, panic codes
│   └── logging_config.py  # Unified logging setup
│
├── ir/                    # Standalone Venom IR types
│   ├── basicblock.py      # IRInstruction, IRVariable, IRLiteral, IRLabel
│   ├── context.py         # IRContext, DataSection
│   └── function.py        # IRFunction
│
├── tools/                 # Benchmark & debugging tools
│   ├── benchmark.py       # Production benchmark tool
│   ├── benchmark.sh       # Quick benchmark script
│   ├── benchmark.example.yaml  # Config template
│   └── evm_tracer.py      # Step-by-step EVM tracer
│
├── testing/               # Debug and test utilities
│   ├── test_framework.py  # Batch transpilation testing
│   ├── debug_liveness.py  # Liveness analysis debugging
│   ├── trace_stack.py     # Stack state tracing
│   ├── trace_memory.py    # Memory operation analysis
│   ├── export_bytecode.py # Compile Yul via solc
│   ├── inspect_bytecode.py # EVM disassembler
│   └── vyper_ir_helper.py # Generate reference Vyper IR
│
├── configs/               # Contract configuration files
│   ├── *.yul2venom.json   # Core contract configs
│   └── bench/             # Benchmark contract configs
│
├── vyper/                 # Vyper fork (git submodule)
│
├── foundry/               # Foundry project for testing
│   ├── src/               # Solidity source contracts
│   │   └── bench/         # 8 benchmark contracts
│   ├── test/              # Forge test files
│   │   └── bench/         # Benchmark test suites
│   └── foundry.toml       # solc 0.8.30, cancun, via_ir
│
├── output/                # Generated Yul/VNM/bytecode
│   └── bench/             # Benchmark outputs
└── debug/                 # Debug artifacts
    ├── raw_ir.vnm         # Pre-optimization IR
    ├── opt_ir.vnm         # Post-optimization IR
    └── assembly.asm       # Generated assembly
```

---

## Commands Reference

### Core Transpilation

```bash
# Prepare: Extract Yul from Solidity
python3.11 yul2venom.py prepare foundry/src/Contract.sol

# Transpile: Yul → Venom → Bytecode
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json

# Transpile with runtime-only output (for testing via vm.etch)
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json --runtime-only

# Dump intermediate Venom IR
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json --dump-ir
```

### Optimization Levels

```bash
# Default (O2) - Safe Yul pipeline
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json

# Native Vyper O2 pipeline
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json --optimize native

# No optimization
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json --optimize O0

# All available: none, O0, O2 (default), O3, Os, native, debug
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

# Analyze a VNM file
cd testing && python3.11 test_framework.py --analyze ../debug/raw_ir.vnm
```

---

## Benchmarking

The benchmark tool compares transpiled bytecode against various Solc configurations.

### Quick Start

```bash
# Run with defaults (8 contracts, default/ir_optimized modes)
python3.11 tools/benchmark.py

# With custom config
cp tools/benchmark.example.yaml tools/benchmark.yaml
# Edit benchmark.yaml
python3.11 tools/benchmark.py --config tools/benchmark.yaml

# Specific options
python3.11 tools/benchmark.py --contracts "Arithmetic,ControlFlow" --runs 200
```

### Configuration

See `tools/benchmark.example.yaml`:

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

### Benchmark Contracts

The `foundry/src/bench/` directory contains 8 comprehensive benchmark contracts:

| Contract | Features |
|----------|----------|
| `Arithmetic.sol` | Safe/unsafe math, comparisons, bitwise operations |
| `ControlFlow.sol` | Loops, conditionals, break/continue, switch |
| `StateManagement.sol` | Storage, memory, constants, immutables, transient storage |
| `DataStructures.sol` | Arrays, structs, nested structs, mappings |
| `Functions.sol` | Internal/external calls, recursion, inheritance |
| `Events.sol` | Simple events, indexed events, complex events |
| `Encoding.sol` | ABI encode/decode, keccak256, signatures |
| `Edge.sol` | Enums, reverts, try-catch, create/create2 |

---

## Debug Tools

### EVM Tracer

Step through bytecode execution:

```bash
python3.11 tools/evm_tracer.py output/Contract_opt_runtime.bin
python3.11 tools/evm_tracer.py output/Contract_opt_runtime.bin 0x12345678  # with calldata
```

Output shows:
- Program counter
- Opcode name  
- Stack state (before/after)
- Memory writes

### Bytecode Inspector

Disassemble bytecode:

```bash
python3.11 testing/inspect_bytecode.py output/Contract_opt.bin --limit 100
```

### Stack Tracer

Trace stack state through blocks:

```bash
python3.11 testing/trace_stack.py debug/raw_ir.vnm --blocks "loop_start,loop_end"
```

### Memory Tracer

Analyze memory operations:

```bash
python3.11 testing/trace_memory.py debug/raw_ir.vnm
```

---

## Test Status

**79/79 tests passing ✅** (as of 2026-01-31)

- 19/19 core configs transpile successfully
- All 8 benchmark contracts transpile successfully
- All Solidity features supported (loops, storage, memory, events, etc.)

---

## Utils Package

The `utils/` package centralizes shared constants and configuration:

### Constants (`utils/constants.py`)

```python
# Memory layout
SPILL_OFFSET = 0x4000      # Stack spill region start
VENOM_MEMORY_START = 0x1000
YUL_HEAP_START = 0x80      # Solidity free memory pointer start
YUL_FMP_SLOT = 0x40        # Free memory pointer location

# Panic codes (Solidity revert reasons)
PANIC_CODES = {
    0x00: "Generic",
    0x01: "Assert failure",
    0x11: "Arithmetic overflow",
    0x12: "Division by zero",
    0x21: "Invalid enum value",
    ...
}
```

---

## Known Limitations

1. Deep function call chains may cause stack overflow
2. External callbacks (DCE disabled in fork)
3. Stack depth > 16 may fail
4. Complex struct encoding edge cases

---

## License

MIT

### Third-Party Licenses

This project includes a modified fork of [Vyper](https://github.com/vyperlang/vyper) 
(in `vyper/` directory) which is licensed under the **Apache License 2.0**.

- Copyright 2015 Vitalik Buterin
- Full license: [vyper/LICENSE](vyper/LICENSE)

See [NOTICE](NOTICE) for complete attribution.
