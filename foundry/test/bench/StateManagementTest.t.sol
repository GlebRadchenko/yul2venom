// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/bench/StateManagement.sol";

/**
 * @title StateManagementTest
 * @dev Benchmark test for StateManagement contract with bytecode injection support.
 *
 * Usage:
 *   # Test with default path
 *   forge test --match-contract StateManagementTest
 *
 *   # Test with custom bytecode
 *   BYTECODE_PATH="path/to/bytecode.bin" forge test --match-contract StateManagementTest
 *
 *   # Test with native Solc (no injection)
 *   BYTECODE_PATH="" forge test --match-contract StateManagementTest
 */
contract StateManagementTest is Test {
    StateManagement target;
    address targetAddr;

    function setUp() public {
        string memory bytecodePath = vm.envOr(
            "BYTECODE_PATH",
            string("../output/StateManagement_opt_runtime.bin")
        );

        if (bytes(bytecodePath).length > 0) {
            try vm.readFileBinary(bytecodePath) returns (bytes memory code) {
                targetAddr = address(0x3333);
                vm.etch(targetAddr, code);
                target = StateManagement(targetAddr);
            } catch {
                target = new StateManagement();
                targetAddr = address(target);
            }
        } else {
            target = new StateManagement();
            targetAddr = address(target);
        }
    }

    // ========== Constants ==========
    function test_constant() public view {
        assertEq(target.CONST_VALUE(), 12345);
    }

    function test_constantHash() public view {
        assertEq(target.CONST_HASH(), keccak256("benchmark"));
    }

    // ========== Simple Storage ==========
    function test_storedUint() public {
        assertEq(target.getStoredUint(), 0);
        target.setStoredUint(42);
        assertEq(target.getStoredUint(), 42);
    }

    function test_storedBool() public {
        assertFalse(target.getStoredBool());
        target.setStoredBool(true);
        assertTrue(target.getStoredBool());
    }

    // ========== Packed Storage ==========
    function test_packedAB() public {
        target.setPackedAB(100, 200);
        (uint128 a, uint128 b) = target.getPackedAB();
        assertEq(a, 100);
        assertEq(b, 200);
    }

    // ========== Mappings ==========
    function test_mappingReadWrite() public {
        assertEq(target.getMappingValue(1), 0);
        target.setMappingValue(1, 100);
        assertEq(target.getMappingValue(1), 100);
    }

    function test_incrementBalance() public {
        address user = address(0xBEEF);
        assertEq(target.balances(user), 0);
        target.incrementBalance(user, 50);
        assertEq(target.balances(user), 50);
    }

    function test_nestedMap() public {
        target.setNestedMap(1, 2, 999);
        assertEq(target.getNestedMap(1, 2), 999);
    }

    // ========== Dynamic Array ==========
    function test_dynamicArray() public {
        assertEq(target.getArrayLength(), 0);
        target.pushArray(10);
        target.pushArray(20);
        assertEq(target.getArrayLength(), 2);
        assertEq(target.getArrayElement(0), 10);
        assertEq(target.getArrayElement(1), 20);
        target.popArray();
        assertEq(target.getArrayLength(), 1);
    }

    // ========== Memory ==========
    function test_memoryAlloc() public view {
        assertEq(target.memoryAlloc(10), 10);
    }

    function test_memoryCopy() public view {
        assertEq(target.memoryCopy(5), 4);
    }

    // ========== Transient Storage ==========
    // NOTE: Transient storage tests moved to TransientStorageTest.t.sol
}
