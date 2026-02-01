# Yul2Venom Benchmark Report

**Generated:** 2026-02-01 22:37:13
**Baseline:** `ir_optimized`

---

## Summary

- **Contracts benchmarked:** 15
- **Transpilation success:** 15/15
- **Optimization runs tested:** [200]
- **Solc modes:** ['default', 'ir_optimized']

## Bytecode Size (bytes)

| Contract           |  Transpiled  | default_200  | ir_optimized |
|------------------|:----------:|:----------:|:----------:|
| Arithmetic         |     1644     |     1368     |     1650     |
| ControlFlow        |     1007     |     962      |     1043     |
| StateManagement    |     2502     |     2686     |     2981     |
| DataStructures     |     1546     |     1576     |     2031     |
| Functions          |     2716     |     2452     |     3477     |
| Events             |     781      |     826      |     1163     |
| Encoding           |     1069     |     976      |     1264     |
| Edge               |     2816     |     3112     |     3787     |
| AdvancedFeatures   |     4657     |     3270     |     3918     |
| ExternalLibrary    |     1610     |    FAILED    |    FAILED    |
| Libraries          |     5310     |     3080     |     3857     |
| Modifiers          |     3443     |     2446     |     3242     |
| SoladyToken        |     4094     |     3299     |     3474     |
| TransientStorage   |     1389     |     1760     |     2010     |
| TypeLimits         |     1495     |     1722     |     1728     |

## Size Delta vs Baseline (`ir_optimized`)

| Contract           |  Transpiled  | default_200  |
|------------------|:----------:|:----------:|
| Arithmetic         |    -0.4%     |    -17.1%    |
| ControlFlow        |    -3.5%     |    -7.8%     |
| StateManagement    |    -16.1%    |    -9.9%     |
| DataStructures     |    -23.9%    |    -22.4%    |
| Functions          |    -21.9%    |    -29.5%    |
| Events             |    -32.8%    |    -29.0%    |
| Encoding           |    -15.4%    |    -22.8%    |
| Edge               |    -25.6%    |    -17.8%    |
| AdvancedFeatures   |    +18.9%    |    -16.5%    |
| ExternalLibrary    |     N/A      |     N/A      |
| Libraries          |    +37.7%    |    -20.1%    |
| Modifiers          |    +6.2%     |    -24.6%    |
| SoladyToken        |    +17.8%    |    -5.0%     |
| TransientStorage   |    -30.9%    |    -12.4%    |
| TypeLimits         |    -13.5%    |    -0.3%     |

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

### AdvancedFeatures

| Function | Transpiled (aggressive+yul-o2) | Native (Solc ir_optimized) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| addAmounts | 339 | 817 | -58.5% |
| addressToBytes20 | 255 | 686 | -62.8% |
| andBytes4 | 319 | 678 | -52.9% |
| bytes20ToAddress | 249 | 854 | -70.8% |
| bytes4Selector | 214 | 788 | -72.8% |
| concatBytes | 546 | 775 | -29.5% |
| concatMultiple | 597 | 1470 | -59.4% |
| concatStrings | 862 | 895 | -3.7% |
| concatThreeStrings | 1077 | 1616 | -33.4% |
| encodeApprove | 577 | 1284 | -55.1% |
| encodeBalanceOf | 519 | 810 | -35.9% |
| encodeTransfer | 582 | 1042 | -44.1% |
| encodeTransferManual | 577 | 756 | -23.7% |
| extractBytes4FromBytes32 | 288 | 930 | -69.0% |
| extractBytes8FromBytes32 | 265 | 644 | -58.9% |
| getAmount | 432 | 1133 | -61.9% |
| getByteAt | 295 | 262 | +12.6% |
| getTokenOwner | 382 | 742 | -48.5% |
| mintToken | 44564 | 44533 | +0.1% |
| notBytes4 | 255 | 1098 | -76.8% |
| orBytes4 | 319 | 392 | -18.6% |
| percentageToUint | 283 | 895 | -68.4% |
| setAmount | 22429 | 23064 | -2.8% |
| setBytes1 | 22391 | 23172 | -3.4% |
| setBytes16 | 22367 | 22393 | -0.1% |
| setBytes2 | 22358 | 22371 | -0.1% |
| setBytes20 | 22341 | 22639 | -1.3% |
| setBytes32 | 22283 | 22742 | -2.0% |
| setBytes4 | 22370 | 22508 | -0.6% |
| setBytes8 | 22365 | 22547 | -0.8% |
| storedBytes1 | 349 | 859 | -59.4% |
| storedBytes16 | 369 | 837 | -55.9% |
| storedBytes2 | 326 | 397 | -17.9% |
| storedBytes20 | 323 | 463 | -30.2% |
| storedBytes32 | 326 | 627 | -48.0% |
| storedBytes4 | 367 | 529 | -30.6% |
| storedBytes8 | 321 | 595 | -46.1% |
| xorBytes4 | 291 | 1008 | -71.1% |

