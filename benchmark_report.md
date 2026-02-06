# Yul2Venom Benchmark Report

**Generated:** 2026-02-06 20:18:50
**Baseline:** `default_200`

---

## Summary

- **Contracts benchmarked:** 15
- **Transpilation success:** 15/15
- **Optimization runs tested:** [200]
- **Solc modes:** ['default', 'via_ir', 'ir_optimized']

## Bytecode Size (bytes)

| Contract           |  Transpiled  | default_200  |  via_ir_200  | ir_optimized |
|------------------|:----------:|:----------:|:----------:|:----------:|
| AdvancedFeatures   |     2900     |     3270     |     3270     |     3918     |
| Arithmetic         |     1586     |     1368     |     1368     |     1650     |
| ControlFlow        |     1002     |     962      |     962      |     1043     |
| DataStructures     |     1392     |     1576     |     1576     |     2031     |
| Edge               |     2694     |     3112     |     3112     |     3787     |
| Encoding           |     961      |     976      |     976      |     1264     |
| Events             |     735      |     826      |     826      |     1163     |
| ExternalLibrary    |     273      |    FAILED    |    FAILED    |    FAILED    |
| Functions          |     2051     |     2452     |     2452     |     3477     |
| Libraries          |     4166     |     3080     |     3080     |     3857     |
| Modifiers          |     2534     |     2446     |     2446     |     3242     |
| SoladyToken        |     3635     |     3299     |     3299     |     3474     |
| StateManagement    |     2234     |     2686     |     2686     |     2981     |
| TransientStorage   |     1293     |     1760     |     1760     |     2010     |
| TypeLimits         |     1344     |     1722     |     1722     |     1728     |

## Size Delta vs Baseline (`default_200`)

| Contract           |  Transpiled  |  via_ir_200  | ir_optimized |
|------------------|:----------:|:----------:|:----------:|
| AdvancedFeatures   |    -11.3%    |    +0.0%     |    +19.8%    |
| Arithmetic         |    +15.9%    |    +0.0%     |    +20.6%    |
| ControlFlow        |    +4.2%     |    +0.0%     |    +8.4%     |
| DataStructures     |    -11.7%    |    +0.0%     |    +28.9%    |
| Edge               |    -13.4%    |    +0.0%     |    +21.7%    |
| Encoding           |    -1.5%     |    +0.0%     |    +29.5%    |
| Events             |    -11.0%    |    +0.0%     |    +40.8%    |
| ExternalLibrary    |     N/A      |     N/A      |     N/A      |
| Functions          |    -16.4%    |    +0.0%     |    +41.8%    |
| Libraries          |    +35.3%    |    +0.0%     |    +25.2%    |
| Modifiers          |    +3.6%     |    +0.0%     |    +32.5%    |
| SoladyToken        |    +10.2%    |    +0.0%     |    +5.3%     |
| StateManagement    |    -16.8%    |    +0.0%     |    +11.0%    |
| TransientStorage   |    -26.5%    |    +0.0%     |    +14.2%    |
| TypeLimits         |    -22.0%    |    +0.0%     |    +0.3%     |

---

## Gas Usage (avg gas per function call)

### AdvancedFeatures

