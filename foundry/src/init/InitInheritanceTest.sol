// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Test: Deep inheritance chain constructor

// Level 1: Base contract
contract BaseLevel1 {
    address public immutable weth;

    constructor(address _weth) {
        weth = _weth;
    }
}

// Level 2: Adds owner
contract BaseLevel2 is BaseLevel1 {
    address public immutable owner;

    constructor(address _weth, address _owner) BaseLevel1(_weth) {
        owner = _owner;
    }
}

// Level 3: Adds config
contract BaseLevel3 is BaseLevel2 {
    uint256 public immutable config;

    constructor(
        address _weth,
        address _owner,
        uint256 _config
    ) BaseLevel2(_weth, _owner) {
        config = _config;
    }
}

/// @title InitInheritanceTest
/// @dev Deep inheritance chain with immutables at each level
contract InitInheritanceTest is BaseLevel3 {
    // Additional immutables at the final level
    address public immutable sender0;
    address public immutable sender1;

    // Storage variables set by constructor
    bool public active;
    uint256 public createdAt;

    constructor(
        address _weth,
        address _owner,
        uint256 _config,
        address _sender0,
        address _sender1
    ) BaseLevel3(_weth, _owner, _config) {
        sender0 = _sender0;
        sender1 = _sender1;
        active = true;
        createdAt = block.timestamp;
    }

    function getWeth() external view returns (address) {
        return weth;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function getConfig() external view returns (uint256) {
        return config;
    }

    function getSender0() external view returns (address) {
        return sender0;
    }

    function getSender1() external view returns (address) {
        return sender1;
    }

    function isActive() external view returns (bool) {
        return active;
    }

    function getCreatedAt() external view returns (uint256) {
        return createdAt;
    }
}