### ExternalLibrary

| Function | Transpiled (aggressive+yul-o2) | Native (Solc ir_optimized) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| testAddInternal | 307 | N/A | N/A |

### Libraries

| Function | Transpiled (aggressive+yul-o2) | Native (Solc ir_optimized) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| decrementBy | 422 | 576 | -26.7% |
| directLibraryCall | 251 | 503 | -50.1% |
| getStoredValue | 247 | 318 | -22.3% |
| incrementBy | 422 | 502 | -15.9% |
| multiplyBy | 486 | 926 | -47.5% |
| processData | 2730 | 4128 | -33.9% |
| setStoredValue | 22221 | 22345 | -0.6% |
| testAdd | 274 | 591 | -53.6% |
| testAddressToBytes | 345 | 966 | -64.3% |
| testArrayContains | 911 | 1501 | -39.3% |
| testArrayMax | 1240 | 1819 | -31.8% |
| testArrayMin | 1286 | 2124 | -39.5% |
| testArraySum | 1042 | 1837 | -43.3% |
| testChainedMath | 349 | 759 | -54.0% |
| testComplexMath | 376 | 939 | -60.0% |
| testDiv | 229 | 429 | -46.6% |
| testIsContract | 262 | 382 | -31.4% |
| testMod | 217 | 270 | -19.6% |
| testMul | 297 | 717 | -58.6% |
| testStringEmpty | 429 | 785 | -45.4% |
| testStringEquals | 793 | 1592 | -50.2% |
| testStringLength | 478 | 1008 | -52.6% |
| testSub | 274 | 741 | -63.0% |

### Modifiers

| Function | Transpiled (aggressive+yul-o2) | Native (Solc ir_optimized) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| addAdmin | 24560 | 24840 | -1.1% |
| adminAction | 26645 | 26813 | -0.6% |
| admins | 410 | 595 | -31.1% |
| blockedFunction | 274 | 460 | -40.4% |
| conditionalIncrement | 213 | 210 | +1.4% |
| counter | 303 | 575 | -47.3% |
| fullProtection | 2340 | 2283 | +2.5% |
| getCounter | 4509 | 4826 | -6.6% |
| getState | 4462 | 4558 | -2.1% |
| incrementWithAfterMod | 22352 | 22506 | -0.7% |
| incrementWithMiddleMod | 22334 | 22373 | -0.2% |
| loggedIncrement | 26141 | 26564 | -1.6% |
| multiEdgeCase | 22370 | 22514 | -0.6% |
| owner | 331 | 690 | -52.0% |
| ownerAction | 24510 | 24857 | -1.4% |
| paused | 348 | 548 | -36.5% |
| pureAdd | 251 | 697 | -64.0% |
| removeAdmin | 608 | 692 | -12.1% |
| restrictedAction | 26673 | 26902 | -0.9% |
| safeIncrement | 22356 | 22365 | -0.0% |
| setOwner | 5252 | 5284 | -0.6% |
| setPaused | 5287 | 5332 | -0.8% |
| wrappedIncrement | 22382 | 22823 | -1.9% |

### SoladyToken

