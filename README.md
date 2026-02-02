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
| **2. Configure** | Edit `configs/Contract.yul2venom.json` | Set deployer, args |
| **3. Transpile** | `yul2venom.py transpile configs/Contract.yul2venom.json` | `output/Contract_opt.bin` |
| **4. Test** | `cd foundry && forge test` | Run Foundry tests |

---

## Transpiler Architecture

### Pipeline Flow

```
┌─────────────────┐     ┌───────────────┐     ┌─────────────────┐
│  parser/        │────►│  optimizer/   │────►│  generator/     │
│  YulParser      │     │ YulOptimizer  │     │ VenomIRBuilder  │
└─────────────────┘     └───────────────┘     └─────────────────┘
                                                       │
                                                       ▼
┌─────────────────┐     ┌───────────────┐     ┌─────────────────┐
│   Vyper Passes  │◄────│  backend/     │◄────│   .vnm output   │
│ SSA, DCE, SCCP  │     │ run_venom     │     │ Venom IR text   │
└─────────────────┘     └───────────────┘     └─────────────────┘
         │
         ▼
   EVM Bytecode (.bin)
```

### Core Packages

| Package | Purpose |
|---------|---------|
| `parser/` | Yul grammar parsing, object extraction |
| `generator/` | Yul AST → Venom IR transpilation |
| `optimizer/` | Pre-transpilation Yul source optimization |
| `backend/` | Venom IR → EVM bytecode via Vyper |
| `core/` | Pipeline orchestration, error handling |
| `ir/` | Standalone Venom IR types |
| `utils/` | Constants, logging utilities |

---

## Configuration Files

Configs are stored in `configs/*.yul2venom.json`:

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

| Field | Description |
|-------|-------------|
| `contract` | Path to source Solidity file |
| `yul` | Path to extracted Yul IR |
| `deployment.deployer` | Deployer address (for CREATE prediction) |
| `deployment.nonce` | Deployer nonce at deployment |
| `constructor_args` | Named constructor arguments |
| `auto_predicted` | Auto-computed CREATE addresses for child contracts |

> **Note**: All paths are **relative to the yul2venom root directory**.

---

## Project Structure

```
yul2venom/
├── yul2venom.py           # Main CLI
├── parser/                # Yul parsing and extraction
├── generator/             # VenomIRBuilder, optimizations
├── optimizer/             # Yul source optimizer
├── backend/               # Vyper backend invocation
├── core/                  # Pipeline, error handling
├── ir/                    # Venom IR types
├── utils/                 # Constants, logging
│
├── tools/                 # Benchmark & debug tools
│   ├── benchmark.py       # Production benchmark tool
│   └── evm_tracer.py      # EVM execution tracer
│
├── testing/               # Test framework & utilities
│   ├── test_framework.py  # Batch transpilation testing
│   ├── inspect_bytecode.py # EVM disassembler
│   ├── trace_stack.py     # Stack state tracing
│   └── trace_memory.py    # Memory operation analysis
│
├── configs/               # Contract configuration files
│   ├── *.yul2venom.json   # Core contract configs
│   ├── bench/             # 15 benchmark configs
│   └── init/              # 10 init bytecode configs
│
├── foundry/               # Foundry project for testing
│   ├── src/               # Solidity source contracts
│   │   ├── bench/         # 15 benchmark contracts
│   │   └── init/          # 10 init test contracts
│   ├── test/              # Forge test files
│   │   ├── bench/         # Benchmark test suites
│   │   └── init/          # Init bytecode tests
│   └── foundry.toml       # solc 0.8.30, cancun, via_ir
│
├── output/                # Generated Yul/VNM/bytecode
├── debug/                 # Debug artifacts
├── docs/                  # Research & reference docs
└── vyper/                 # Vyper fork (submodule)
```

### Vyper Fork

**Branch**: `yul2venom` (commit 798d288f)

The Vyper submodule contains critical patches for Yul2Venom:
- Phi operand ordering fix (nested loops)
- Log0-4 effect registration (events)
- Yul opcode support (sha3, mstore8, byte, pop)
- Duplicate literal handling
- Assign instruction stack model fix

See [docs/VENOM_CHANGES.md](docs/VENOM_CHANGES.md) for the complete audit.

---

## Commands Reference

### Core Transpilation

