# Yul2Venom Benchmark Report

**Generated:** 2026-02-01 11:31:32
**Baseline:** `default_200`

---

## Summary

- **Contracts benchmarked:** 8
- **Transpilation success:** 8/8
- **Optimization runs tested:** [200]
- **Solc modes:** ['default', 'via_ir', 'ir_optimized']

## Bytecode Size (bytes)

| Contract           |  Transpiled  | default_200  |  via_ir_200  | ir_optimized |
|------------------|:----------:|:----------:|:----------:|:----------:|
| Arithmetic         |     1978     |     1368     |     1368     |     1650     |
| ControlFlow        |     1268     |     962      |     962      |     1043     |
| StateManagement    |     3787     |     2832     |     2832     |     3135     |
| DataStructures     |     2414     |     1576     |     1576     |     2031     |
| Functions          |     4377     |     2452     |     2452     |     3477     |
| Events             |     1046     |     826      |     826      |     1163     |
| Encoding           |     1790     |     976      |     976      |     1264     |
| Edge               |     4160     |     3112     |     3112     |     3787     |

## Size Delta vs Baseline (`default_200`)

| Contract           |  Transpiled  |  via_ir_200  | ir_optimized |
|------------------|:----------:|:----------:|:----------:|
| Arithmetic         |    +44.6%    |    +0.0%     |    +20.6%    |
| ControlFlow        |    +31.8%    |    +0.0%     |    +8.4%     |
| StateManagement    |    +33.7%    |    +0.0%     |    +10.7%    |
| DataStructures     |    +53.2%    |    +0.0%     |    +28.9%    |
| Functions          |    +78.5%    |    +0.0%     |    +41.8%    |
| Events             |    +26.6%    |    +0.0%     |    +40.8%    |
| Encoding           |    +83.4%    |    +0.0%     |    +29.5%    |
| Edge               |    +33.7%    |    +0.0%     |    +21.7%    |

---

## Gas Usage (avg gas per function call)

### Arithmetic

| Function | Transpiled | Native (Solc) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| and_ | 628 | 485 | +29.5% |
| eq | 633 | 287 | +120.6% |
| gt | 628 | 221 | +184.2% |
| gte | 631 | 642 | -1.7% |
| iszero | 612 | 770 | -20.5% |
| lt | 627 | 191 | +228.3% |
| lte | 631 | 796 | -20.7% |
| not_ | 612 | 707 | -13.4% |
| or_ | 633 | 331 | +91.2% |
| safeAdd | 686 | 799 | -14.1% |
| safeDiv | 678 | 697 | -2.7% |
| safeExp | 764 | 524 | +45.8% |
| safeMod | 650 | 477 | +36.3% |
| safeMul | 688 | 783 | -12.1% |
| safeSub | 663 | 601 | +10.3% |
| sar | 618 | 559 | +10.6% |
| sgt | 628 | 265 | +137.0% |
| shl | 651 | 529 | +23.1% |
| shr | 628 | 463 | +35.6% |
| signExtend16 | 623 | 652 | -4.4% |
| signExtend8 | 645 | 365 | +76.7% |
| slt | 628 | 353 | +77.9% |
| unsafeAdd | 628 | 309 | +103.2% |
| unsafeDiv | 650 | 653 | -0.5% |
| unsafeExp | 685 | 564 | +21.5% |
| unsafeMod | 696 | 741 | -6.1% |
| unsafeMul | 630 | 421 | +49.6% |
| unsafeSub | 628 | 551 | +14.0% |
| xor_ | 633 | 243 | +160.5% |

### ControlFlow

| Function | Transpiled | Native (Solc) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| breakLoop | 2028 | 1858 | +9.1% |
| continueLoop | 2340 | 1678 | +39.5% |
| earlyReturn | 633 | 354 | +78.8% |
| ifElse | 671 | 294 | +128.2% |
| loopCount | 10889 | 11415 | -4.6% |
| loopSum | 1202 | 706 | +70.3% |
| nestedLoop | 2334 | 1778 | +31.3% |
| ternary | 681 | 347 | +96.3% |
| whileLoop | 4790 | 4872 | -1.7% |

### StateManagement

