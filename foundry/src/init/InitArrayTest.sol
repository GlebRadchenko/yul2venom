// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title InitArrayTest
 * @notice Test contract with array constructor arg and storage array init.
 * @dev Phase 2: Storage array initialization
 */
contract InitArrayTest {
    uint256[] public values;

    constructor(uint256[] memory _initialValues) {
        for (uint256 i = 0; i < _initialValues.length; i++) {
            values.push(_initialValues[i]);
        }
    }

    function getLength() external view returns (uint256) {
        return values.length;
    }

    function getValueAt(uint256 index) external view returns (uint256) {
        return values[index];
    }

    function getAllValues() external view returns (uint256[] memory) {
        return values;
    }
}
