// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/bench/DataStructures.sol";

/**
 * @title DataStructuresTest
 * @dev Benchmark test for DataStructures contract with bytecode injection support.
 *
 * Usage:
 *   # Test with default path
 *   forge test --match-contract DataStructuresTest
 *
 *   # Test with custom bytecode
 *   BYTECODE_PATH="path/to/bytecode.bin" forge test --match-contract DataStructuresTest
 *
 *   # Test with native Solc (no injection)
 *   BYTECODE_PATH="" forge test --match-contract DataStructuresTest
 */
contract DataStructuresTest is Test {
    DataStructures target;
    address targetAddr;

    function setUp() public {
        string memory bytecodePath = vm.envOr(
            "BYTECODE_PATH",
            string("../output/DataStructures_opt_runtime.bin")
        );

        if (bytes(bytecodePath).length > 0) {
            try vm.readFileBinary(bytecodePath) returns (bytes memory code) {
                targetAddr = address(0x4444);
                vm.etch(targetAddr, code);
                target = DataStructures(targetAddr);
            } catch {
                target = new DataStructures();
                targetAddr = address(target);
            }
        } else {
            target = new DataStructures();
            targetAddr = address(target);
        }
    }

    // ========== Fixed Array ==========
    function test_fixedArraySum() public view {
        uint256[5] memory arr = [uint256(1), 2, 3, 4, 5];
        assertEq(target.fixedArraySum(arr), 15);
    }

    // ========== Dynamic Array ==========
    function test_dynamicArraySum() public view {
        uint256[] memory arr = new uint256[](3);
        arr[0] = 10;
        arr[1] = 20;
        arr[2] = 30;
        assertEq(target.dynamicArraySum(arr), 60);
    }

    function test_createArray() public view {
        uint256[] memory arr = target.createArray(5);
        assertEq(arr.length, 5);
        assertEq(arr[0], 0);
        assertEq(arr[4], 8);
    }

    // ========== Struct ==========
    function test_processStruct() public view {
        DataStructures.SimpleStruct memory s = DataStructures.SimpleStruct(
            10,
            20
        );
        assertEq(target.processStruct(s), 30);
    }

    function test_createStruct() public view {
        DataStructures.SimpleStruct memory s = target.createStruct(5, 15);
        assertEq(s.id, 5);
        assertEq(s.value, 15);
    }

    function test_processStructArray() public view {
        DataStructures.SimpleStruct[]
            memory arr = new DataStructures.SimpleStruct[](2);
        arr[0] = DataStructures.SimpleStruct(1, 2);
        arr[1] = DataStructures.SimpleStruct(3, 4);

        DataStructures.SimpleStruct[] memory result = target.processStructArray(
            arr
        );
        assertEq(result.length, 2);
        assertEq(result[0].id, 2);
        assertEq(result[0].value, 4);
        assertEq(result[1].id, 6);
        assertEq(result[1].value, 8);
    }

    // ========== Bytes ==========
    function test_bytesLength() public view {
        assertEq(target.bytesLength(hex"0102030405"), 5);
    }

    function test_bytesConcat() public view {
        bytes memory result = target.bytesConcat(hex"0102", hex"0304");
        assertEq(result.length, 4);
        assertEq(result, hex"01020304");
    }
}
