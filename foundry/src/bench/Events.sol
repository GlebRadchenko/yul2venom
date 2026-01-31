// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Events Benchmark
/// @notice Tests event emission with various data types
contract Events {
    event SimpleEvent(uint256 value);
    event IndexedEvent(uint256 indexed id, uint256 value);
    event MultiIndexed(uint256 indexed a, uint256 indexed b, uint256 indexed c);
    event StringEvent(string message);
    event BytesEvent(bytes data);
    event ComplexEvent(
        address indexed sender,
        uint256 indexed id,
        uint256 value,
        bytes data
    );

    // ========== Simple Events ==========
    function emitSimple(uint256 value) external {
        emit SimpleEvent(value);
    }

    function emitIndexed(uint256 id, uint256 value) external {
        emit IndexedEvent(id, value);
    }

    function emitMultiIndexed(uint256 a, uint256 b, uint256 c) external {
        emit MultiIndexed(a, b, c);
    }

    // ========== String/Bytes Events ==========
    function emitString(string calldata message) external {
        emit StringEvent(message);
    }

    function emitBytes(bytes calldata data) external {
        emit BytesEvent(data);
    }

    // ========== Complex Events ==========
    function emitComplex(
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external {
        emit ComplexEvent(msg.sender, id, value, data);
    }

    // ========== Multiple Events ==========
    function emitMultiple(uint256 count) external {
        if (count > 100) count = 100;
        for (uint256 i = 0; i < count; i++) {
            emit SimpleEvent(i);
        }
    }
}
