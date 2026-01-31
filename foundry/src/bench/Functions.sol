// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Functions Benchmark
/// @notice Tests internal/external calls, returns, modifiers, delegatecall, staticcall

// ========== Inheritance Hierarchy (Diamond-like) ==========
interface IBase {
    function interfaceFunc() external pure returns (uint256);
}

abstract contract BaseA {
    function virtualA() public pure virtual returns (uint256) {
        return 100;
    }
}

abstract contract BaseB {
    function virtualB() public pure virtual returns (uint256) {
        return 200;
    }
}

contract Middle is BaseA, BaseB {
    function virtualA() public pure virtual override returns (uint256) {
        return super.virtualA() + 10; // 110
    }

    function virtualB() public pure virtual override returns (uint256) {
        return super.virtualB() + 20; // 220
    }
}

/// @notice Library for delegatecall testing
contract CallLibrary {
    uint256 public storedValue;

    function setAndDouble(uint256 val) external returns (uint256) {
        storedValue = val * 2;
        return storedValue;
    }

    function pureAdd(uint256 a, uint256 b) external pure returns (uint256) {
        return a + b;
    }
}

contract Functions is Middle, IBase {
    uint256 public storedValue;
    address public callTarget;

    // ========== Simple Returns ==========
    function returnSingle() external pure returns (uint256) {
        return 42;
    }

    function returnMultiple()
        external
        pure
        returns (uint256, uint256, uint256)
    {
        return (1, 2, 3);
    }

    function returnNothing() external pure {
        // void return
    }

    // ========== Interface Implementation ==========
    function interfaceFunc() external pure override returns (uint256) {
        return 999;
    }

    // ========== Diamond Inheritance ==========
    function virtualA() public pure override returns (uint256) {
        return super.virtualA() + 1; // 111
    }

    function virtualB() public pure override returns (uint256) {
        return super.virtualB() + 2; // 222
    }

    function callVirtualA() external pure returns (uint256) {
        return virtualA();
    }

    function callVirtualB() external pure returns (uint256) {
        return virtualB();
    }

    // ========== Internal Calls ==========
    function internalAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function callInternal(
        uint256 a,
        uint256 b
    ) external pure returns (uint256) {
        return internalAdd(a, b);
    }

    function nestedInternal(uint256 x) external pure returns (uint256) {
        return _level1(x);
    }

    function _level1(uint256 x) internal pure returns (uint256) {
        return _level2(x) + 1;
    }

    function _level2(uint256 x) internal pure returns (uint256) {
        return _level3(x) * 2;
    }

    function _level3(uint256 x) internal pure returns (uint256) {
        return x + 10;
    }

    // ========== Recursion ==========
    function factorial(uint256 n) external pure returns (uint256) {
        if (n > 12) n = 12; // Bound to prevent overflow
        return _factorial(n);
    }

    function _factorial(uint256 n) internal pure returns (uint256) {
        if (n <= 1) return 1;
        return n * _factorial(n - 1);
    }

    function fibonacci(uint256 n) external pure returns (uint256) {
        if (n > 20) n = 20; // Bound
        return _fib(n);
    }

    function _fib(uint256 n) internal pure returns (uint256) {
        if (n <= 1) return n;
        return _fib(n - 1) + _fib(n - 2);
    }

    // ========== External Self-Call ==========
    function selfAdd(uint256 a, uint256 b) external pure returns (uint256) {
        return a + b;
    }

    function callSelf(uint256 a, uint256 b) external view returns (uint256) {
        return this.selfAdd(a, b);
    }

    // ========== Low-Level Calls ==========
    function setCallTarget(address target) external {
        callTarget = target;
    }

    function lowLevelCall(
        bytes calldata data
    ) external returns (bool success, bytes memory result) {
        (success, result) = callTarget.call(data);
    }

    function lowLevelStaticCall(
        bytes calldata data
    ) external view returns (bool success, bytes memory result) {
        (success, result) = callTarget.staticcall(data);
    }

    function lowLevelDelegateCall(
        bytes calldata data
    ) external returns (bool success, bytes memory result) {
        (success, result) = callTarget.delegatecall(data);
    }

    // ========== Call With Value ==========
    function callWithValue(
        address target,
        uint256 amount
    ) external payable returns (bool) {
        (bool success, ) = target.call{value: amount}("");
        return success;
    }

    // ========== Staticcall Pure Function ==========
    function staticCallPure(
        address target,
        uint256 a,
        uint256 b
    ) external view returns (uint256) {
        (bool success, bytes memory result) = target.staticcall(
            abi.encodeWithSignature("pureAdd(uint256,uint256)", a, b)
        );
        require(success, "staticcall failed");
        return abi.decode(result, (uint256));
    }

    // ========== Delegatecall Modifies Storage ==========
    function delegateSetValue(
        address library_,
        uint256 val
    ) external returns (uint256) {
        (bool success, bytes memory result) = library_.delegatecall(
            abi.encodeWithSignature("setAndDouble(uint256)", val)
        );
        require(success, "delegatecall failed");
        return abi.decode(result, (uint256));
    }

    // ========== Proxy Pattern ==========
    address public implementation;

    function setImplementation(address impl) external {
        implementation = impl;
    }

    function proxyCall(bytes calldata data) external returns (bytes memory) {
        (bool success, bytes memory result) = implementation.delegatecall(data);
        require(success, "proxy failed");
        return result;
    }

    // ========== Receive/Fallback ==========
    receive() external payable {}

    fallback() external payable {
        // Forward to implementation if set
        if (implementation != address(0)) {
            (bool success, bytes memory result) = implementation.delegatecall(
                msg.data
            );
            require(success);
            assembly {
                return(add(result, 32), mload(result))
            }
        }
    }
}
