// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title External Library Test
/// @notice Tests external library linking via DELEGATECALL

/// @dev Library deployed as a separate contract
library MathLib {
    /// @notice Add two numbers - will be called via DELEGATECALL
    function add(uint256 a, uint256 b) external pure returns (uint256) {
        return a + b;
    }

    /// @notice Multiply two numbers
    function mul(uint256 a, uint256 b) external pure returns (uint256) {
        return a * b;
    }

    /// @notice Calculate power
    function pow(uint256 base, uint256 exp) external pure returns (uint256) {
        uint256 result = 1;
        for (uint256 i = 0; i < exp; i++) {
            result *= base;
        }
        return result;
    }

    /// @notice Internal function (inlined, not DELEGATECALL)
    function addInternal(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
}

/// @dev Library for array operations
library ArrayLib {
    /// @notice Sum array elements
    function sum(uint256[] memory arr) external pure returns (uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < arr.length; i++) {
            total += arr[i];
        }
        return total;
    }

    /// @notice Find max element
    function max(uint256[] memory arr) external pure returns (uint256) {
        require(arr.length > 0, "Empty array");
        uint256 maxVal = arr[0];
        for (uint256 i = 1; i < arr.length; i++) {
            if (arr[i] > maxVal) {
                maxVal = arr[i];
            }
        }
        return maxVal;
    }
}

/// @title ExternalLibraryTest
/// @notice Contract that uses external library functions
contract ExternalLibraryTest {
    using MathLib for uint256;

    // Storage to test library calls with state
    uint256 public lastResult;

    /// @notice Use external library function (DELEGATECALL)
    function testAdd(uint256 a, uint256 b) external returns (uint256) {
        lastResult = MathLib.add(a, b);
        return lastResult;
    }

    /// @notice Use direct library call
    function testMul(uint256 a, uint256 b) external pure returns (uint256) {
        return MathLib.mul(a, b);
    }

    /// @notice Use library with loop
    function testPow(
        uint256 base,
        uint256 exp
    ) external pure returns (uint256) {
        return MathLib.pow(base, exp);
    }

    /// @notice Use internal library function (should be inlined)
    function testAddInternal(
        uint256 a,
        uint256 b
    ) external pure returns (uint256) {
        return MathLib.addInternal(a, b);
    }

    /// @notice Test array library
    function testArraySum(
        uint256[] calldata arr
    ) external pure returns (uint256) {
        uint256[] memory arrMem = arr;
        return ArrayLib.sum(arrMem);
    }

    /// @notice Test array max
    function testArrayMax(
        uint256[] calldata arr
    ) external pure returns (uint256) {
        uint256[] memory arrMem = arr;
        return ArrayLib.max(arrMem);
    }

    /// @notice Chain multiple library calls
    function testChained(
        uint256 a,
        uint256 b,
        uint256 c
    ) external pure returns (uint256) {
        uint256 sum = MathLib.add(a, b);
        return MathLib.mul(sum, c);
    }
}