| Function | Transpiled (aggressive+yul-o2) | Native (Solc default_200) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| addAmounts | 254 | 817 | -68.9% |
| addressToBytes20 | 172 | 686 | -74.9% |
| andBytes4 | 206 | 678 | -69.6% |
| bytes20ToAddress | 199 | 854 | -76.7% |
| bytes4Selector | 165 | 788 | -79.1% |
| concatBytes | 434 | 775 | -44.0% |
| concatMultiple | 464 | 1470 | -68.4% |
| concatStrings | 590 | 895 | -34.1% |
| concatThreeStrings | 710 | 1616 | -56.1% |
| encodeApprove | 461 | 1284 | -64.1% |
| encodeBalanceOf | 403 | 810 | -50.2% |
| encodeTransfer | 466 | 1042 | -55.3% |
| encodeTransferManual | 461 | 756 | -39.0% |
| extractBytes4FromBytes32 | 238 | 930 | -74.4% |
| extractBytes8FromBytes32 | 215 | 644 | -66.6% |
| getAmount | 377 | 1133 | -66.7% |
| getByteAt | 249 | 262 | -5.0% |
| getTokenOwner | 340 | 742 | -54.2% |
| mintToken | 44507 | 44533 | -0.1% |
| notBytes4 | 172 | 1098 | -84.3% |
| orBytes4 | 206 | 392 | -47.4% |
| percentageToUint | 233 | 895 | -74.0% |
| setAmount | 22341 | 23064 | -3.1% |
| setBytes1 | 22298 | 23172 | -3.8% |
| setBytes16 | 22318 | 22393 | -0.3% |
| setBytes2 | 22315 | 22371 | -0.3% |
| setBytes20 | 22291 | 22639 | -1.5% |
| setBytes32 | 22233 | 22742 | -2.2% |
| setBytes4 | 22278 | 22508 | -1.0% |
| setBytes8 | 22312 | 22547 | -1.0% |
| storedBytes1 | 300 | 859 | -65.1% |
| storedBytes16 | 320 | 837 | -61.8% |
| storedBytes2 | 277 | 397 | -30.2% |
| storedBytes20 | 274 | 463 | -40.8% |
| storedBytes32 | 277 | 627 | -55.8% |
| storedBytes4 | 318 | 529 | -39.9% |
| storedBytes8 | 272 | 595 | -54.3% |
| xorBytes4 | 178 | 1008 | -82.3% |

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

### ControlFlow

| Function | Transpiled (aggressive+yul-o2) | Native (Solc default_200) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| breakLoop | 1306 | 1858 | -29.7% |
| continueLoop | 1503 | 1678 | -10.4% |
| earlyReturn | 181 | 354 | -48.9% |
| ifElse | 211 | 294 | -28.2% |
| loopCount | 8120 | 11415 | -28.9% |
| loopSum | 683 | 706 | -3.3% |
| nestedLoop | 1513 | 1778 | -14.9% |
| ternary | 229 | 347 | -34.0% |
| whileLoop | 3421 | 4872 | -29.8% |

### DataStructures

| Function | Transpiled (aggressive+yul-o2) | Native (Solc default_200) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| bytesConcat | 572 | 851 | -32.8% |
| bytesLength | 224 | 385 | -41.8% |
| createArray | 1585 | 2099 | -24.5% |
| createStruct | 304 | 510 | -40.4% |
| dynamicArraySum | 618 | 896 | -31.0% |
| fixedArraySum | 712 | 964 | -26.1% |
| processStruct | 236 | 235 | +0.4% |
| processStructArray | 1448 | 2463 | -41.2% |

### Edge

| Function | Transpiled (aggressive+yul-o2) | Native (Solc default_200) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| assertCondition | 203 | 565 | -64.1% |
| checkGas | 152 | 728 | -79.1% |
| fallback | 189 | 712 | -73.5% |
| getBlockInfo | 188 | 175 | +7.4% |
| getMsgInfo | 221 | 643 | -65.6% |
| mayFail | 302 | 799 | -62.2% |
| requireTrue | 273 | 598 | -54.3% |
| requireValue | 211 | 433 | -51.3% |
| tryCall | 766 | 1390 | -44.9% |

### Encoding

| Function | Transpiled (aggressive+yul-o2) | Native (Solc default_200) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| abiEncode | 371 | 603 | -38.5% |
| abiEncodePacked | 394 | 537 | -26.6% |
| abiEncodeWithSelector | 356 | 557 | -36.1% |
| decodePair | 228 | 393 | -42.0% |
| encodeMultiple | 655 | 1005 | -34.8% |
| encodePackedMixed | 433 | 696 | -37.8% |
| keccak256Encode | 300 | 483 | -37.9% |
| keccak256Hash | 462 | 747 | -38.2% |
| keccak256Packed | 300 | 417 | -28.1% |

### Events

| Function | Transpiled (aggressive+yul-o2) | Native (Solc default_200) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| emitBytes | 1852 | 2068 | -10.4% |
| emitComplex | 2920 | 3059 | -4.5% |
| emitIndexed | 1581 | 1676 | -5.7% |
| emitMultiIndexed | 2037 | 2094 | -2.7% |
| emitMultiple | 5583 | 5564 | +0.3% |
| emitSimple | 1168 | 1273 | -8.2% |
| emitString | 1822 | 1969 | -7.5% |

### ExternalLibrary

| Function | Transpiled (aggressive+yul-o2) | Native (Solc default_200) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| testAddInternal | 120 | N/A | N/A |

### Functions

