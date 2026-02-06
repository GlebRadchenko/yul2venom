# Yul2Venom Benchmark Report

**Generated:** 2026-02-06 12:20:20
**Baseline:** `default_200`

---

## Summary

- **Contracts benchmarked:** 1
- **Transpilation success:** 1/1
- **Optimization runs tested:** [200]
- **Solc modes:** ['default']

## Bytecode Size (bytes)

| Contract           |  Transpiled  | default_200  |
|------------------|:----------:|:----------:|
| Arithmetic         |     1586     |     1368     |

## Size Delta vs Baseline (`default_200`)

| Contract           |  Transpiled  |
|------------------|:----------:|
| Arithmetic         |    +15.9%    |

---

## Configuration

| Setting | Value |
|---------|-------|
| Baseline | `default_200` |
| Optimization Runs | `[200]` |
| Solc Modes | `['default']` |

### Mode Descriptions

- **default**: `solc --optimize --optimizer-runs=N` (traditional optimizer)
- **via_ir**: `solc --via-ir --optimize --optimizer-runs=N` (Yul-based optimizer)
- **ir_optimized**: `solc --ir-optimized --optimize` (outputs optimized Yul IR)
- **Transpiled**: Yul → Venom IR → EVM via Yul2Venom

### Interpretation

- **Negative delta** = smaller than baseline (better)
- **Positive delta** = larger than baseline (worse)
- **FAILED** = compilation/transpilation failed