# Contributing to Yul2Venom

Thanks for your interest in improving Yul2Venom!

This document will help you get started. **Do not let the document intimidate you.**
It should be considered as a guide to help you navigate the process.

## Project Overview

**Yul2Venom** is a Yul-to-Venom IR transpiler enabling Vyper's optimization pipeline for Solidity contracts:

```
Solidity → solc --ir-optimized → Yul → Yul2Venom → Venom IR → Vyper backend → EVM Bytecode
```

Before contributing, please read:
- [README.md](README.md) - Quick start and architecture
- [AGENTS.md](AGENTS.md) - Detailed technical reference (parser reversal, memory layout, etc.)

## Ways to Contribute

There are fundamentally three ways to contribute:

1. **By opening an issue:** If you believe you have uncovered a bug or want to suggest a feature,
   creating a new issue is the way to report it.
2. **By adding context:** Providing additional context to existing issues,
   such as debug output, stack traces, or minimal reproduction cases.
3. **By resolving issues:** Opening a pull request that fixes the underlying problem,
   in a concrete and reviewable manner.

**Anybody can participate in any stage of contribution.** We urge you to participate in the discussion
around bugs and participate in reviewing PRs.

## Development Setup

### Prerequisites

- Python 3.11+
- solc 0.8.x (Solidity compiler)
- Foundry (forge, cast)

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/yul2venom.git
cd yul2venom

# Install Python dependencies
pip install -r requirements.txt

# Initialize Foundry (for testing)
cd foundry && forge install && cd ..
```

### Prepare Bytecode Before Testing

The test suite requires transpiled bytecode. Before running tests for the first time 
(or after modifying contracts), you must transpile all configs:

```bash
# Option 1: Batch transpile all existing configs
cd testing && python3.11 test_framework.py --transpile-all && cd ..

# Option 2: Manual per-contract (if adding a new contract)
python3.11 yul2venom.py prepare foundry/src/YourContract.sol
# Edit configs/YourContract.yul2venom.json to fill deployer, nonce, constructor_args
python3.11 yul2venom.py transpile configs/YourContract.yul2venom.json
```

### Verify Setup

```bash
# After transpiling, run the test suite
cd foundry && forge test
```

## Transpilation Workflow

### Full Pipeline

```bash
# Step 1: Prepare - Extract Yul and create config template
python3.11 yul2venom.py prepare foundry/src/Contract.sol

# Step 2: Edit config (REQUIRED for contracts with constructor args or immutables)
# The prepare command creates a template with placeholders:
#   - deployment.deployer: Set to your deployer address (for CREATE address prediction)
#   - deployment.nonce: Set deployer's nonce at deployment time
#   - constructor_args: Fill in any constructor argument values
vim configs/Contract.yul2venom.json

# Step 3: Transpile - Generate Venom IR and bytecode
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json

# Step 4: Test
cd foundry && forge test --match-contract ContractTest
```

### Config Template Example

The `prepare` command generates a config like this:

```json
{
  "version": "1.0",
  "contract": "foundry/src/Contract.sol",
  "yul": "output/Contract.yul",
  "deployment": {
    "deployer": "0x1234567890123456789012345678901234567890",
    "nonce": 0
  },
  "constructor_args": {
    "owner": {
      "id": "42",
      "type": "address",
      "value": ""  // ← YOU MUST FILL THIS
    }
  },
  "auto_predicted": {}
}
```

> **Note:** Simple contracts without constructor args or immutables often work with defaults.
> The benchmark contracts are pre-configured and ready to transpile.

### Optimization Levels

```bash
# Default (O2) - Safe Yul pipeline
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json

# Native Vyper O2 pipeline (may produce smaller code)
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json -O native

# No optimization (for debugging)
python3.11 yul2venom.py transpile configs/Contract.yul2venom.json -O O0

# All available: none, O0, O2 (default), O3, Os, native, debug
```

## Testing

### Running Tests

```bash
# Run all Forge tests
cd foundry && forge test

# Run specific test with verbose output
cd foundry && forge test --match-test "test_name" -vvvv

# Run tests excluding benchmarks (faster)
cd foundry && forge test --no-match-path "test/bench/*"

