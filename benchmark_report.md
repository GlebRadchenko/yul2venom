# Yul2Venom Benchmark Report

**Generated:** 2026-02-01 11:57:10
**Baseline:** `ir_optimized`

---

## Summary

- **Contracts benchmarked:** 8
- **Transpilation success:** 8/8
- **Optimization runs tested:** [200]
- **Solc modes:** ['default', 'via_ir', 'ir_optimized']

## Bytecode Size (bytes)

| Contract           |  Transpiled  | default_200  |  via_ir_200  | ir_optimized |
|------------------|:----------:|:----------:|:----------:|:----------:|
| Arithmetic         |     1596     |     1368     |     1368     |     1650     |
| ControlFlow        |     998      |     962      |     962      |     1043     |
| StateManagement    |     2499     |     2832     |     2832     |     3135     |
| DataStructures     |     1545     |     1576     |     1576     |     2031     |
| Functions          |     2705     |     2452     |     2452     |     3477     |
| Events             |     778      |     826      |     826      |     1163     |
| Encoding           |     1060     |     976      |     976      |     1264     |
| Edge               |     2800     |     3112     |     3112     |     3787     |

## Size Delta vs Baseline (`ir_optimized`)

| Contract           |  Transpiled  | default_200  |  via_ir_200  |
|------------------|:----------:|:----------:|:----------:|
| Arithmetic         |    -3.3%     |    -17.1%    |    -17.1%    |
| ControlFlow        |    -4.3%     |    -7.8%     |    -7.8%     |
| StateManagement    |    -20.3%    |    -9.7%     |    -9.7%     |
| DataStructures     |    -23.9%    |    -22.4%    |    -22.4%    |
| Functions          |    -22.2%    |    -29.5%    |    -29.5%    |
| Events             |    -33.1%    |    -29.0%    |    -29.0%    |
| Encoding           |    -16.1%    |    -22.8%    |    -22.8%    |
| Edge               |    -26.1%    |    -17.8%    |    -17.8%    |

---

## Gas Usage (avg gas per function call)

### Arithmetic

| Function | Transpiled | Native (Solc) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| and_ | 180 | 485 | -62.9% |
| eq | 195 | 287 | -32.1% |
| gt | 180 | 221 | -18.6% |
| gte | 183 | 642 | -71.5% |
| iszero | 154 | 770 | -80.0% |
| lt | 189 | 191 | -1.0% |
| lte | 183 | 796 | -77.0% |
| not_ | 154 | 707 | -78.2% |
| or_ | 195 | 331 | -41.1% |
| safeAdd | 248 | 799 | -69.0% |
| safeDiv | 240 | 697 | -65.6% |
| safeExp | 308 | 524 | -41.2% |
| safeMod | 202 | 477 | -57.7% |
| safeMul | 240 | 783 | -69.3% |
| safeSub | 215 | 601 | -64.2% |
| sar | 160 | 559 | -71.4% |
| sgt | 180 | 265 | -32.1% |
| shl | 213 | 529 | -59.7% |
| shr | 180 | 463 | -61.1% |
| signExtend16 | 165 | 652 | -74.7% |
| signExtend8 | 187 | 365 | -48.8% |
| slt | 180 | 353 | -49.0% |
| unsafeAdd | 180 | 309 | -41.7% |
| unsafeDiv | 202 | 653 | -69.1% |
| unsafeExp | 237 | 564 | -58.0% |
| unsafeMod | 258 | 741 | -65.2% |
| unsafeMul | 182 | 421 | -56.8% |
| unsafeSub | 180 | 551 | -67.3% |
| xor_ | 195 | 243 | -19.8% |

### ControlFlow

| Function | Transpiled | Native (Solc) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| breakLoop | 1300 | 1858 | -30.0% |
| continueLoop | 1497 | 1678 | -10.8% |
| earlyReturn | 175 | 354 | -50.6% |
| ifElse | 205 | 294 | -30.3% |
| loopCount | 8114 | 11415 | -28.9% |
| loopSum | 677 | 706 | -4.1% |
| nestedLoop | 1507 | 1778 | -15.2% |
| ternary | 223 | 347 | -35.7% |
| whileLoop | 3415 | 4872 | -29.9% |

### StateManagement

