// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Phase 2 Test: Single function call with no args and no returns
contract VoidCall {
    function trigger() external {
        _internal();
    }
    
    function _internal() internal {
        // Empty function - just tests call/return mechanics
    }
}
