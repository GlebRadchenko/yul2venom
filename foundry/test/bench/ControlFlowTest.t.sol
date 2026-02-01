// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/bench/ControlFlow.sol";

/**
 * @title ControlFlowTest
 * @dev Benchmark test for ControlFlow contract with bytecode injection support.
 *
 * Usage:
 *   # Test with default path
 *   forge test --match-contract ControlFlowTest
 *
 *   # Test with custom bytecode
 *   BYTECODE_PATH="path/to/bytecode.bin" forge test --match-contract ControlFlowTest
 *
 *   # Test with native Solc (no injection)
 *   BYTECODE_PATH="" forge test --match-contract ControlFlowTest
 */
contract ControlFlowTest is Test {
    ControlFlow target;
    address targetAddr;

    function setUp() public {
        string memory bytecodePath = vm.envOr(
            "BYTECODE_PATH",
            string("../output/bench/ControlFlow_opt.bin")
        );

        if (bytes(bytecodePath).length > 0) {
            try vm.readFileBinary(bytecodePath) returns (bytes memory code) {
                targetAddr = address(0x2222);
                vm.etch(targetAddr, code);
                target = ControlFlow(targetAddr);
            } catch {
                target = new ControlFlow();
                targetAddr = address(target);
            }
        } else {
            target = new ControlFlow();
            targetAddr = address(target);
        }
    }

    // ========== Simple Loops ==========
    function test_loopSum() public view {
        assertEq(target.loopSum(5), 0 + 1 + 2 + 3 + 4); // 10
    }

    function test_loopSum_zero() public view {
        assertEq(target.loopSum(0), 0);
    }

    function test_loopCount() public view {
        assertEq(target.loopCount(100), 100);
    }

    function test_whileLoop() public view {
        assertEq(target.whileLoop(50), 50);
    }

    // ========== Nested Loops ==========
    function test_nestedLoop() public view {
        assertEq(target.nestedLoop(3, 4), 12);
    }

    // ========== Conditionals ==========
    function test_ternary() public view {
        assertEq(target.ternary(10, 5), 10);
        assertEq(target.ternary(5, 10), 10);
    }

    function test_ifElse() public view {
        assertEq(target.ifElse(5), 1);
        assertEq(target.ifElse(50), 2);
        assertEq(target.ifElse(500), 3);
    }

    function test_earlyReturn() public view {
        assertEq(target.earlyReturn(0), 0);
        assertEq(target.earlyReturn(1), 1);
        assertEq(target.earlyReturn(5), 10);
    }

    // ========== Break/Continue ==========
    function test_breakLoop() public view {
        assertEq(target.breakLoop(100, 10), 10);
    }

    function test_continueLoop() public view {
        // Skip every 3rd: 0,3,6,9 skipped out of 0-9 = 10 - 4 = 6
        assertEq(target.continueLoop(10, 3), 6);
    }
}
