# Yul2Venom: Solidity Feature Coverage

This document catalogs Solidity feature coverage in our transpilation pipeline and test suite.

---

## ✅ Confirmed Working Features

These features are tested and pass in our benchmark suite (228 tests):

| Category | Features |
|----------|----------|
| **Basic Types** | uint8-uint256, int8-int256, bool, address, bytes, string |
| **Type Introspection** | `type(T).max`, `type(T).min`, `type(I).interfaceId` |
| **State** | storage variables, mappings (simple/nested), constants, immutables |
| **Structs/Enums** | struct definitions, nested structs, enum types |
| **Functions** | internal, external, public, private, view, pure, payable |
| **Modifiers** | basic, with arguments, nested (_ before/after/middle), multiple stacked, conditional |
| **Inheritance** | single, multiple, diamond, abstract, interface, virtual/override |
| **Control Flow** | if/else, for/while loops, continue, break, early return |
| **Error Handling** | require, assert, revert, custom errors, try/catch |
| **Events** | simple, indexed (1-3 topics), with various data types |
| **Low-level** | call, staticcall, delegatecall, assembly blocks |
| **Special** | receive, fallback, create2 |
| **ABI** | encode, encodePacked, encodeWithSignature, decode |
| **Libraries** | `using X for Y`, internal library functions, direct calls |
| **Transient Storage** | TLOAD/TSTORE, reentrancy guards, counters, address/bytes32 storage |
| **ERC Standards** | ERC20 (via Solady), minting, burning, transfers, approvals |

---

## ⚠️ Partially Supported / Known Limitations

### 1. Init Code / Constructor Execution
**Status**: Not supported for transpiled bytecode  
**Workaround**: Use `--runtime-only` flag and `vm.etch()` with manual storage initialization  
**Impact**: High - cannot deploy transpiled contracts via normal flow  
**Notes**: Constructor logic compiles, but init code returning runtime code isn't generated

### 2. CREATE Opcode (Contract Deployment)
**Status**: CREATE2 works, regular CREATE needs testing  
**Files**: Edge.sol has create2 test  
**Impact**: Medium - affects factory patterns

### 3. Complex Storage Initialization with vm.etch
**Status**: Dynamic strings and complex types difficult to initialize manually  
**Workaround**: Use native Solc for contracts requiring complex constructor state  
**Impact**: Low - only affects testing with injected bytecode

---

## ❌ Not Tested / Potentially Missing

### Priority 1: High Impact

#### External Library Calls (DELEGATECALL to deployed libraries)
**Status**: Internal library functions work; external linked libraries unknown  
**Impact**: Medium - affects large codebases using deployed library contracts

#### `abi.encodeCall` (Type-safe encoding)
**Status**: Not tested  
**Example**: `abi.encodeCall(IERC20.transfer, (to, amount))`  
**Impact**: Low - newer syntax, abi.encode alternatives work

---

### Priority 2: Medium Impact

#### Fixed-size Byte Arrays (bytes1 to bytes31)
**Status**: bytes32 works, smaller sizes not explicitly tested  
**Impact**: Medium - used in hashing, signatures

#### Inline Assembly with Complex Memory Manipulation
**Status**: Basic assembly works, FMP manipulation not tested  
**Example**: `assembly { mstore(0x40, ...) }`  
**Impact**: Medium for complex contracts

#### `unchecked` Blocks
**Status**: Yul optimizer handles, not explicitly tested  
**Impact**: Medium - gas optimization

---

### Priority 3: Low Impact / Edge Cases

#### User-Defined Value Types
**Status**: Not tested  
**Example**: `type TokenId is uint256;`  
**Impact**: Low - newer feature

#### `block.basefee`, `block.prevrandao`
**Status**: Not tested  
**Example**: Post-merge block properties  
**Impact**: Low

#### String/Bytes Concatenation
**Status**: Not tested  
**Examples**: `string.concat("a", "b")`, `bytes.concat(...)`  
**Impact**: Low

#### Salt-based CREATE2 Variations
**Status**: Single test exists, variations not tested  
**Impact**: Low - niche use case

---

## 🔴 Known Not Supported

### 1. Full Contract Deployment (Init Code)
Runtime-only bytecode is generated. Full deployment flow with init code is not supported. Use `--runtime-only` flag.

### 2. Multi-file Contracts with Separate Compilation Units
Complex multi-contract systems with separate compilation may have issues. All imports must be resolvable.

---

## Test Coverage Matrix

| Feature | Contract | Tests | Status |
|---------|----------|-------|--------|
| Arithmetic | Arithmetic.sol | 15 | ✅ |
| Control Flow | ControlFlow.sol | 12 | ✅ |
| Data Structures | DataStructures.sol | 10 | ✅ |
| Edge Cases | Edge.sol | 15 | ✅ |
| Encoding | Encoding.sol | 8 | ✅ |
| Events | Events.sol | 8 | ✅ |
| Functions | Functions.sol | 20 | ✅ |
| **Libraries** | Libraries.sol | 29 | ✅ |
| **Modifiers** | Modifiers.sol | 38 | ✅ |
| **ERC20 (Solady)** | SoladyToken.sol | 17 | ✅ |
| State Management | StateManagement.sol | 12 | ✅ |
| **Transient Storage** | TransientStorage.sol | 15 | ✅ |
| **Type Limits** | TypeLimits.sol | 26 | ✅ |

**Total**: 228 tests passing across 13 benchmark contracts

---

## Recommendations for Future Work

1. **Priority 1**: Test external library linking (DELEGATECALL to deployed libraries)
2. **Priority 2**: Add `unchecked` block explicit tests
3. **Priority 3**: Test `bytes1`-`bytes31` fixed-size arrays
4. **Priority 4**: Test `block.prevrandao`, `block.basefee`
5. **Priority 5**: Investigate init code generation for full deployment support

---

*Last updated: 2026-02-01*
