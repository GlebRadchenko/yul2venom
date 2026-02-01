// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/bench/TransientStorage.sol";

/**
 * @title TransientStorageTest
 * @dev Tests EIP-1153 transient storage (TLOAD/TSTORE).
 *
 * Note: StateManagement.sol already has basic tload/tstore tests.
 * This contract focuses on additional patterns:
 *   - Reentrancy guard with transient storage
 *   - Multiple slot operations
 *   - Counter pattern
 *   - Address/bytes32 storage
 *   - Callback pattern
 */
contract TransientStorageTest is Test {
    TransientStorage target;
    address payable targetAddr;

    function setUp() public {
        string memory bytecodePath = vm.envOr(
            "BYTECODE_PATH",
            string("../output/TransientStorage_opt.bin")
        );

        if (bytes(bytecodePath).length > 0) {
            try vm.readFileBinary(bytecodePath) returns (bytes memory code) {
                targetAddr = payable(address(0x6666));
                vm.etch(targetAddr, code);
                target = TransientStorage(targetAddr);
            } catch {
                target = new TransientStorage();
                targetAddr = payable(address(target));
            }
        } else {
            target = new TransientStorage();
            targetAddr = payable(address(target));
        }
    }

    // ========== Basic Operations ==========

    function test_tstore_tload() public {
        target.tstore(0, 123);
        assertEq(target.tload(0), 123);
    }

    function test_tstore_differentSlots() public {
        target.tstore(1, 100);
        target.tstore(2, 200);
        target.tstore(3, 300);

        assertEq(target.tload(1), 100);
        assertEq(target.tload(2), 200);
        assertEq(target.tload(3), 300);
    }

    function test_tstoreAndLoad() public {
        uint256 loaded = target.tstoreAndLoad(5, 999);
        assertEq(loaded, 999);
    }

    // ========== Reentrancy Lock ==========

    function test_isLocked_initially() public view {
        assertFalse(target.isLocked());
    }

    function test_setLock() public {
        target.setLock();
        assertTrue(target.isLocked());
    }

    function test_clearLock() public {
        target.setLock();
        assertTrue(target.isLocked());
        target.clearLock();
        assertFalse(target.isLocked());
    }

    function test_protectedFunction() public {
        uint256 result = target.protectedFunction();
        assertEq(result, 42);
        // Lock should be cleared after function returns
        assertFalse(target.isLocked());
    }

    // ========== Multiple Slots ==========

    function test_tstoreMultiple() public {
        uint256[] memory slots = new uint256[](3);
        slots[0] = 10;
        slots[1] = 20;
        slots[2] = 30;

        uint256[] memory values = new uint256[](3);
        values[0] = 111;
        values[1] = 222;
        values[2] = 333;

        target.tstoreMultiple(slots, values);

        assertEq(target.tload(10), 111);
        assertEq(target.tload(20), 222);
        assertEq(target.tload(30), 333);
    }

    function test_tloadMultiple() public {
        target.tstore(100, 1000);
        target.tstore(200, 2000);

        uint256[] memory slots = new uint256[](2);
        slots[0] = 100;
        slots[1] = 200;

        uint256[] memory values = target.tloadMultiple(slots);

        assertEq(values.length, 2);
        assertEq(values[0], 1000);
        assertEq(values[1], 2000);
    }

    // ========== Transient vs Regular Storage ==========

    function test_transientVsRegular() public {
        target.storeRegular(100);
        target.storeTransient(200);

        (uint256 regular, uint256 transient_) = target.getBoth();

        assertEq(regular, 100);
        assertEq(transient_, 200);
    }

    // ========== Counter Pattern ==========

    function test_transientCounter_increment() public {
        assertEq(target.getTransientCounter(), 0);

        assertEq(target.incrementTransientCounter(), 1);
        assertEq(target.incrementTransientCounter(), 2);
        assertEq(target.incrementTransientCounter(), 3);

        assertEq(target.getTransientCounter(), 3);
    }

    function test_transientCounter_reset() public {
        target.incrementTransientCounter();
        target.incrementTransientCounter();
        assertEq(target.getTransientCounter(), 2);

        target.resetTransientCounter();
        assertEq(target.getTransientCounter(), 0);
    }

    // ========== Address Storage ==========

    function test_tstoreAddress() public {
        address testAddr = address(0xDEADBEEF);
        target.tstoreAddress(50, testAddr);
        assertEq(target.tloadAddress(50), testAddr);
    }

    // ========== Bytes32 Storage ==========

    function test_tstoreBytes32() public {
        bytes32 testData = keccak256("test");
        target.tstoreBytes32(60, testData);
        assertEq(target.tloadBytes32(60), testData);
    }

    // ========== Callback Pattern ==========

    function test_getCallbackSender_initial() public view {
        assertEq(target.getCallbackSender(), address(0));
    }
}
