# Yul2Venom Benchmark Report

**Generated:** 2026-02-06 11:53:50
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

## Gas Usage (avg gas per function call)

### Arithmetic

| Function | Transpiled (aggressive+yul-o2) | Native (Solc default_200) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| and_ | 186 | 485 | -61.6% |
| eq | 201 | 287 | -30.0% |
| gt | 186 | 221 | -15.8% |
| gte | 189 | 642 | -70.6% |
| iszero | 160 | 770 | -79.2% |
| lt | 195 | 191 | +2.1% |
| lte | 189 | 796 | -76.3% |
| not_ | 160 | 707 | -77.4% |
| or_ | 201 | 331 | -39.3% |
| safeAdd | 244 | 799 | -69.5% |
| safeDiv | 246 | 697 | -64.7% |
| safeExp | 314 | 524 | -40.1% |
| safeMod | 208 | 477 | -56.4% |
| safeMul | 246 | 783 | -68.6% |
| safeSub | 221 | 601 | -63.2% |
| sar | 166 | 559 | -70.3% |
| sgt | 186 | 265 | -29.8% |
| shl | 209 | 529 | -60.5% |
| shr | 186 | 463 | -59.8% |
| signExtend16 | 171 | 652 | -73.8% |
| signExtend8 | 193 | 365 | -47.1% |
| slt | 186 | 353 | -47.3% |
| unsafeAdd | 186 | 309 | -39.8% |
| unsafeDiv | 208 | 653 | -68.1% |
| unsafeExp | 243 | 564 | -56.9% |
| unsafeMod | 254 | 741 | -65.7% |
| unsafeMul | 188 | 421 | -55.3% |
| unsafeSub | 186 | 551 | -66.2% |
| xor_ | 201 | 243 | -17.3% |


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