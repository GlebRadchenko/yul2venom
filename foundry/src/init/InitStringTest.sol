// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title InitStringTest
 * @notice Test contract with dynamic string constructor arg.
 * @dev Phase 2: Dynamic constructor args (strings/bytes)
 */
contract InitStringTest {
    string public name;
    string public symbol;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function getName() external view returns (string memory) {
        return name;
    }

    function getSymbol() external view returns (string memory) {
        return symbol;
    }
}
