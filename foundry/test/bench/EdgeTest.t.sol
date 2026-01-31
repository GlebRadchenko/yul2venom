// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/bench/Edge.sol";

/**
 * @title EdgeTest
 * @dev Benchmark test for Edge contract with bytecode injection support.
 *
 * Usage:
 *   # Test with default path
 *   forge test --match-contract EdgeTest
 *
 *   # Test with custom bytecode
 *   BYTECODE_PATH="path/to/bytecode.bin" forge test --match-contract EdgeTest
 *
 *   # Test with native Solc (no injection)
 *   BYTECODE_PATH="" forge test --match-contract EdgeTest
 */
contract EdgeTest is Test {
    Edge target;
    address payable targetAddr;

    function setUp() public {
        string memory bytecodePath = vm.envOr(
            "BYTECODE_PATH",
            string("output/bench/Edge_opt.bin")
        );

        if (bytes(bytecodePath).length > 0) {
            try vm.readFileBinary(bytecodePath) returns (bytes memory code) {
                targetAddr = payable(address(0x8888));
                vm.etch(targetAddr, code);
                target = Edge(targetAddr);
            } catch {
                target = new Edge();
                targetAddr = payable(address(target));
            }
        } else {
            target = new Edge();
            targetAddr = payable(address(target));
        }
    }

    // ========== Receive ==========
    function test_receive() public {
        (bool success, ) = targetAddr.call{value: 1 ether}("");
        assertTrue(success);
    }

    // ========== Fallback ==========
    function test_fallback() public {
        (bool success, ) = targetAddr.call(hex"deadbeef");
        assertTrue(success);
    }

    // ========== Require ==========
    function test_requireTrue() public view {
        assertTrue(target.requireTrue(true));
    }

    function test_requireFalse() public {
        vm.expectRevert("condition failed");
        target.requireTrue(false);
    }

    function test_requireValue() public view {
        assertEq(target.requireValue(42), 42);
    }

    function test_requireValueZero() public {
        vm.expectRevert("must be positive");
        target.requireValue(0);
    }

    // ========== Assert ==========
    function test_assertCondition() public view {
        assertTrue(target.assertCondition(true));
    }

    // ========== Try-Catch ==========
    function test_tryCall_success() public view {
        (bool success, uint256 result) = target.tryCall(50);
        assertTrue(success);
        assertEq(result, 100);
    }

    function test_tryCall_failure() public view {
        (bool success, uint256 result) = target.tryCall(150);
        assertFalse(success);
        assertEq(result, 0);
    }

    // ========== Gas Check ==========
    function test_checkGas() public view {
        uint256 gas = target.checkGas();
        assertTrue(gas > 0);
    }

    // ========== Block Info ==========
    function test_getBlockInfo() public view {
        (uint256 blockNum, uint256 timestamp, address coinbase) = target
            .getBlockInfo();
        assertEq(blockNum, block.number);
        assertEq(timestamp, block.timestamp);
        assertEq(coinbase, block.coinbase);
    }

    // ========== Msg Info ==========
    function test_getMsgInfo() public {
        (address sender, uint256 value, bytes4 sig) = target.getMsgInfo{
            value: 0
        }();
        assertEq(sender, address(this));
        assertEq(value, 0);
    }
}
