// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Control Flow Benchmark
/// @notice Tests loops, conditionals, and control flow constructs
contract ControlFlow {
    // ========== Simple Loops ==========
    function loopSum(uint256 n) external pure returns (uint256) {
        if (n > 10000) n = 10000; // Bound for fuzz
        uint256 sum = 0;
        for (uint256 i = 0; i < n; i++) {
            sum += i;
        }
        return sum;
    }

    function loopCount(uint256 n) external pure returns (uint256) {
        if (n > 10000) n = 10000;
        uint256 count = 0;
        for (uint256 i = 0; i < n; i++) {
            count++;
        }
        return count;
    }

    function whileLoop(uint256 n) external pure returns (uint256) {
        if (n > 10000) n = 10000;
        uint256 i = 0;
        while (i < n) {
            i++;
        }
        return i;
    }

    // ========== Nested Loops ==========
    function nestedLoop(
        uint256 outer,
        uint256 inner
    ) external pure returns (uint256) {
        if (outer > 100) outer = 100;
        if (inner > 100) inner = 100;
        uint256 count = 0;
        for (uint256 i = 0; i < outer; i++) {
            for (uint256 j = 0; j < inner; j++) {
                count++;
            }
        }
        return count;
    }

    // ========== Conditionals ==========
    function ternary(uint256 a, uint256 b) external pure returns (uint256) {
        return a > b ? a : b;
    }

    function ifElse(uint256 x) external pure returns (uint256) {
        if (x < 10) {
            return 1;
        } else if (x < 100) {
            return 2;
        } else {
            return 3;
        }
    }

    // ========== Early Return ==========
    function earlyReturn(uint256 x) external pure returns (uint256) {
        if (x == 0) return 0;
        if (x == 1) return 1;
        return x * 2;
    }

    // ========== Break/Continue ==========
    function breakLoop(
        uint256 n,
        uint256 breakAt
    ) external pure returns (uint256) {
        if (n > 1000) n = 1000;
        uint256 count = 0;
        for (uint256 i = 0; i < n; i++) {
            if (i == breakAt) break;
            count++;
        }
        return count;
    }

    function continueLoop(
        uint256 n,
        uint256 skipEvery
    ) external pure returns (uint256) {
        if (n > 1000) n = 1000;
        if (skipEvery == 0) skipEvery = 1;
        uint256 count = 0;
        for (uint256 i = 0; i < n; i++) {
            if (i % skipEvery == 0) continue;
            count++;
        }
        return count;
    }
}