| Function | Transpiled (aggressive+yul-o2) | Native (Solc default_200) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| callInternal | 207 | 528 | -60.8% |
| callSelf | 692 | 1171 | -40.9% |
| callVirtualA | 142 | 594 | -76.1% |
| callVirtualB | 142 | 142 | +0.0% |
| factorial | 281 | 487 | -42.3% |
| fibonacci | 275 | 394 | -30.2% |
| interfaceFunc | 147 | 506 | -70.9% |
| nestedInternal | 198 | 302 | -34.4% |
| returnMultiple | 178 | 736 | -75.8% |
| returnNothing | 142 | 350 | -59.4% |
| returnSingle | 142 | 462 | -69.3% |
| selfAdd | 184 | 286 | -35.7% |

### Libraries

| Function | Transpiled (aggressive+yul-o2) | Native (Solc default_200) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| decrementBy | 428 | 576 | -25.7% |
| directLibraryCall | 313 | 503 | -37.8% |
| getStoredValue | 253 | 318 | -20.4% |
| incrementBy | 494 | 502 | -1.6% |
| multiplyBy | 539 | 926 | -41.8% |
| processData | 3271 | 4128 | -20.8% |
| setStoredValue | 22227 | 22345 | -0.5% |
| testAdd | 336 | 591 | -43.1% |
| testAddressToBytes | 351 | 966 | -63.7% |
| testArrayContains | 972 | 1501 | -35.2% |
| testArrayMax | 1368 | 1819 | -24.8% |
| testArrayMin | 1414 | 2124 | -33.4% |
| testArraySum | 1230 | 1837 | -33.0% |
| testChainedMath | 474 | 759 | -37.5% |
| testComplexMath | 426 | 939 | -54.6% |
| testDiv | 255 | 429 | -40.6% |
| testIsContract | 268 | 382 | -29.8% |
| testMod | 223 | 270 | -17.4% |
| testMul | 350 | 717 | -51.2% |
| testStringEmpty | 377 | 785 | -52.0% |
| testStringEquals | 690 | 1592 | -56.7% |
| testStringLength | 426 | 1008 | -57.7% |
| testSub | 270 | 741 | -63.6% |

### Modifiers

| Function | Transpiled (aggressive+yul-o2) | Native (Solc default_200) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| addAdmin | 24527 | 24840 | -1.3% |
| adminAction | 26596 | 26813 | -0.8% |
| admins | 368 | 595 | -38.2% |
| blockedFunction | 225 | 460 | -51.1% |
| conditionalIncrement | 139 | 210 | -33.8% |
| counter | 254 | 575 | -55.8% |
| fullProtection | 2299 | 2283 | +0.7% |
| getCounter | 4460 | 4826 | -7.6% |
| getState | 4421 | 4558 | -3.0% |
| incrementWithAfterMod | 22303 | 22506 | -0.9% |
| incrementWithMiddleMod | 22265 | 22373 | -0.5% |
| loggedIncrement | 26051 | 26564 | -1.9% |
| multiEdgeCase | 22298 | 22514 | -1.0% |
| owner | 290 | 690 | -58.0% |
| ownerAction | 24469 | 24857 | -1.6% |
| paused | 299 | 548 | -45.4% |
| pureAdd | 201 | 697 | -71.2% |
| removeAdmin | 575 | 692 | -16.9% |
| restrictedAction | 26632 | 26902 | -1.0% |
| safeIncrement | 22281 | 22365 | -0.4% |
| setOwner | 5222 | 5284 | -1.2% |
| setPaused | 5249 | 5332 | -1.6% |
| wrappedIncrement | 22333 | 22823 | -2.1% |

### SoladyToken

| Function | Transpiled (aggressive+yul-o2) | Native (Solc default_200) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| allowance | 406 | 887 | -54.2% |
| approve | 24237 | 24234 | +0.0% |
| balanceOf | 316 | 580 | -45.5% |
| burn | 2431 | 2648 | -8.2% |
| burnFrom | 2814 | 3139 | -10.4% |
| decimals | 2265 | 2339 | -3.2% |
| mint | 46260 | 48595 | -4.8% |
| mintBatch | 95210 | 98182 | -3.0% |
| name | 2586 | 2702 | -4.3% |
| safeTransfer | 24470 | 24650 | -0.7% |
| safeTransferFrom | 24845 | 25098 | -1.0% |
| symbol | 2605 | 3020 | -13.7% |
| totalSupply | 259 | 289 | -10.4% |
| transfer | 24429 | 24804 | -1.5% |
| transferFrom | 24848 | 24966 | -0.5% |

