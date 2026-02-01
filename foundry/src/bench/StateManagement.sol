// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title State Management Benchmark
/// @notice Tests storage, memory, constants, immutables, and transient storage
contract StateManagement {
    // ========== Constants ==========
    uint256 public constant CONST_VALUE = 12345;
    bytes32 public constant CONST_HASH = keccak256("benchmark");
    string public constant CONST_STRING = "hello";

    // ========== Immutables ==========
    uint256 public immutable DEPLOY_TIME;
    address public immutable DEPLOYER;
    bytes32 public immutable DEPLOY_HASH;

    // ========== Storage: Simple Types ==========
    uint256 public storedUint;
    int256 public storedInt;
    bool public storedBool;
    address public storedAddress;
    bytes32 public storedBytes32;

    // ========== Storage: Packed Slots ==========
    uint128 public packedA;
    uint128 public packedB; // Should pack with packedA
    uint64 public packedC;
    uint64 public packedD;
    uint64 public packedE;
    uint64 public packedF; // Should pack with C, D, E

    // ========== Storage: Mappings ==========
    mapping(uint256 => uint256) public valueMap;
    mapping(address => uint256) public balances;
    mapping(uint256 => mapping(uint256 => uint256)) public nestedMap;

    // ========== Storage: Arrays ==========
    uint256[] public dynamicArray;
    uint256[10] public fixedArray;

    constructor() {
        DEPLOY_TIME = block.timestamp;
        DEPLOYER = msg.sender;
        DEPLOY_HASH = blockhash(block.number > 0 ? block.number - 1 : 0);
    }

    // ========== Simple Storage Read/Write ==========
    function getStoredUint() external view returns (uint256) {
        return storedUint;
    }

    function setStoredUint(uint256 val) external {
        storedUint = val;
    }

    function getStoredBool() external view returns (bool) {
        return storedBool;
    }

    function setStoredBool(bool val) external {
        storedBool = val;
    }

    // ========== Packed Storage ==========
    function setPackedAB(uint128 a, uint128 b) external {
        packedA = a;
        packedB = b;
    }

    function getPackedAB() external view returns (uint128, uint128) {
        return (packedA, packedB);
    }

    // ========== Mapping Operations ==========
    function getMappingValue(uint256 key) external view returns (uint256) {
        return valueMap[key];
    }

    function setMappingValue(uint256 key, uint256 val) external {
        valueMap[key] = val;
    }

    function incrementBalance(address addr, uint256 amount) external {
        balances[addr] += amount;
    }

    function setNestedMap(uint256 k1, uint256 k2, uint256 val) external {
        nestedMap[k1][k2] = val;
    }

    function getNestedMap(
        uint256 k1,
        uint256 k2
    ) external view returns (uint256) {
        return nestedMap[k1][k2];
    }

    // ========== Dynamic Array ==========
    function pushArray(uint256 val) external {
        dynamicArray.push(val);
    }

    function popArray() external {
        dynamicArray.pop();
    }

    function getArrayLength() external view returns (uint256) {
        return dynamicArray.length;
    }

    function getArrayElement(uint256 idx) external view returns (uint256) {
        return dynamicArray[idx];
    }

    // ========== Memory Operations ==========
    function memoryAlloc(uint256 size) external pure returns (uint256) {
        if (size > 1000) size = 1000;
        uint256[] memory arr = new uint256[](size);
        return arr.length;
    }

    function memoryCopy(uint256 size) external pure returns (uint256) {
        if (size > 100) size = 100;
        uint256[] memory src = new uint256[](size);
        for (uint256 i = 0; i < size; i++) {
            src[i] = i;
        }
        uint256[] memory dst = new uint256[](size);
        for (uint256 i = 0; i < size; i++) {
            dst[i] = src[i];
        }
        return dst[size > 0 ? size - 1 : 0];
    }

    // ========== Transient Storage ==========
    // NOTE: Transient storage functions moved to TransientStorage.sol

    // ========== Constant/Immutable Access ==========
    function getConstants()
        external
        view
        returns (uint256, bytes32, uint256, address)
    {
        return (CONST_VALUE, CONST_HASH, DEPLOY_TIME, DEPLOYER);
    }
}
