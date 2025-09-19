// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract HeavyMath {
    uint256 private constant MOD = 1_000_000_007;

    function sumOfSquares(uint256 n) public pure returns (uint256 acc) {
        for (uint256 i = 1; i <= n; i++) {
            acc += i * i;
        }
    }

    function factorialMod(uint256 n) public pure returns (uint256 acc) {
        if (n == 0) {
            return 1;
        }
        acc = 1;
        for (uint256 i = 2; i <= n; i++) {
            acc = (acc * i) % MOD;
        }
    }

    function fibonacci(uint256 n) public pure returns (uint256) {
        if (n == 0) {
            return 0;
        }
        if (n == 1) {
            return 1;
        }
        uint256 prev = 0;
        uint256 curr = 1;
        for (uint256 i = 2; i <= n; i++) {
            (prev, curr) = (curr, prev + curr);
        }
        return curr;
    }

    function polynomialReduce(uint256 x) public pure returns (uint256) {
        // Evaluate large-degree polynomial using Horner's method with alternating coefficients.
        uint256 result = 0;
        for (uint256 i = 0; i < 64; i++) {
            result = (result * x + (i % 2 == 0 ? 3 * (i + 1) : 5 * (i + 1))) % MOD;
        }
        return result;
    }

    function mixedSeries(uint256 seed, uint256 rounds) public pure returns (uint256) {
        uint256 acc = seed % MOD;
        for (uint256 i = 1; i <= rounds; i++) {
            acc = (acc + sumOfSquaresInternal(i + seed)) % MOD;
            acc = (acc * fibonacciInternal(i + 5)) % MOD;
            acc = (acc + factorialInternal((i % 11) + 5)) % MOD;
        }
        return acc;
    }

    function sumOfSquaresInternal(uint256 n) internal pure returns (uint256 acc) {
        for (uint256 i = 1; i <= n; i++) {
            acc += i * i;
        }
    }

    function fibonacciInternal(uint256 n) internal pure returns (uint256) {
        if (n == 0) {
            return 0;
        }
        if (n == 1) {
            return 1;
        }
        uint256 prev = 0;
        uint256 curr = 1;
        for (uint256 i = 2; i <= n; i++) {
            (prev, curr) = (curr, prev + curr);
        }
        return curr % MOD;
    }

    function factorialInternal(uint256 n) internal pure returns (uint256 acc) {
        acc = 1;
        for (uint256 i = 2; i <= n; i++) {
            acc = (acc * i) % MOD;
        }
    }
}
