// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Test: Multiple different types of immutables
/// @dev Stress test with many immutables of different types

contract InitMultiImmutableTest {
    // Different types of immutables
    address public immutable addr1;
    address public immutable addr2;
    address public immutable addr3;
    uint256 public immutable uint1;
    uint256 public immutable uint2;
    uint128 public immutable uint128val;
    bool public immutable flag1;
    bool public immutable flag2;
    bytes32 public immutable hash;

    // Storage variables
    uint256 public counter;

    constructor(
        address _addr1,
        address _addr2,
        address _addr3,
        uint256 _uint1,
        uint256 _uint2,
        uint128 _uint128val,
        bool _flag1,
        bool _flag2,
        bytes32 _hash
    ) {
        addr1 = _addr1;
        addr2 = _addr2;
        addr3 = _addr3;
        uint1 = _uint1;
        uint2 = _uint2;
        uint128val = _uint128val;
        flag1 = _flag1;
        flag2 = _flag2;
        hash = _hash;
        counter = 1;
    }

    function getAddr1() external view returns (address) {
        return addr1;
    }

    function getAddr2() external view returns (address) {
        return addr2;
    }

    function getAddr3() external view returns (address) {
        return addr3;
    }

    function getUint1() external view returns (uint256) {
        return uint1;
    }

    function getUint2() external view returns (uint256) {
        return uint2;
    }

    function getUint128() external view returns (uint128) {
        return uint128val;
    }

    function getFlags() external view returns (bool, bool) {
        return (flag1, flag2);
    }

    function getHash() external view returns (bytes32) {
        return hash;
    }

    function getCounter() external view returns (uint256) {
        return counter;
    }
}
