# Yul2Venom: Missing Solidity Features

This document catalogs Solidity features that are **not yet covered** by our transpilation pipeline or test suite. Features are prioritized by importance for typical DeFi/smart contract use cases.

---

## ✅ Confirmed Working Features

These features are tested and pass in our benchmark suite:

| Category | Features |
|----------|----------|
| **Basic Types** | uint8-uint256, int8-int256, bool, address, bytes, string |
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

---

## ⚠️ Partially Supported / Needs More Testing

### 1. Init Code / Constructor Execution
**Status**: Not supported for transpiled bytecode  
**Current Workaround**: Use `--runtime-only` flag and `vm.etch()` with manual storage initialization  
**Impact**: High - cannot deploy transpiled contracts normally  
**Notes**: Constructor logic is compiled but init code that returns runtime code isn't generated

### 2. CREATE Opcode (Contract Deployment)
**Status**: CREATE2 works, regular CREATE needs testing  
**Files**: Edge.sol has create2, no CREATE test  
**Impact**: Medium - affects factory patterns

### 3. Transient Storage (EIP-1153)
**Status**: Unknown - needs testing with TLOAD/TSTORE  
**Impact**: Low - relatively new feature, not widely used yet

---

## ❌ Not Tested / Potentially Missing

### Priority 1: High Impact

#### Libraries with `using X for Y`
**Status**: Not tested  
**Example**:
```solidity
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
}
contract Example {
    using SafeMath for uint256;
    function test() external pure returns (uint256) {
        return uint256(1).add(2);
    }
}
```
**Impact**: Very common in DeFi contracts (OpenZeppelin, etc.)

#### External Library Calls (DELEGATECALL to libraries)
**Status**: Only internal library functions work; external library linking unknown  
**Impact**: Medium

---

### Priority 2: Medium Impact

#### `type(T).max` / `type(T).min`
**Status**: Not tested  
**Example**: `type(uint256).max`  
**Impact**: Common for overflow checks

#### Fixed-size Byte Arrays (bytes1 to bytes32)
**Status**: bytes32 works (constants), smaller sizes not explicitly tested  
**Impact**: Medium - used in hashing, signatures

#### `abi.encodeCall` (Type-safe encoding)
**Status**: Not tested  
**Example**: `abi.encodeCall(IERC20.transfer, (to, amount))`  
**Impact**: Low - newer syntax

#### Inline Assembly with Memory Allocation
**Status**: Basic assembly works, complex patterns not tested  
**Example**: `assembly { mstore(0x40, ...) }` FMP manipulation  
**Impact**: High for complex contracts

---

### Priority 3: Low Impact / Edge Cases

#### User-Defined Value Types
**Status**: Not tested  
**Example**: `type TokenId is uint256;`  
**Impact**: Low - newer feature

#### Salt-based CREATE2 with Different Bytecode
**Status**: Single test exists, variations not tested  
**Impact**: Low - niche use case

#### `block.basefee`, `block.prevrandao`
**Status**: Not tested  
**Example**: Post-merge block properties  
**Impact**: Low

#### String Concatenation
**Status**: Not tested  
**Example**: `string.concat("a", "b")`  
**Impact**: Low

#### Bytes Concatenation
**Status**: Not tested  
**Example**: `bytes.concat(bytes1(0x01), bytes2(0x0203))`  
**Impact**: Low

#### `unchecked` Blocks
**Status**: Yul optimizer may handle, not explicitly tested  
**Impact**: Medium - gas optimization

---

## 🔴 Known Not Supported

### 1. Full Contract Deployment (Init Code)
Runtime-only bytecode is generated. Full deployment flow with init code is not supported.

### 2. Multi-file Contracts with Separate Compilation
Each contract must be in a single file or properly imported. Complex multi-contract systems with separate compilation units may have issues.

---

## Test Coverage Matrix

| Feature | Contract | Test Count | Status |
|---------|----------|------------|--------|
| Arithmetic | Arithmetic.sol | ~15 | ✅ |
| Control Flow | ControlFlow.sol | ~12 | ✅ |
| Data Structures | DataStructures.sol | ~10 | ✅ |
| Edge Cases | Edge.sol | ~15 | ✅ |
| Encoding | Encoding.sol | ~8 | ✅ |
| Events | Events.sol | ~8 | ✅ |
| Functions | Functions.sol | ~20 | ✅ |
| **Modifiers** | Modifiers.sol | 38 | ✅ |
| State Management | StateManagement.sol | ~15 | ✅ |

**Total**: 223+ tests passing

---

## Recommendations for Future Work

1. **Priority 1**: Add library tests with `using X for Y` pattern
2. **Priority 2**: Add `type(T).max/min` tests
3. **Priority 3**: Test transient storage (TLOAD/TSTORE)
4. **Priority 4**: Test full deployment flow (init code generation)

---

*Last updated: 2026-02-01*
