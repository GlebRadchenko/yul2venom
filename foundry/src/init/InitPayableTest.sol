// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title InitPayableTest
 * @notice Test contract with payable constructor.
 * @dev Phase 2: Payable constructor (accepts ETH)
 */
contract InitPayableTest {
    uint256 public initialBalance;

    constructor() payable {
        initialBalance = msg.value;
    }

    function getInitialBalance() external view returns (uint256) {
        return initialBalance;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