| Function | Transpiled | Native (Solc) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| CONST_HASH | 194 | 1074 | -81.9% |
| CONST_VALUE | 171 | 964 | -82.3% |
| balances | 2321 | 2577 | -9.9% |
| getArrayElement | 460 | 591 | -22.2% |
| getArrayLength | 2247 | 2289 | -1.8% |
| getMappingValue | 2315 | 3000 | -22.8% |
| getNestedMap | 414 | 1279 | -67.6% |
| getPackedAB | 278 | 591 | -53.0% |
| getStoredBool | 2288 | 2551 | -10.3% |
| getStoredUint | 2270 | 2890 | -21.5% |
| incrementBalance | 20335 | 20637 | -1.5% |
| memoryAlloc | 361 | 770 | -53.1% |
| memoryCopy | 1823 | 3220 | -43.4% |
| popArray | 532 | 1417 | -62.5% |
| pushArray | 42444 | 42764 | -0.7% |
| setMappingValue | 20239 | 21143 | -4.3% |
| setNestedMap | 22355 | 22787 | -1.9% |
| setPackedAB | 22300 | 23086 | -3.4% |
| setStoredBool | 20288 | 20359 | -0.3% |
| setStoredUint | 20126 | 20223 | -0.5% |
| tload | 297 | 851 | -65.1% |
| transientIncrement | 336 | 697 | -51.8% |
| transientSwap | 560 | 604 | -7.3% |
| tstore | 260 | 273 | -4.8% |

### DataStructures

| Function | Transpiled | Native (Solc) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| bytesConcat | 665 | 851 | -21.9% |
| bytesLength | 271 | 385 | -29.6% |
| createArray | 1579 | 2099 | -24.8% |
| createStruct | 298 | 510 | -41.6% |
| dynamicArraySum | 612 | 896 | -31.7% |
| fixedArraySum | 706 | 964 | -26.8% |
| processStruct | 230 | 235 | -2.1% |
| processStructArray | 1680 | 2463 | -31.8% |

### Functions

| Function | Transpiled | Native (Solc) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| callInternal | 201 | 528 | -61.9% |
| callSelf | 690 | 1171 | -41.1% |
| callVirtualA | 136 | 594 | -77.1% |
| callVirtualB | 136 | 142 | -4.2% |
| factorial | 275 | 487 | -43.5% |
| fibonacci | 269 | 394 | -31.7% |
| interfaceFunc | 141 | 506 | -72.1% |
| nestedInternal | 192 | 302 | -36.4% |
| returnMultiple | 172 | 736 | -76.6% |
| returnNothing | 136 | 350 | -61.1% |
| returnSingle | 136 | 462 | -70.6% |
| selfAdd | 168 | 286 | -41.3% |

### Events

| Function | Transpiled | Native (Solc) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| emitBytes | 1892 | 2068 | -8.5% |
| emitComplex | 2954 | 3059 | -3.4% |
| emitIndexed | 1575 | 1676 | -6.0% |
| emitMultiIndexed | 2031 | 2094 | -3.0% |
| emitMultiple | 5577 | 5564 | +0.2% |
| emitSimple | 1162 | 1273 | -8.7% |
| emitString | 1865 | 1969 | -5.3% |

### Encoding

| Function | Transpiled | Native (Solc) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| abiEncode | 365 | 603 | -39.5% |
| abiEncodePacked | 398 | 537 | -25.9% |
| abiEncodeWithSelector | 387 | 557 | -30.5% |
| decodePair | 308 | 393 | -21.6% |
| encodeMultiple | 685 | 1005 | -31.8% |
| encodePackedMixed | 427 | 696 | -38.6% |
| keccak256Encode | 294 | 483 | -39.1% |
| keccak256Hash | 509 | 747 | -31.9% |
| keccak256Packed | 294 | 417 | -29.5% |

### Edge

| Function | Transpiled | Native (Solc) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| CodeIsLawZ95677371 | 183 | N/A | N/A |
| assertCondition | 215 | 565 | -61.9% |
| checkGas | 146 | 728 | -79.9% |
| fallback | N/A | 712 | N/A |
| getBlockInfo | 182 | 175 | +4.0% |
| getMsgInfo | 215 | 643 | -66.6% |
| mayFail | 296 | 799 | -63.0% |
| requireTrue | 295 | 598 | -50.7% |
| requireValue | 205 | 433 | -52.7% |
| tryCall | 731 | 1390 | -47.4% |


---

## Configuration

| Setting | Value |
|---------|-------|
| Baseline | `ir_optimized` |
| Optimization Runs | `[200]` |
| Solc Modes | `['default', 'via_ir', 'ir_optimized']` |

### Mode Descriptions

- **default**: `solc --optimize --optimizer-runs=N` (traditional optimizer)
- **via_ir**: `solc --via-ir --optimize --optimizer-runs=N` (Yul-based optimizer)
- **ir_optimized**: `solc --ir-optimized --optimize` (outputs optimized Yul IR)
- **Transpiled**: Yul → Venom IR → EVM via Yul2Venom

### Interpretation

- **Negative delta** = smaller than baseline (better)
- **Positive delta** = larger than baseline (worse)
- **FAILED** = compilation/transpilation failed