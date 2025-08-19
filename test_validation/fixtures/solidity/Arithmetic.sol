// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Arithmetic {
    function add(uint256 a, uint256 b) public pure returns (uint256) {
        return a + b;
    }
    
    function subtract(uint256 a, uint256 b) public pure returns (uint256) {
        require(b <= a, "Subtraction overflow");
        return a - b;
    }
    
    function multiply(uint256 a, uint256 b) public pure returns (uint256) {
        return a * b;
    }
    
    function divide(uint256 a, uint256 b) public pure returns (uint256) {
        require(b > 0, "Division by zero");
        return a / b;
    }
    
    function modulo(uint256 a, uint256 b) public pure returns (uint256) {
        require(b > 0, "Modulo by zero");
        return a % b;
    }
    
    function power(uint256 base, uint256 exponent) public pure returns (uint256) {
        if (exponent == 0) return 1;
        uint256 result = 1;
        for (uint256 i = 0; i < exponent; i++) {
            result *= base;
        }
        return result;
    }
    
    function maximum(uint256 a, uint256 b) public pure returns (uint256) {
        return a > b ? a : b;
    }
    
    function minimum(uint256 a, uint256 b) public pure returns (uint256) {
        return a < b ? a : b;
    }
}