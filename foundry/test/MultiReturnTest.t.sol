// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

/**
 * @title MultiReturnTestRunner
 * @notice Isolated test for invoke multi-return fix in Yul2Venom transpiler.
 * @dev Verifies that functions returning multiple values work correctly.
 */
contract MultiReturnTestRunner is Test {
    address public deployed;

    function setUp() public {
        // Load transpiled runtime bytecode (must be runtime-only for vm.etch)
        bytes memory bytecode = vm.readFileBinary(
            "../output/MultiReturnTest_opt_runtime.bin"
        );
        require(bytecode.length > 0, "Bytecode is empty");

        // Deploy via vm.etch
        deployed = address(0x1234567890123456789012345678901234567890);
        vm.etch(deployed, bytecode);
    }

    /// @notice Test basic two-value return (a=43, b=101)
    function test_twoValues() public view {
        (bool success, bytes memory result) = deployed.staticcall(
            abi.encodeWithSignature("testTwoValues()")
        );
        assertTrue(success, "testTwoValues() failed");
        (uint256 a, uint256 b) = abi.decode(result, (uint256, uint256));
        assertEq(a, 43, "First return value should be 42+1=43");
        assertEq(b, 101, "Second return value should be 100+1=101");
    }

    /// @notice Test three-value return (a=10, b=20, c=30)
    function test_threeValues() public view {
        (bool success, bytes memory result) = deployed.staticcall(
            abi.encodeWithSignature("testThreeValues()")
        );
        assertTrue(success, "testThreeValues() failed");
        (uint256 a, uint256 b, uint256 c) = abi.decode(
            result,
            (uint256, uint256, uint256)
        );
        assertEq(a, 10, "First return value should be 1*10=10");
        assertEq(b, 20, "Second return value should be 2*10=20");
        assertEq(c, 30, "Third return value should be 3*10=30");
    }

    /// @notice Test recursive multi-return (fibonacci)
    function test_fibonacciRecursive() public view {
        // fibonacci(0) = (0, 1) -> returns 0
        (bool success, bytes memory result) = deployed.staticcall(
            abi.encodeWithSignature("testFibonacci(uint256)", 0)
        );
        assertTrue(success, "testFibonacci(0) failed");
        uint256 fib0 = abi.decode(result, (uint256));
        assertEq(fib0, 0, "fibonacci(0) should return 0");

        // fibonacci(5) = (5, 8) -> returns 5
        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("testFibonacci(uint256)", 5)
        );
        assertTrue(success, "testFibonacci(5) failed");
        uint256 fib5 = abi.decode(result, (uint256));
        assertEq(fib5, 5, "fibonacci(5) should return 5");

        // fibonacci(10) = (55, 89) -> returns 55
        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("testFibonacci(uint256)", 10)
        );
        assertTrue(success, "testFibonacci(10) failed");
        uint256 fib10 = abi.decode(result, (uint256));
        assertEq(fib10, 55, "fibonacci(10) should return 55");
    }

    /// @notice Test chained multi-returns
    function test_chainedMultiReturn() public view {
        // (42 + 100) + (1 + 2 + 3) = 142 + 6 = 148
        (bool success, bytes memory result) = deployed.staticcall(
            abi.encodeWithSignature("chainedMultiReturn()")
        );
        assertTrue(success, "chainedMultiReturn() failed");
        uint256 sum = abi.decode(result, (uint256));
        assertEq(sum, 148, "Chained multi-return sum should be 148");
    }

    /// @notice Test storing and retrieving multi-return values
    function test_storeAndRetrieve() public {
        // Store the values
        (bool success, ) = deployed.call(
            abi.encodeWithSignature("storeMultiReturn()")
        );
        assertTrue(success, "storeMultiReturn() failed");

        // Get the sum (1 + 2 + 3 = 6)
        bytes memory result;
        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("getStoredSum()")
        );
        assertTrue(success, "getStoredSum() failed");
        uint256 sum = abi.decode(result, (uint256));
        assertEq(sum, 6, "Stored sum should be 1+2+3=6");
    }
}
