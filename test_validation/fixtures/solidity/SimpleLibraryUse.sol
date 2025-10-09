// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

library SimpleLibrary {
    function double(uint256 value) external pure returns (uint256) {
        return value * 2;
    }
}

contract UsesSimpleLibrary {
    function double(uint256 value) external pure returns (uint256) {
        return SimpleLibrary.double(value);
    }
}
