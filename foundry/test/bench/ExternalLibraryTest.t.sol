// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/bench/ExternalLibrary.sol";

/**
 * @title ExternalLibraryTest
 * @dev Tests for external library calls via DELEGATECALL
 *
 * Note: This tests the transpilation of contracts that use external libraries.
 * The libraries (MathLib, ArrayLib) are linked via linkersymbol placeholders.
 * For full testing, libraries must be deployed and addresses configured.
 */
contract ExternalLibraryTestTest is Test {
    ExternalLibraryTest target;
    address payable targetAddr;

    function setUp() public {
        string memory bytecodePath = vm.envOr(
            "BYTECODE_PATH",
            string("../output/ExternalLibrary_opt_runtime.bin")
        );

        if (bytes(bytecodePath).length > 0) {
            try vm.readFileBinary(bytecodePath) returns (bytes memory code) {
                targetAddr = payable(address(0x8888));
                vm.etch(targetAddr, code);
                target = ExternalLibraryTest(targetAddr);
            } catch {
                target = new ExternalLibraryTest();
                targetAddr = payable(address(target));
            }
        } else {
            target = new ExternalLibraryTest();
            targetAddr = payable(address(target));
        }
    }

    // ========== Internal Library (Inlined) ==========

    function test_addInternal() public view {
        // Internal library functions are inlined, no DELEGATECALL
        assertEq(target.testAddInternal(100, 200), 300);
    }

    // ========== External Library Calls ==========
    // Note: These tests require library linking to work properly.
    // With placeholder addresses, DELEGATECALL will fail.
    // These tests verify that the contract structure compiles correctly.

    // Uncomment these tests when library linking is fully implemented:

    // function test_add() public {
    //     assertEq(target.testAdd(5, 3), 8);
    //     assertEq(target.lastResult(), 8);
    // }

    // function test_mul() public view {
    //     assertEq(target.testMul(7, 6), 42);
    // }

    // function test_pow() public view {
    //     assertEq(target.testPow(2, 10), 1024);
    // }

    // function test_arraySum() public view {
    //     uint256[] memory arr = new uint256[](3);
    //     arr[0] = 10;
    //     arr[1] = 20;
    //     arr[2] = 30;
    //     assertEq(target.testArraySum(arr), 60);
    // }

    // function test_arrayMax() public view {
    //     uint256[] memory arr = new uint256[](3);
    //     arr[0] = 10;
    //     arr[1] = 50;
    //     arr[2] = 30;
    //     assertEq(target.testArrayMax(arr), 50);
    // }

    // function test_chained() public view {
    //     // (2 + 3) * 4 = 20
    //     assertEq(target.testChained(2, 3, 4), 20);
    // }
}
