# Yul2Venom Benchmark Report

**Generated:** 2026-02-01 21:22:08
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
| Arithmetic         |     1644     |     1368     |     1368     |     1650     |
| ControlFlow        |     1007     |     962      |     962      |     1043     |
| StateManagement    |     2502     |     2686     |     2686     |     2981     |
| DataStructures     |     1546     |     1576     |     1576     |     2031     |
| Functions          |     2716     |     2452     |     2452     |     3477     |
| Events             |     781      |     826      |     826      |     1163     |
| Encoding           |     1069     |     976      |     976      |     1264     |
| Edge               |     2816     |     3112     |     3112     |     3787     |

## Size Delta vs Baseline (`ir_optimized`)

| Contract           |  Transpiled  | default_200  |  via_ir_200  |
|------------------|:----------:|:----------:|:----------:|
| Arithmetic         |    -0.4%     |    -17.1%    |    -17.1%    |
| ControlFlow        |    -3.5%     |    -7.8%     |    -7.8%     |
| StateManagement    |    -16.1%    |    -9.9%     |    -9.9%     |
| DataStructures     |    -23.9%    |    -22.4%    |    -22.4%    |
| Functions          |    -21.9%    |    -29.5%    |    -29.5%    |
| Events             |    -32.8%    |    -29.0%    |    -29.0%    |
| Encoding           |    -15.4%    |    -22.8%    |    -22.8%    |
| Edge               |    -25.6%    |    -17.8%    |    -17.8%    |

---

## Gas Usage (avg gas per function call)

### Arithmetic

| Function | Transpiled (aggressive+yul-o2) | Native (Solc ir_optimized) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| and_ | 190 | 485 | -60.8% |
| eq | 195 | 287 | -32.1% |
| gt | 190 | 221 | -14.0% |
| gte | 193 | 642 | -69.9% |
| iszero | 154 | 770 | -80.0% |
| lt | 189 | 191 | -1.0% |
| lte | 193 | 796 | -75.8% |
| not_ | 154 | 707 | -78.2% |
| or_ | 195 | 331 | -41.1% |
| safeAdd | 248 | 799 | -69.0% |
| safeDiv | 240 | 697 | -65.6% |
| safeExp | 318 | 524 | -39.3% |
| safeMod | 212 | 477 | -55.6% |
| safeMul | 250 | 783 | -68.1% |
| safeSub | 225 | 601 | -62.6% |
| sar | 160 | 559 | -71.4% |
| sgt | 190 | 265 | -28.3% |
| shl | 213 | 529 | -59.7% |
| shr | 190 | 463 | -59.0% |
| signExtend16 | 165 | 652 | -74.7% |
| signExtend8 | 187 | 365 | -48.8% |
| slt | 190 | 353 | -46.2% |
| unsafeAdd | 190 | 309 | -38.5% |
| unsafeDiv | 212 | 653 | -67.5% |
| unsafeExp | 247 | 564 | -56.2% |
| unsafeMod | 258 | 741 | -65.2% |
| unsafeMul | 192 | 421 | -54.4% |
| unsafeSub | 190 | 551 | -65.5% |
| xor_ | 195 | 243 | -19.8% |

### ControlFlow

| Function | Transpiled (aggressive+yul-o2) | Native (Solc ir_optimized) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| breakLoop | 1310 | 1858 | -29.5% |
| continueLoop | 1497 | 1678 | -10.8% |
| earlyReturn | 175 | 354 | -50.6% |
| ifElse | 205 | 294 | -30.3% |
| loopCount | 8114 | 11415 | -28.9% |
| loopSum | 677 | 706 | -4.1% |
| nestedLoop | 1517 | 1778 | -14.7% |
| ternary | 233 | 347 | -32.9% |
| whileLoop | 3415 | 4872 | -29.9% |

### StateManagement

