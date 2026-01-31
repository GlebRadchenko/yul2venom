// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Arithmetic Benchmark
/// @notice Tests basic arithmetic with both safe (checked) and unsafe (unchecked) versions
contract Arithmetic {
    // ========== SAFE (Checked) Operations ==========
    // These will revert on overflow/underflow

    function safeAdd(uint256 a, uint256 b) external pure returns (uint256) {
        return a + b;
    }

    function safeSub(uint256 a, uint256 b) external pure returns (uint256) {
        return a - b;
    }

    function safeMul(uint256 a, uint256 b) external pure returns (uint256) {
        return a * b;
    }

    function safeDiv(uint256 a, uint256 b) external pure returns (uint256) {
        return a / b;
    }

    function safeMod(uint256 a, uint256 b) external pure returns (uint256) {
        return a % b;
    }

    // ========== UNSAFE (Unchecked) Operations ==========
    // These wrap around on overflow/underflow - lower gas cost

    function unsafeAdd(uint256 a, uint256 b) external pure returns (uint256) {
        unchecked {
            return a + b;
        }
    }

    function unsafeSub(uint256 a, uint256 b) external pure returns (uint256) {
        unchecked {
            return a - b;
        }
    }

    function unsafeMul(uint256 a, uint256 b) external pure returns (uint256) {
        unchecked {
            return a * b;
        }
    }

    function unsafeDiv(uint256 a, uint256 b) external pure returns (uint256) {
        unchecked {
            return a / b;
        }
    }

    function unsafeMod(uint256 a, uint256 b) external pure returns (uint256) {
        unchecked {
            return a % b;
        }
    }

    // ========== Shifts (always unchecked) ==========
    function shl(uint256 shift, uint256 val) external pure returns (uint256) {
        return val << shift;
    }

    function shr(uint256 shift, uint256 val) external pure returns (uint256) {
        return val >> shift;
    }

    function sar(int256 val, uint256 shift) external pure returns (int256) {
        return val >> shift; // Arithmetic right shift for signed
    }

    // ========== Comparisons ==========
    function lt(uint256 a, uint256 b) external pure returns (bool) {
        return a < b;
    }

    function gt(uint256 a, uint256 b) external pure returns (bool) {
        return a > b;
    }

    function eq(uint256 a, uint256 b) external pure returns (bool) {
        return a == b;
    }

    function lte(uint256 a, uint256 b) external pure returns (bool) {
        return a <= b;
    }

    function gte(uint256 a, uint256 b) external pure returns (bool) {
        return a >= b;
    }

    function slt(int256 a, int256 b) external pure returns (bool) {
        return a < b;
    }

    function sgt(int256 a, int256 b) external pure returns (bool) {
        return a > b;
    }

    function iszero(uint256 a) external pure returns (bool) {
        return a == 0;
    }

    // ========== Bitwise ==========
    function and_(uint256 a, uint256 b) external pure returns (uint256) {
        return a & b;
    }

    function or_(uint256 a, uint256 b) external pure returns (uint256) {
        return a | b;
    }

    function xor_(uint256 a, uint256 b) external pure returns (uint256) {
        return a ^ b;
    }

    function not_(uint256 a) external pure returns (uint256) {
        return ~a;
    }

    // ========== Exponentiation ==========
    function safeExp(
        uint256 base,
        uint256 exp
    ) external pure returns (uint256) {
        return base ** exp;
    }

    function unsafeExp(
        uint256 base,
        uint256 exp
    ) external pure returns (uint256) {
        unchecked {
            return base ** exp;
        }
    }

    // ========== Sign Extension ==========
    function signExtend8(uint256 x) external pure returns (int256) {
        return int256(int8(uint8(x)));
    }

    function signExtend16(uint256 x) external pure returns (int256) {
        return int256(int16(uint16(x)));
    }
}