| Function | Transpiled (aggressive+yul-o2) | Native (Solc ir_optimized) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| allowance | 887 | 887 | +0.0% |
| approve | 24234 | 24234 | +0.0% |
| balanceOf | 580 | 580 | +0.0% |
| burn | 2648 | 2648 | +0.0% |
| burnFrom | 3139 | 3139 | +0.0% |
| decimals | 2339 | 2339 | +0.0% |
| mint | 48595 | 48595 | +0.0% |
| mintBatch | 98182 | 98182 | +0.0% |
| name | 2702 | 2702 | +0.0% |
| safeTransfer | 24650 | 24650 | +0.0% |
| safeTransferFrom | 25098 | 25098 | +0.0% |
| symbol | 3020 | 3020 | +0.0% |
| totalSupply | 289 | 289 | +0.0% |
| transfer | 24804 | 24804 | +0.0% |
| transferFrom | 24966 | 24966 | +0.0% |

### TransientStorage

| Function | Transpiled (aggressive+yul-o2) | Native (Solc ir_optimized) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| clearLock | 218 | 517 | -57.8% |
| getBoth | 387 | 567 | -31.7% |
| getCallbackSender | 254 | 303 | -16.2% |
| getTransientCounter | 253 | 605 | -58.2% |
| incrementTransientCounter | 368 | 497 | -26.0% |
| isLocked | 259 | 501 | -48.3% |
| protectedFunction | 369 | 497 | -25.8% |
| resetTransientCounter | 218 | 341 | -36.1% |
| setLock | 219 | 408 | -46.3% |
| storeRegular | 22249 | 22631 | -1.7% |
| storeTransient | 267 | 653 | -59.1% |
| tload | 256 | 477 | -46.3% |
| tloadAddress | 257 | 351 | -26.8% |
| tloadBytes32 | 297 | 565 | -47.4% |
| tloadMultiple | 1099 | 1701 | -35.4% |
| tstore | 260 | 273 | -4.8% |
| tstoreAddress | 248 | 531 | -53.3% |
| tstoreAndLoad | 316 | 858 | -63.2% |
| tstoreBytes32 | 248 | 679 | -63.5% |
| tstoreMultiple | 968 | 1395 | -30.6% |

### TypeLimits

| Function | Transpiled (aggressive+yul-o2) | Native (Solc ir_optimized) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| clampToInt128 | 228 | 486 | -53.1% |
| clampToUint8 | 204 | 438 | -53.4% |
| fitsInInt64 | 209 | 622 | -66.4% |
| fitsInUint128 | 186 | 754 | -75.3% |
| getConstants | 210 | 556 | -62.2% |
| getInterfaceId | 154 | 414 | -62.8% |
| int128Limits | 215 | 718 | -70.1% |
| int16Limits | 174 | 234 | -25.6% |
| int256Limits | 165 | 163 | +1.2% |
| int32Limits | 174 | 542 | -67.9% |
| int64Limits | 192 | 674 | -71.5% |
| int8Limits | 215 | 696 | -69.1% |
| isMaxUint256 | 180 | 732 | -75.4% |
| isMinInt256 | 168 | 446 | -62.3% |
| maxForBits | 277 | 461 | -39.9% |
| safeAdd | 285 | 736 | -61.3% |
| uint128Limits | 170 | 365 | -53.4% |
| uint16Limits | 165 | 475 | -65.3% |
| uint256Limits | 172 | 255 | -32.5% |
| uint32Limits | 170 | 211 | -19.4% |
| uint64Limits | 193 | 321 | -39.9% |
| uint8Limits | 165 | 299 | -44.8% |
| wouldOverflow | 216 | 535 | -59.6% |
| wouldUnderflow | 213 | 642 | -66.8% |


---

## Configuration

| Setting | Value |
|---------|-------|
| Baseline | `ir_optimized` |
| Optimization Runs | `[200]` |
| Solc Modes | `['default', 'ir_optimized']` |

### Mode Descriptions

- **default**: `solc --optimize --optimizer-runs=N` (traditional optimizer)
- **via_ir**: `solc --via-ir --optimize --optimizer-runs=N` (Yul-based optimizer)
- **ir_optimized**: `solc --ir-optimized --optimize` (outputs optimized Yul IR)
- **Transpiled**: Yul → Venom IR → EVM via Yul2Venom

### Interpretation

- **Negative delta** = smaller than baseline (better)
- **Positive delta** = larger than baseline (worse)
- **FAILED** = compilation/transpilation failed