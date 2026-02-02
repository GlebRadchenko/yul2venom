// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title InitConstructorArgsTest
 * @notice Test contract for constructor with value arguments.
 * @dev Phase 2: Simple constructor args (uint256, address, bool)
 */
contract InitConstructorArgsTest {
    uint256 public value;
    address public owner;
    bool public active;

    constructor(uint256 _value, address _owner, bool _active) {
        value = _value;
        owner = _owner;
        active = _active;
    }

    function getValue() external view returns (uint256) {
        return value;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function isActive() external view returns (bool) {
        return active;
    }
}
