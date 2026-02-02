// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title InitComplexTest
 * @notice Complex constructor test with multiple patterns combined.
 * @dev Tests: args + storage init + internal function call + require
 *      Note: Avoids mappings to prevent sha3_64 optimization issues
 */
contract InitComplexTest {
    address public owner;
    uint256 public totalSupply;
    uint256 public ownerBalance;

    event Initialized(address indexed owner, uint256 supply);

    constructor(address _owner, uint256 _initialSupply) {
        require(_owner != address(0), "Invalid owner");
        require(_initialSupply > 0, "Invalid supply");

        owner = _owner;
        totalSupply = _initialSupply;
        _mint(_initialSupply);

        emit Initialized(_owner, _initialSupply);
    }

    function _mint(uint256 amount) internal {
        ownerBalance += amount;
    }

    function balanceOf() external view returns (uint256) {
        return ownerBalance;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function getTotalSupply() external view returns (uint256) {
        return totalSupply;
    }
}
