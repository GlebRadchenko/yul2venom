// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title TypeLimits Benchmark
/// @notice Tests type(T).max, type(T).min, and related type introspection

contract TypeLimits {
    // ========== Unsigned Integer Limits ==========

    function uint8Limits() external pure returns (uint8 min, uint8 max) {
        return (type(uint8).min, type(uint8).max);
    }

    function uint16Limits() external pure returns (uint16 min, uint16 max) {
        return (type(uint16).min, type(uint16).max);
    }

    function uint32Limits() external pure returns (uint32 min, uint32 max) {
        return (type(uint32).min, type(uint32).max);
    }

    function uint64Limits() external pure returns (uint64 min, uint64 max) {
        return (type(uint64).min, type(uint64).max);
    }

    function uint128Limits() external pure returns (uint128 min, uint128 max) {
        return (type(uint128).min, type(uint128).max);
    }

    function uint256Limits() external pure returns (uint256 min, uint256 max) {
        return (type(uint256).min, type(uint256).max);
    }

    // ========== Signed Integer Limits ==========

    function int8Limits() external pure returns (int8 min, int8 max) {
        return (type(int8).min, type(int8).max);
    }

    function int16Limits() external pure returns (int16 min, int16 max) {
        return (type(int16).min, type(int16).max);
    }

    function int32Limits() external pure returns (int32 min, int32 max) {
        return (type(int32).min, type(int32).max);
    }

    function int64Limits() external pure returns (int64 min, int64 max) {
        return (type(int64).min, type(int64).max);
    }

    function int128Limits() external pure returns (int128 min, int128 max) {
        return (type(int128).min, type(int128).max);
    }

    function int256Limits() external pure returns (int256 min, int256 max) {
        return (type(int256).min, type(int256).max);
    }

    // ========== Practical Use Cases ==========

    /// @notice Check if a value would overflow on add
    function wouldOverflow(uint256 a, uint256 b) external pure returns (bool) {
        return a > type(uint256).max - b;
    }

    /// @notice Check if a value would underflow on sub
    function wouldUnderflow(uint256 a, uint256 b) external pure returns (bool) {
        return b > a;
    }

    /// @notice Safe add with explicit overflow check
    function safeAdd(uint256 a, uint256 b) external pure returns (uint256) {
        require(a <= type(uint256).max - b, "overflow");
        return a + b;
    }

    /// @notice Clamp value to uint8 range
    function clampToUint8(uint256 value) external pure returns (uint8) {
        if (value > type(uint8).max) {
            return type(uint8).max;
        }
        return uint8(value);
    }

    /// @notice Clamp value to int128 range
    function clampToInt128(int256 value) external pure returns (int128) {
        if (value > type(int128).max) {
            return type(int128).max;
        }
        if (value < type(int128).min) {
            return type(int128).min;
        }
        return int128(value);
    }

    /// @notice Check if value fits in uint128
    function fitsInUint128(uint256 value) external pure returns (bool) {
        return value <= type(uint128).max;
    }

    /// @notice Check if value fits in int64 (from int256)
    function fitsInInt64(int256 value) external pure returns (bool) {
        return value >= type(int64).min && value <= type(int64).max;
    }

    // ========== Interface Type Info ==========

    /// @notice Get interface ID (uses type() for interfaces)
    function getInterfaceId() external pure returns (bytes4) {
        return type(IERC165).interfaceId;
    }

    // ========== Constants Using Type Limits ==========

    uint256 public constant MAX_UINT = type(uint256).max;
    int256 public constant MIN_INT = type(int256).min;
    int256 public constant MAX_INT = type(int256).max;
    uint128 public constant MAX_UINT128 = type(uint128).max;

    function getConstants()
        external
        pure
        returns (
            uint256 maxUint,
            int256 minInt,
            int256 maxInt,
            uint128 maxUint128
        )
    {
        return (MAX_UINT, MIN_INT, MAX_INT, MAX_UINT128);
    }

    // ========== Comparison with Limits ==========

    function isMaxUint256(uint256 value) external pure returns (bool) {
        return value == type(uint256).max;
    }

    function isMinInt256(int256 value) external pure returns (bool) {
        return value == type(int256).min;
    }

    // ========== Bitwise Size Calculations ==========

    /// @notice Calculate max value for N bits (unsigned)
    function maxForBits(uint8 bits) external pure returns (uint256) {
        require(bits > 0 && bits <= 256, "Invalid bits");
        if (bits == 256) return type(uint256).max;
        return (1 << bits) - 1;
    }
}

// Minimal ERC165 interface for testing type().interfaceId
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
