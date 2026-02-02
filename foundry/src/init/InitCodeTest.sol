// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title InitCodeTest
 * @notice Minimal contract for testing init bytecode transpilation.
 * @dev No constructor args - simplest case for Phase 1 init support.
 */
contract InitCodeTest {
    uint256 public value;

    constructor() {
        value = 42;
    }

    function getValue() external view returns (uint256) {
        return value;
    }

    function setValue(uint256 newValue) external {
        value = newValue;
    }
}