```bash
# Prepare: Extract Yul from Solidity
python3.11 yul2venom.py prepare foundry/src/Contract.sol

# Transpile: Yul → Venom → Bytecode
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json

# Runtime-only output (for vm.etch testing)
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json --runtime-only

# Full init bytecode (for deployment)
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json --with-init

# Dump intermediate Venom IR
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json --dump-ir
```

### Optimization Levels

```bash
# Default (O2) - Safe Yul pipeline
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json

# Native Vyper O2 pipeline
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json -O native

# No optimization
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json -O O0

# All levels: none, O0, O2 (default), O3, Os, native, debug
```

### Yul Source Optimizer

```bash
# Enable standard optimization
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json --yul-opt

# Aggressive optimization (strips runtime checks)
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json --yul-opt-level=aggressive

# Levels: safe, standard, aggressive, maximum
```

| Level | Effect |
|-------|--------|
| `safe` | Remove dead validators, empty blocks |
| `standard` | + Strip callvalue, calldatasize checks |
| `aggressive` | + Strip extcodesize, returndatasize checks |
| `maximum` | + Strip overflow checks (**DANGEROUS**) |

### Testing

```bash
# Run all tests
cd foundry && forge test

# Specific test with verbose output
cd foundry && forge test --match-test "test_name" -vvvv

# Batch transpile all configs
python3.11 testing/test_framework.py --transpile-all

# Transpile init bytecode configs
python3.11 testing/test_framework.py --init-all

# Run init bytecode tests
python3.11 testing/test_framework.py --test-init

# Full pipeline (transpile + test)
python3.11 testing/test_framework.py --full
```

---

## Benchmarking

```bash
# Run with defaults
python3.11 tools/benchmark.py

# Specific contracts
python3.11 tools/benchmark.py --contracts "Arithmetic,ControlFlow"

# Custom optimization runs
python3.11 tools/benchmark.py --runs 200
```

### Benchmark Contracts

15 comprehensive benchmark contracts in `foundry/src/bench/`:

| Contract | Features |
|----------|----------|
| `Arithmetic.sol` | Math, comparisons, bitwise ops |
| `ControlFlow.sol` | Loops, conditionals, break/continue |
| `StateManagement.sol` | Storage, memory, transient storage |
| `DataStructures.sol` | Arrays, structs, mappings |
| `Functions.sol` | Internal/external calls, recursion |
| `Events.sol` | Simple, indexed, complex events |
| `Encoding.sol` | ABI encode/decode, keccak256 |
| `Edge.sol` | Enums, reverts, try-catch, create2 |
| `Libraries.sol` | Using-for, internal libraries |
| `Modifiers.sol` | Basic, nested, stacked modifiers |
| `SoladyToken.sol` | Full ERC20 implementation |
| `TransientStorage.sol` | TLOAD/TSTORE, reentrancy guards |
| `TypeLimits.sol` | Type introspection, safe math |
| `AdvancedFeatures.sol` | User-defined types, bytes ops |
| `ExternalLibrary.sol` | External library linking |

---

## Debug Tools

### EVM Tracer

```bash
python3.11 tools/evm_tracer.py output/Contract_opt_runtime.bin
python3.11 tools/evm_tracer.py output/Contract_opt_runtime.bin 0x12345678  # with calldata
```

### Bytecode Inspector

```bash
python3.11 testing/inspect_bytecode.py output/Contract_opt.bin --limit 100
```

### Debug Files

After transpilation:
- `debug/raw_ir.vnm` - Pre-optimization IR
- `debug/opt_ir.vnm` - Post-optimization IR
- `debug/assembly.asm` - Generated assembly

---

## Test Status

**339 tests passing ✅** (38 test suites)

- 21 core contracts
- 15 benchmark contracts  
- 10 init bytecode edge cases
- Full constructor support (args, immutables, inheritance, CREATE)

---

## Utils Package

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
    ...
}
```

---

## Known Limitations

1. Deep function call chains (>16 stack depth) may require spilling
2. External library linking requires manual address configuration
3. Complex struct encoding edge cases

---

## License

MIT

### Third-Party Licenses

This project includes a modified fork of [Vyper](https://github.com/vyperlang/vyper) 
(in `vyper/` directory) licensed under **Apache License 2.0**.

- Copyright 2015 Vitalik Buterin
- Full license: [vyper/LICENSE](vyper/LICENSE)

See [NOTICE](NOTICE) for complete attribution.