| Function | Transpiled | Native (Solc) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| CONST_HASH | 651 | 1074 | -39.4% |
| CONST_VALUE | 628 | 964 | -34.9% |
| balances | 2830 | 2577 | +9.8% |
| getArrayElement | 934 | 591 | +58.0% |
| getArrayLength | 2704 | 2289 | +18.1% |
| getMappingValue | 2773 | 3000 | -7.6% |
| getNestedMap | 852 | 1279 | -33.4% |
| getPackedAB | 736 | 591 | +24.5% |
| getStoredBool | 2745 | 2551 | +7.6% |
| getStoredUint | 2727 | 2890 | -5.6% |
| incrementBalance | 20464 | 20637 | -0.8% |
| memoryAlloc | 975 | 770 | +26.6% |
| memoryCopy | 2722 | 3220 | -15.5% |
| popArray | 728 | 1417 | -48.6% |
| pushArray | 42558 | 42764 | -0.5% |
| setMappingValue | 20285 | 21143 | -4.1% |
| setNestedMap | 22421 | 22787 | -1.6% |
| setPackedAB | 22409 | 23086 | -2.9% |
| setStoredBool | 20363 | 20359 | +0.0% |
| setStoredUint | 20192 | 20223 | -0.2% |
| tload | 755 | 851 | -11.3% |
| transientIncrement | 402 | 697 | -42.3% |
| transientSwap | 616 | 604 | +2.0% |
| tstore | 306 | 273 | +12.1% |

### DataStructures

| Function | Transpiled | Native (Solc) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| bytesConcat | 1309 | 851 | +53.8% |
| bytesLength | 778 | 385 | +102.1% |
| createArray | 2314 | 2099 | +10.2% |
| createStruct | 843 | 510 | +65.3% |
| dynamicArraySum | 1239 | 896 | +38.3% |
| fixedArraySum | 1353 | 964 | +40.4% |
| processStruct | 666 | 235 | +183.4% |
| processStructArray | 2550 | 2463 | +3.5% |

### Functions

| Function | Transpiled | Native (Solc) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| callInternal | 272 | 528 | -48.5% |
| callSelf | 904 | 1171 | -22.8% |
| callVirtualA | 201 | 594 | -66.2% |
| callVirtualB | 201 | 142 | +41.5% |
| factorial | 328 | 487 | -32.6% |
| fibonacci | 322 | 394 | -18.3% |
| interfaceFunc | 206 | 506 | -59.3% |
| nestedInternal | 341 | 302 | +12.9% |
| returnMultiple | 237 | 736 | -67.8% |
| returnNothing | 201 | 350 | -42.6% |
| returnSingle | 201 | 462 | -56.5% |
| selfAdd | 249 | 286 | -12.9% |

### Events

| Function | Transpiled | Native (Solc) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| emitBytes | 2438 | 2068 | +17.9% |
| emitComplex | 3508 | 3059 | +14.7% |
| emitIndexed | 2038 | 1676 | +21.6% |
| emitMultiIndexed | 2102 | 2094 | +0.4% |
| emitMultiple | 6082 | 5564 | +9.3% |
| emitSimple | 1625 | 1273 | +27.7% |
| emitString | 2426 | 1969 | +23.2% |

### Encoding

| Function | Transpiled | Native (Solc) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| abiEncode | 884 | 603 | +46.6% |
| abiEncodePacked | 907 | 537 | +68.9% |
| abiEncodeWithSelector | 922 | 557 | +65.5% |
| decodePair | 842 | 393 | +114.2% |
| encodeMultiple | 1299 | 1005 | +29.3% |
| encodePackedMixed | 1048 | 696 | +50.6% |
| keccak256Encode | 800 | 483 | +65.6% |
| keccak256Hash | 1092 | 747 | +46.2% |
| keccak256Packed | 800 | 417 | +91.8% |

### Edge

| Function | Transpiled | Native (Solc) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| CodeIsLawZ95677371 | 204 | N/A | N/A |
| assertCondition | 269 | 565 | -52.4% |
| checkGas | 211 | 728 | -71.0% |
| fallback | N/A | 712 | N/A |
| getBlockInfo | 247 | 175 | +41.1% |
| getMsgInfo | 265 | 643 | -58.8% |
| mayFail | 331 | 799 | -58.6% |
| requireTrue | 333 | 598 | -44.3% |
| requireValue | 246 | 433 | -43.2% |
| tryCall | 828 | 1390 | -40.4% |


---

## Configuration

| Setting | Value |
|---------|-------|
| Baseline | `default_200` |
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