// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Data Structures Benchmark
/// @notice Tests arrays, structs, and complex data handling
contract DataStructures {
    struct SimpleStruct {
        uint256 id;
        uint256 value;
    }

    struct NestedStruct {
        uint256 id;
        SimpleStruct inner;
    }

    // ========== Fixed Array ==========
    function fixedArraySum(
        uint256[5] calldata arr
    ) external pure returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < 5; i++) {
            sum += arr[i];
        }
        return sum;
    }

    // ========== Dynamic Array ==========
    function dynamicArraySum(
        uint256[] calldata arr
    ) external pure returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < arr.length; i++) {
            sum += arr[i];
        }
        return sum;
    }

    function createArray(
        uint256 size
    ) external pure returns (uint256[] memory) {
        if (size > 100) size = 100;
        uint256[] memory arr = new uint256[](size);
        for (uint256 i = 0; i < size; i++) {
            arr[i] = i * 2;
        }
        return arr;
    }

    // ========== Struct Operations ==========
    function processStruct(
        SimpleStruct calldata s
    ) external pure returns (uint256) {
        return s.id + s.value;
    }

    function createStruct(
        uint256 id,
        uint256 value
    ) external pure returns (SimpleStruct memory) {
        return SimpleStruct(id, value);
    }

    function processStructArray(
        SimpleStruct[] calldata arr
    ) external pure returns (SimpleStruct[] memory) {
        SimpleStruct[] memory result = new SimpleStruct[](arr.length);
        for (uint256 i = 0; i < arr.length; i++) {
            result[i] = SimpleStruct(arr[i].id * 2, arr[i].value * 2);
        }
        return result;
    }

    // ========== Nested Struct ==========
    function processNested(
        NestedStruct calldata n
    ) external pure returns (uint256) {
        return n.id + n.inner.id + n.inner.value;
    }

    // ========== Bytes ==========
    function bytesLength(bytes calldata data) external pure returns (uint256) {
        return data.length;
    }

    function bytesConcat(
        bytes calldata a,
        bytes calldata b
    ) external pure returns (bytes memory) {
        return bytes.concat(a, b);
    }
}
