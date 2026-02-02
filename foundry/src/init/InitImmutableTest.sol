// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title InitImmutableTest
 * @notice Test contract with immutable variables set in constructor.
 * @dev Phase 2: Immutables support
 */
contract InitImmutableTest {
    uint256 public immutable IMMUTABLE_VALUE;
    address public immutable IMMUTABLE_OWNER;

    uint256 public mutableValue;

    constructor(uint256 _immutableVal, address _immutableOwner) {
        IMMUTABLE_VALUE = _immutableVal;
        IMMUTABLE_OWNER = _immutableOwner;
        mutableValue = 100;
    }

    function getImmutableValue() external view returns (uint256) {
        return IMMUTABLE_VALUE;
    }

    function getImmutableOwner() external view returns (address) {
        return IMMUTABLE_OWNER;
    }

    function getMutable() external view returns (uint256) {
        return mutableValue;
    }

    function setMutable(uint256 val) external {
        mutableValue = val;
    }
}
