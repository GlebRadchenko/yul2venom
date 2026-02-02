// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/bench/Events.sol";

/**
 * @title EventsTest
 * @dev Benchmark test for Events contract with bytecode injection support.
 *
 * Usage:
 *   # Test with default path
 *   forge test --match-contract EventsTest
 *
 *   # Test with custom bytecode
 *   BYTECODE_PATH="path/to/bytecode.bin" forge test --match-contract EventsTest
 *
 *   # Test with native Solc (no injection)
 *   BYTECODE_PATH="" forge test --match-contract EventsTest
 */
contract EventsTest is Test {
    Events target;
    address targetAddr;

    function setUp() public {
        string memory bytecodePath = vm.envOr(
            "BYTECODE_PATH",
            string("../output/Events_opt_runtime.bin")
        );

        if (bytes(bytecodePath).length > 0) {
            try vm.readFileBinary(bytecodePath) returns (bytes memory code) {
                targetAddr = address(0x6666);
                vm.etch(targetAddr, code);
                target = Events(targetAddr);
            } catch {
                target = new Events();
                targetAddr = address(target);
            }
        } else {
            target = new Events();
            targetAddr = address(target);
        }
    }

    // ========== Simple Events ==========
    function test_emitSimple() public {
        vm.expectEmit(true, true, true, true);
        emit Events.SimpleEvent(42);
        target.emitSimple(42);
    }

    function test_emitIndexed() public {
        vm.expectEmit(true, true, true, true);
        emit Events.IndexedEvent(1, 100);
        target.emitIndexed(1, 100);
    }

    function test_emitMultiIndexed() public {
        vm.expectEmit(true, true, true, true);
        emit Events.MultiIndexed(1, 2, 3);
        target.emitMultiIndexed(1, 2, 3);
    }

    // ========== String/Bytes Events ==========
    function test_emitString() public {
        vm.expectEmit(true, true, true, true);
        emit Events.StringEvent("hello");
        target.emitString("hello");
    }

    function test_emitBytes() public {
        vm.expectEmit(true, true, true, true);
        emit Events.BytesEvent(hex"deadbeef");
        target.emitBytes(hex"deadbeef");
    }

    // ========== Complex Events ==========
    function test_emitComplex() public {
        vm.expectEmit(true, true, false, true);
        emit Events.ComplexEvent(address(this), 123, 456, hex"cafe");
        target.emitComplex(123, 456, hex"cafe");
    }

    // ========== Multiple Events ==========
    function test_emitMultiple() public {
        // Just verify it doesn't revert
        target.emitMultiple(5);
    }
}
