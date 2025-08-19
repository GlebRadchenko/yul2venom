// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleStorage {
    uint256 private storedValue;
    
    event ValueChanged(uint256 newValue);
    
    constructor(uint256 initialValue) {
        storedValue = initialValue;
    }
    
    function store(uint256 value) public {
        storedValue = value;
        emit ValueChanged(value);
    }
    
    function retrieve() public view returns (uint256) {
        return storedValue;
    }
    
    function increment() public {
        storedValue = storedValue + 1;
        emit ValueChanged(storedValue);
    }
    
    function decrement() public {
        require(storedValue > 0, "Cannot decrement below zero");
        storedValue = storedValue - 1;
        emit ValueChanged(storedValue);
    }
}