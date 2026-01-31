// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Encoding Benchmark
/// @notice Tests ABI encoding and hashing operations
contract Encoding {
    // ========== ABI Encode ==========
    function abiEncode(
        uint256 a,
        uint256 b
    ) external pure returns (bytes memory) {
        return abi.encode(a, b);
    }

    function abiEncodePacked(
        uint256 a,
        uint256 b
    ) external pure returns (bytes memory) {
        return abi.encodePacked(a, b);
    }

    function abiEncodeWithSelector(
        bytes4 selector,
        uint256 a
    ) external pure returns (bytes memory) {
        return abi.encodeWithSelector(selector, a);
    }

    // ========== Multiple Types ==========
    function encodeMultiple(
        uint256 a,
        address b,
        bytes32 c,
        string calldata d
    ) external pure returns (bytes memory) {
        return abi.encode(a, b, c, d);
    }

    function encodePackedMixed(
        uint8 a,
        uint16 b,
        uint256 c
    ) external pure returns (bytes memory) {
        return abi.encodePacked(a, b, c);
    }

    // ========== Hashing ==========
    function keccak256Hash(
        bytes calldata data
    ) external pure returns (bytes32) {
        return keccak256(data);
    }

    function keccak256Encode(
        uint256 a,
        uint256 b
    ) external pure returns (bytes32) {
        return keccak256(abi.encode(a, b));
    }

    function keccak256Packed(
        uint256 a,
        uint256 b
    ) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(a, b));
    }

    // ========== Decode (if encoded correctly) ==========
    function decodePair(
        bytes calldata data
    ) external pure returns (uint256, uint256) {
        return abi.decode(data, (uint256, uint256));
    }
}
