# Yul2Venom Benchmark Report

**Generated:** 2026-01-31 18:43:43
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
| Arithmetic         |     1987     |     1368     |     1368     |     1650     |
| ControlFlow        |     1310     |     962      |     962      |     1043     |
| StateManagement    |     3774     |     2832     |     2832     |     3135     |
| DataStructures     |     2431     |     1576     |     1576     |     2031     |
| Functions          |     4406     |     2452     |     2452     |     3477     |
| Events             |     1057     |     826      |     826      |     1163     |
| Encoding           |     1791     |     976      |     976      |     1264     |
| Edge               |     4206     |     3112     |     3112     |     3787     |

## Size Delta vs Baseline (`default_200`)

| Contract           |  Transpiled  |  via_ir_200  | ir_optimized |
|------------------|:----------:|:----------:|:----------:|
| Arithmetic         |    +45.2%    |    +0.0%     |    +20.6%    |
| ControlFlow        |    +36.2%    |    +0.0%     |    +8.4%     |
| StateManagement    |    +33.3%    |    +0.0%     |    +10.7%    |
| DataStructures     |    +54.3%    |    +0.0%     |    +28.9%    |
| Functions          |    +79.7%    |    +0.0%     |    +41.8%    |
| Events             |    +28.0%    |    +0.0%     |    +40.8%    |
| Encoding           |    +83.5%    |    +0.0%     |    +29.5%    |
| Edge               |    +35.2%    |    +0.0%     |    +21.7%    |

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
| breakLoop | N/A | 1858 | N/A |
| continueLoop | N/A | 1678 | N/A |
| earlyReturn | N/A | 354 | N/A |
| ifElse | N/A | 294 | N/A |
| loopCount | N/A | 11415 | N/A |
| loopSum | N/A | 706 | N/A |
| nestedLoop | N/A | 1778 | N/A |
| ternary | N/A | 347 | N/A |
| whileLoop | N/A | 4872 | N/A |

### StateManagement

| Function | Transpiled | Native (Solc) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| CONST_HASH | N/A | 1074 | N/A |
| CONST_VALUE | N/A | 964 | N/A |
| balances | N/A | 2577 | N/A |
| getArrayElement | N/A | 591 | N/A |
| getArrayLength | N/A | 2289 | N/A |
| getMappingValue | N/A | 3000 | N/A |
| getNestedMap | N/A | 1279 | N/A |
| getPackedAB | N/A | 591 | N/A |
| getStoredBool | N/A | 2551 | N/A |
| getStoredUint | N/A | 2890 | N/A |
| incrementBalance | N/A | 20637 | N/A |
| memoryAlloc | N/A | 770 | N/A |
| memoryCopy | N/A | 3220 | N/A |
| popArray | N/A | 1417 | N/A |
| pushArray | N/A | 42764 | N/A |
| setMappingValue | N/A | 21143 | N/A |
| setNestedMap | N/A | 22787 | N/A |
| setPackedAB | N/A | 23086 | N/A |
| setStoredBool | N/A | 20359 | N/A |
| setStoredUint | N/A | 20223 | N/A |
| tload | N/A | 851 | N/A |
| transientIncrement | N/A | 697 | N/A |
| transientSwap | N/A | 604 | N/A |
| tstore | N/A | 273 | N/A |

### DataStructures

| Function | Transpiled | Native (Solc) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| bytesConcat | N/A | 851 | N/A |
| bytesLength | N/A | 385 | N/A |
| createArray | N/A | 2099 | N/A |
| createStruct | N/A | 510 | N/A |
| dynamicArraySum | N/A | 896 | N/A |
| fixedArraySum | N/A | 964 | N/A |
| processStruct | N/A | 235 | N/A |
| processStructArray | N/A | 2463 | N/A |

### Functions

| Function | Transpiled | Native (Solc) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| callInternal | N/A | 528 | N/A |
| callSelf | N/A | 1171 | N/A |
| callVirtualA | N/A | 594 | N/A |
| callVirtualB | N/A | 142 | N/A |
| factorial | N/A | 487 | N/A |
| fibonacci | N/A | 394 | N/A |
| interfaceFunc | N/A | 506 | N/A |
| nestedInternal | N/A | 302 | N/A |
| returnMultiple | N/A | 736 | N/A |
| returnNothing | N/A | 350 | N/A |
| returnSingle | N/A | 462 | N/A |
| selfAdd | N/A | 286 | N/A |

### Events

| Function | Transpiled | Native (Solc) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| emitBytes | N/A | 2068 | N/A |
| emitComplex | N/A | 3059 | N/A |
| emitIndexed | N/A | 1676 | N/A |
| emitMultiIndexed | N/A | 2094 | N/A |
| emitMultiple | N/A | 5564 | N/A |
| emitSimple | N/A | 1273 | N/A |
| emitString | N/A | 1969 | N/A |

### Encoding

| Function | Transpiled | Native (Solc) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| abiEncode | N/A | 603 | N/A |
| abiEncodePacked | N/A | 537 | N/A |
| abiEncodeWithSelector | N/A | 557 | N/A |
| decodePair | N/A | 393 | N/A |
| encodeMultiple | N/A | 1005 | N/A |
| encodePackedMixed | N/A | 696 | N/A |
| keccak256Encode | N/A | 483 | N/A |
| keccak256Hash | N/A | 747 | N/A |
| keccak256Packed | N/A | 417 | N/A |

### Edge

| Function | Transpiled | Native (Solc) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| assertCondition | N/A | 565 | N/A |
| checkGas | N/A | 728 | N/A |
| fallback | N/A | 712 | N/A |
| getBlockInfo | N/A | 175 | N/A |
| getMsgInfo | N/A | 643 | N/A |
| mayFail | N/A | 799 | N/A |
| requireTrue | N/A | 598 | N/A |
| requireValue | N/A | 433 | N/A |
| tryCall | N/A | 1390 | N/A |


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