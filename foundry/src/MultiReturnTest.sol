// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title MultiReturnTest
 * @notice Test contract to verify multi-return function handling in Yul2Venom transpiler.
 * @dev Tests the invoke instruction with multiple output variables.
 *
 * This contract specifically tests:
 * 1. Functions returning multiple values (tuple returns)
 * 2. Recursive functions (uses invoke, not inlining)
 * 3. Correct mapping of all return values
 */
contract MultiReturnTest {
    uint256 public storedA;
    uint256 public storedB;
    uint256 public storedC;

    // Simple multi-return function (will be inlined)
    function getTwo() internal pure returns (uint256, uint256) {
        return (42, 100);
    }

    // Another multi-return (will be inlined)
    function getThree() internal pure returns (uint256, uint256, uint256) {
        return (1, 2, 3);
    }

    // Recursive multi-return function (MUST use invoke, not inlining)
    function fibonacci(uint256 n) public pure returns (uint256 a, uint256 b) {
        if (n == 0) {
            return (0, 1);
        }
        (uint256 prevA, uint256 prevB) = fibonacci(n - 1);
        return (prevB, prevA + prevB);
    }

    // Test basic two-value return
    function testTwoValues() external pure returns (uint256, uint256) {
        (uint256 a, uint256 b) = getTwo();
        return (a + 1, b + 1);
    }

    // Test three-value return
    function testThreeValues()
        external
        pure
        returns (uint256, uint256, uint256)
    {
        (uint256 a, uint256 b, uint256 c) = getThree();
        return (a * 10, b * 10, c * 10);
    }

    // Test recursive multi-return (invokes fibonacci)
    function testFibonacci(uint256 n) external pure returns (uint256) {
        (uint256 a, ) = fibonacci(n);
        return a;
    }

    // Test storing multi-return values
    function storeMultiReturn() external {
        (storedA, storedB, storedC) = getThree();
    }

    // Verify stored values
    function getStoredSum() external view returns (uint256) {
        return storedA + storedB + storedC;
    }

    // Complex: chain multi-returns
    function chainedMultiReturn() external pure returns (uint256) {
        (uint256 a, uint256 b) = getTwo();
        (uint256 x, uint256 y, uint256 z) = getThree();
        return a + b + x + y + z;
    }
}
