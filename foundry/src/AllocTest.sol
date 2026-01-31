// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AllocTest {
    function get() public pure returns (uint256) {
        return 128;  // Should return the free memory pointer value
    }
}
