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
| `yul_extractor.py` | Extracts deployed runtime object from compilier output |
| `optimizer.py` | Yul-level regex and structural optimizations |
| `venom_generator.py` | Converts Yul AST → Venom IR (the core transpilation logic) |
| `run_venom.py` | Compiles `.vnm` files to EVM bytecode via Vyper backend |
| `transpiler.py` | Legacy wrapper (scheduled for removal) |

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

| Field | Description |
|-------|-------------|
| `contract` | Path to source Solidity file |
| `yul` | Path to extracted Yul IR |
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
│   ├── __init__.py
│   ├── constants.py       # Memory layout, panic codes
│   └── logging_config.py  # Unified logging setup
│
├── ir/                    # Standalone Venom IR types
│   ├── __init__.py        # Exports: IRContext, IRFunction, IRBasicBlock...
│   ├── basicblock.py      # IRInstruction, IRVariable, IRLiteral, IRLabel
│   ├── context.py         # IRContext, DataSection
│   └── function.py        # IRFunction
│
├── testing/               # Debug and test utilities
│   ├── __init__.py        # Package constants (paths, timeouts)
│   ├── test_framework.py  # Batch transpilation testing
│   ├── debug_liveness.py  # Liveness analysis debugging
│   ├── trace_stack.py     # Stack state tracing
│   ├── trace_memory.py    # Memory operation analysis
│   ├── export_bytecode.py # Compile Yul via solc
│   ├── inspect_bytecode.py # EVM disassembler
│   └── vyper_ir_helper.py # Generate reference Vyper IR
│
├── configs/               # Contract configuration files
│   └── *.yul2venom.json   # 20 contract configs
│
├── vyper/                 # Vyper fork (git submodule)
│
├── foundry/               # Foundry project for testing
│   ├── src/               # Solidity source contracts
│   ├── test/              # Forge test files
│   └── foundry.toml       # solc 0.8.30, cancun, via_ir
│
├── output/                # Generated Yul/VNM/bytecode
└── debug/                 # Debug artifacts
```

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

## Testing Utilities

All testing utilities support `--help` for usage information.

| Script | Usage |
|--------|-------|
| `test_framework.py` | `python3 test_framework.py --transpile-all` |
| `debug_liveness.py` | `python3 debug_liveness.py <file.vnm> --function NAME` |
| `trace_stack.py` | `python3 trace_stack.py <file.vnm> --blocks "loop,end_if"` |
| `trace_memory.py` | `python3 trace_memory.py <file.vnm>` |
| `inspect_bytecode.py` | `python3 inspect_bytecode.py <file.bin> --limit 100` |
| `export_bytecode.py` | `python3 export_bytecode.py input.yul output.bin` |

---

## Commands

```bash
# Prepare: Extract Yul from Solidity
python3.11 yul2venom.py prepare foundry/src/Contract.sol

# Transpile: Yul → Venom → Bytecode
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json

# Transpile with runtime-only output
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json --runtime-only

# Compile VNM to bytecode directly
python3.11 run_venom.py output/Contract.vnm --output output/Contract.bin
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