# Full pipeline (transpile + test)
cd testing && python3.11 test_framework.py --full
```

### Test File Pattern

Tests use `vm.readFileBinary()` to load transpiled bytecode:

```solidity
function setUp() public {
    bytes memory code = vm.readFileBinary("output/Contract_opt.bin");
    target = address(0x1234);
    vm.etch(target, code);  // Deploy transpiled bytecode
}
```

## Benchmarking

```bash
# Run benchmarks (compares transpiled vs Solc output)
python3.11 tools/benchmark.py

# Quick benchmark with specific contracts
python3.11 tools/benchmark.py --contracts "Arithmetic,ControlFlow"

# With specific transpiler optimization level
python3.11 tools/benchmark.py -O O3

# Compare all modes
python3.11 tools/benchmark.py --modes "default,via_ir,ir_optimized"
```

## Project Structure

```
yul2venom/
├── yul2venom.py           # Main CLI (prepare, transpile commands)
├── venom_generator.py     # Core transpiler (Yul AST → Venom IR)
├── yul_parser.py          # Yul grammar parser
├── optimizer.py           # Yul-level optimizations
├── run_venom.py           # VNM → bytecode compiler
│
├── configs/               # Contract configuration files
│   └── bench/             # Benchmark contract configs
├── foundry/               # Foundry project for testing
│   ├── src/               # Solidity source contracts
│   │   └── bench/         # 8 benchmark contracts
│   └── test/              # Forge test files
├── vyper/                 # Vyper fork (git submodule)
└── output/                # Generated: *.yul, *.vnm, *.bin
```

## Debugging Tips

### Debug Files

After transpilation, check:
- `debug/raw_ir.vnm` - Pre-optimization IR
- `debug/opt_ir.vnm` - Post-optimization IR  
- `debug/assembly.asm` - Generated assembly

### Common Issues

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| `InvalidJump` | ret operand order | PC first: `ret %pc, %val` |
| Return always 0 | invoke output not captured | Use `ret=variable` |
| Loop exits early | lt/gt operand order | Check comparison operands |
| Stack underflow | Param count mismatch | Check invoke param count |

### Debug Tools

```bash
# EVM tracer - step through bytecode execution
python3.11 tools/evm_tracer.py output/Contract_opt_runtime.bin

# Bytecode disassembler
python3.11 testing/inspect_bytecode.py output/Contract_opt.bin --limit 100
```

## Important Guidelines

1. **Transpiler fixes > Backend patches** - The Vyper backend is designed for native Vyper.
   If the backend produces wrong output, the bug is almost always in `venom_generator.py`.
   Fix the transpiler, not the backend.

2. **Never hardcode bytecode** - Always use `vm.readFileBinary()` in tests.

3. **Config paths are relative** - All paths in config files should be relative to the yul2venom root.

4. **Python 3.11+ required** - The codebase uses match/case syntax.

5. **Read AGENTS.md** - It contains critical information about parser operand reversal and memory layout.

## Submitting a Pull Request

Before opening a PR:

```bash
# All Forge tests pass
cd foundry && forge test

# Batch transpilation succeeds (if you modified transpiler logic)
cd testing && python3.11 test_framework.py --transpile-all
```

## CI/CD Pipeline

The project uses GitHub Actions for continuous integration. On every push and PR:

### Workflow Overview

| Workflow | Trigger | Description |
|----------|---------|-------------|
| `ci.yml` | Push, PR | Lint, transpile, test, benchmark (on PR) |
| `nightly.yml` | 2 AM UTC daily | Full benchmark suite with historical tracking |

### What CI Does

1. **Lint** - Runs `ruff` on Python code
2. **Prepare** - Compiles all Solidity → Yul (`test_framework.py --prepare-all`)
3. **Transpile** - Converts Yul → Venom → Bytecode (`test_framework.py --transpile-all`)
4. **Test** - Runs Forge tests against transpiled bytecode
5. **Benchmark** (PRs only) - Generates comparison report and posts as PR comment

### Benchmark Reports on PRs

When you open a PR, the CI will automatically:
- Transpile all benchmark contracts
- Run the benchmark suite comparing against Solc
- Post results as a comment on your PR

This helps reviewers understand the impact of your changes on bytecode size.

### Running CI Locally

To simulate what CI does:

```bash
# Full pipeline (same as CI)
python3.11 testing/test_framework.py --prepare-all
python3.11 testing/test_framework.py --transpile-all
cd foundry && forge test --match-path "test/bench/*.t.sol"

# Generate benchmark report
python3.11 tools/benchmark.py --output report.md
```

---

Thank you for contributing to Yul2Venom! 🎉
