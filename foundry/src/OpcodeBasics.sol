// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OpcodeBasics {
    function test_sub(uint256 a, uint256 b) external pure returns (uint256) {
        // Bound b <= a to avoid underflow (expected behavior for fuzz)
        if (b > a) return 0;
        return a - b;
    }

    function test_div(uint256 a, uint256 b) external pure returns (uint256) {
        // Guard against division by zero (expected behavior for fuzz)
        if (b == 0) return 0;
        return a / b;
    }

    function test_lt(uint256 a, uint256 b) external pure returns (uint256) {
        return a < b ? 1 : 0;
    }

    function test_gt(uint256 a, uint256 b) external pure returns (uint256) {
        return a > b ? 1 : 0;
    }

    function test_shl(
        uint256 shift,
        uint256 val
    ) external pure returns (uint256) {
        return val << shift;
    }

    function test_slt(uint256 a, uint256 b) external pure returns (uint256) {
        return int256(a) < int256(b) ? 1 : 0;
    }

    function test_lt_literal(uint256 b) external pure returns (uint256) {
        uint256 a = 10;
        return a < b ? 1 : 0;
    }

    function test_mul(uint256 a, uint256 b) external pure returns (uint256) {
        // Use unchecked to avoid overflow revert (test opcodes, not safety)
        unchecked {
            return a * b;
        }
    }

    function test_loop_lt(uint256 limit) external pure returns (uint256) {
        // Bound limit to avoid OOG (reasonable max iterations for testing)
        if (limit > 10000) limit = 10000;
        uint256 count = 0;
        for (uint256 i = 0; i < limit; i++) {
            count++;
        }
        return count;
    }
}