### StateManagement

| Function | Transpiled (aggressive+yul-o2) | Native (Solc default_200) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| CONST_HASH | 154 | 986 | -84.4% |
| CONST_VALUE | 154 | 876 | -82.4% |
| balances | 2358 | 2533 | -6.9% |
| getArrayElement | 443 | 547 | -19.0% |
| getArrayLength | 2253 | 2245 | +0.4% |
| getMappingValue | 2321 | 2912 | -20.3% |
| getNestedMap | 428 | 1191 | -64.1% |
| getPackedAB | 292 | 547 | -46.6% |
| getStoredBool | 2266 | 2507 | -9.6% |
| getStoredUint | 2281 | 2802 | -18.6% |
| incrementBalance | 20315 | 20593 | -1.3% |
| memoryAlloc | 349 | 726 | -51.9% |
| memoryCopy | 1768 | 3154 | -43.9% |
| popArray | 538 | 1329 | -59.5% |
| pushArray | 42450 | 42720 | -0.6% |
| setMappingValue | 20235 | 21055 | -3.9% |
| setNestedMap | 22379 | 22721 | -1.5% |
| setPackedAB | 22333 | 22998 | -2.9% |
| setStoredBool | 20294 | 20315 | -0.1% |
| setStoredUint | 20132 | 20179 | -0.2% |

### TransientStorage

| Function | Transpiled (aggressive+yul-o2) | Native (Solc default_200) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| clearLock | 224 | 517 | -56.7% |
| getBoth | 393 | 567 | -30.7% |
| getCallbackSender | 268 | 303 | -11.6% |
| getTransientCounter | 259 | 605 | -57.2% |
| incrementTransientCounter | 374 | 497 | -24.7% |
| isLocked | 265 | 501 | -47.1% |
| protectedFunction | 375 | 497 | -24.5% |
| resetTransientCounter | 224 | 341 | -34.3% |
| setLock | 225 | 408 | -44.9% |
| storeRegular | 22255 | 22631 | -1.7% |
| storeTransient | 273 | 653 | -58.2% |
| tload | 262 | 477 | -45.1% |
| tloadAddress | 271 | 351 | -22.8% |
| tloadBytes32 | 303 | 565 | -46.4% |
| tloadMultiple | 1062 | 1701 | -37.6% |
| tstore | 266 | 273 | -2.6% |
| tstoreAddress | 254 | 531 | -52.2% |
| tstoreAndLoad | 312 | 858 | -63.6% |
| tstoreBytes32 | 254 | 679 | -62.6% |
| tstoreMultiple | 865 | 1395 | -38.0% |

### TypeLimits

| Function | Transpiled (aggressive+yul-o2) | Native (Solc default_200) | Delta |
|:---------|:----------:|:-------------:|:-----:|
| clampToInt128 | 220 | 486 | -54.7% |
| clampToUint8 | 210 | 438 | -52.1% |
| fitsInInt64 | 215 | 622 | -65.4% |
| fitsInUint128 | 192 | 754 | -74.5% |
| getConstants | 232 | 556 | -58.3% |
| getInterfaceId | 160 | 414 | -61.4% |
| int128Limits | 229 | 718 | -68.1% |
| int16Limits | 180 | 234 | -23.1% |
| int256Limits | 179 | 163 | +9.8% |
| int32Limits | 180 | 542 | -66.8% |
| int64Limits | 198 | 674 | -70.6% |
| int8Limits | 221 | 696 | -68.2% |
| isMaxUint256 | 186 | 732 | -74.6% |
| isMinInt256 | 174 | 446 | -61.0% |
| maxForBits | 283 | 461 | -38.6% |
| safeAdd | 291 | 736 | -60.5% |
| uint128Limits | 184 | 365 | -49.6% |
| uint16Limits | 171 | 475 | -64.0% |
| uint256Limits | 178 | 255 | -30.2% |
| uint32Limits | 176 | 211 | -16.6% |
| uint64Limits | 199 | 321 | -38.0% |
| uint8Limits | 171 | 299 | -42.8% |
| wouldOverflow | 212 | 535 | -60.4% |
| wouldUnderflow | 209 | 642 | -67.4% |


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