| Function | Transpiled (aggressive+yul-o2) | Native (Solc ir_optimized) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| CONST_HASH | 194 | 986 | -80.3% |
| CONST_VALUE | 171 | 876 | -80.5% |
| balances | 2321 | 2533 | -8.4% |
| getArrayElement | 460 | 547 | -15.9% |
| getArrayLength | 2247 | 2245 | +0.1% |
| getMappingValue | 2315 | 2912 | -20.5% |
| getNestedMap | 414 | 1191 | -65.2% |
| getPackedAB | 278 | 547 | -49.2% |
| getStoredBool | 2288 | 2507 | -8.7% |
| getStoredUint | 2270 | 2802 | -19.0% |
| incrementBalance | 20335 | 20593 | -1.3% |
| memoryAlloc | 361 | 726 | -50.3% |
| memoryCopy | 1823 | 3154 | -42.2% |
| popArray | 532 | 1329 | -60.0% |
| pushArray | 42444 | 42720 | -0.6% |
| setMappingValue | 20239 | 21055 | -3.9% |
| setNestedMap | 22355 | 22721 | -1.6% |
| setPackedAB | 22300 | 22998 | -3.0% |
| setStoredBool | 20288 | 20315 | -0.1% |
| setStoredUint | 20126 | 20179 | -0.3% |

### DataStructures

| Function | Transpiled (aggressive+yul-o2) | Native (Solc ir_optimized) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| bytesConcat | 669 | 851 | -21.4% |
| bytesLength | 271 | 385 | -29.6% |
| createArray | 1579 | 2099 | -24.8% |
| createStruct | 298 | 510 | -41.6% |
| dynamicArraySum | 612 | 896 | -31.7% |
| fixedArraySum | 706 | 964 | -26.8% |
| processStruct | 230 | 235 | -2.1% |
| processStructArray | 1680 | 2463 | -31.8% |

### Functions

| Function | Transpiled (aggressive+yul-o2) | Native (Solc ir_optimized) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| callInternal | 201 | 528 | -61.9% |
| callSelf | 700 | 1171 | -40.2% |
| callVirtualA | 136 | 594 | -77.1% |
| callVirtualB | 136 | 142 | -4.2% |
| factorial | 275 | 487 | -43.5% |
| fibonacci | 269 | 394 | -31.7% |
| interfaceFunc | 141 | 506 | -72.1% |
| nestedInternal | 192 | 302 | -36.4% |
| returnMultiple | 172 | 736 | -76.6% |
| returnNothing | 136 | 350 | -61.1% |
| returnSingle | 136 | 462 | -70.6% |
| selfAdd | 178 | 286 | -37.8% |

### Events

| Function | Transpiled (aggressive+yul-o2) | Native (Solc ir_optimized) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| emitBytes | 1899 | 2068 | -8.2% |
| emitComplex | 2954 | 3059 | -3.4% |
| emitIndexed | 1575 | 1676 | -6.0% |
| emitMultiIndexed | 2031 | 2094 | -3.0% |
| emitMultiple | 5577 | 5564 | +0.2% |
| emitSimple | 1162 | 1273 | -8.7% |
| emitString | 1869 | 1969 | -5.1% |

### Encoding

| Function | Transpiled (aggressive+yul-o2) | Native (Solc ir_optimized) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| abiEncode | 375 | 603 | -37.8% |
| abiEncodePacked | 398 | 537 | -25.9% |
| abiEncodeWithSelector | 387 | 557 | -30.5% |
| decodePair | 304 | 393 | -22.6% |
| encodeMultiple | 689 | 1005 | -31.4% |
| encodePackedMixed | 427 | 696 | -38.6% |
| keccak256Encode | 304 | 483 | -37.1% |
| keccak256Hash | 509 | 747 | -31.9% |
| keccak256Packed | 304 | 417 | -27.1% |

### Edge

| Function | Transpiled (aggressive+yul-o2) | Native (Solc ir_optimized) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| CodeIsLawZ95677371 | 183 | N/A | N/A |
| assertCondition | 221 | 565 | -60.9% |
| checkGas | 146 | 728 | -79.9% |
| fallback | N/A | 712 | N/A |
| getBlockInfo | 182 | 175 | +4.0% |
| getMsgInfo | 215 | 643 | -66.6% |
| mayFail | 296 | 799 | -63.0% |
| requireTrue | 291 | 598 | -51.3% |
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