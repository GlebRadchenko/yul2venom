# Contributing to Yul2Venom

Thanks for your interest in improving Yul2Venom!

## Project Overview

**Yul2Venom** is a Yul-to-Venom IR transpiler enabling Vyper's optimization pipeline for Solidity contracts:

```
Solidity → solc --ir-optimized → Yul → Yul2Venom → Venom IR → Vyper backend → EVM Bytecode
```

Before contributing, please read:
- [README.md](README.md) - Quick start and architecture
- [AGENTS.md](AGENTS.md) - Technical reference (parser reversal, memory layout)

## Development Setup

### Prerequisites

- Python 3.11+
- solc 0.8.x (Solidity compiler)
- Foundry (forge, cast)

### Installation

```bash
git clone https://github.com/your-username/yul2venom.git
cd yul2venom
pip install -r requirements.txt
cd foundry && forge install && cd ..
```

### Prepare Bytecode Before Testing

```bash
# Batch transpile all configs
python3.11 testing/test_framework.py --transpile-all

# Transpile init bytecode configs
python3.11 testing/test_framework.py --init-all

# Run tests
cd foundry && forge test
```

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
├── tools/                 # benchmark.py, evm_tracer.py
├── testing/               # test_framework.py, debug utils
├── configs/               # Contract configs (core, bench, init)
├── foundry/               # Solidity contracts and tests
├── output/                # Generated .yul, .vnm, .bin
└── vyper/                 # Vyper fork (submodule)
```

### Vyper Fork

The `vyper/` submodule is on branch `yul2venom` with critical patches for Yul support:

- **liveness.py**: Phi operand ordering fix for nested loops
- **effects.py**: log0-4 effect registration
- **venom_to_assembly.py**: Yul opcodes, duplicate literals, assign stack fix

See [docs/VENOM_CHANGES.md](docs/VENOM_CHANGES.md) for the complete change audit.

## Transpilation Workflow

```bash
# Step 1: Prepare - Extract Yul and create config
python3.11 yul2venom.py prepare foundry/src/Contract.sol

# Step 2: Edit config (set deployer, constructor_args if needed)
vim configs/Contract.yul2venom.json

# Step 3: Transpile
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json

# Step 4: Test
cd foundry && forge test --match-contract ContractTest
```

### Transpilation Modes

```bash
# Runtime-only (for vm.etch testing)
python3.11 yul2venom.py transpile config.json --runtime-only

# Full init bytecode (for deployment)
python3.11 yul2venom.py transpile config.json --with-init

# Optimization levels: none, O0, O2 (default), O3, Os, native
python3.11 yul2venom.py transpile config.json -O native
```

## Testing

```bash
# Run all Forge tests
cd foundry && forge test

# Verbose single test
cd foundry && forge test --match-test "test_name" -vvvv

# Full pipeline (transpile + retranspile for tests + run Forge)
python3.11 testing/test_framework.py --test-all

# Init bytecode tests only
python3.11 testing/test_framework.py --test-init
```

> **Important**: `--test-all` automatically retranspiles all contracts with `--runtime-only` for `vm.etch` tests before running Forge. Always use this command to ensure bytecode is up-to-date.

### Test Pattern

Tests use `vm.readFileBinary()` to load transpiled bytecode:

```solidity
function setUp() public {
    bytes memory code = vm.readFileBinary("../output/Contract_opt.bin");
    target = address(0x1234);
    vm.etch(target, code);
}
```

## Debugging

### Debug Files

After transpilation:
- `debug/raw_ir.vnm` - Pre-optimization IR
- `debug/opt_ir.vnm` - Post-optimization IR
- `debug/assembly.asm` - Generated assembly

### Debug Tools

```bash
# EVM tracer
python3.11 tools/evm_tracer.py output/Contract_opt_runtime.bin

# Bytecode disassembler
python3.11 testing/inspect_bytecode.py output/Contract_opt.bin --limit 100
```

### Common Issues

| Symptom | Cause | Fix |
|---------|-------|-----|
| `InvalidJump` | ret operand order | PC first: `ret %pc, %val` |
| Return always 0 | invoke output not captured | Use `ret=variable` |
| Loop exits early | lt/gt operand order | Check comparison operands |

## Important Guidelines

1. **Transpiler fixes > Backend patches** — The Vyper backend is designed for native Vyper. Fix the transpiler, not the backend.

2. **Never hardcode bytecode** — Always use `vm.readFileBinary()` in tests.

3. **Config paths are relative** — All paths relative to yul2venom root.

4. **Python 3.11+ required** — Uses match/case syntax.

5. **Read AGENTS.md** — Critical info about parser operand reversal.

## Submitting a Pull Request

Before opening a PR:

```bash
# All tests pass
cd foundry && forge test

# Batch transpilation succeeds
python3.11 testing/test_framework.py --transpile-all
python3.11 testing/test_framework.py --init-all
```

## CI/CD Pipeline

| Workflow | Trigger | Description |
|----------|---------|-------------|
| `ci.yml` | Push, PR | Lint, transpile, test, benchmark |
| `nightly.yml` | 2 AM UTC | Full benchmark with historical tracking |

### Running CI Locally

```bash
python3.11 testing/test_framework.py --prepare-all
python3.11 testing/test_framework.py --transpile-all
python3.11 testing/test_framework.py --init-all
cd foundry && forge test
python3.11 tools/benchmark.py --output report.md
```

---

Thank you for contributing to Yul2Venom! 🎉
