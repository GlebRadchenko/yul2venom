// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../lib/solady/src/tokens/ERC20.sol";

/// @title SoladyToken - ERC20 Benchmark using Solady
/// @notice Tests Solady's highly optimized ERC20 implementation
contract SoladyToken is ERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    address public owner;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        owner = msg.sender;
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    // ========== Minting ==========

    function mint(address to, uint256 amount) external {
        require(msg.sender == owner, "Only owner");
        _mint(to, amount);
    }

    function mintBatch(
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external {
        require(msg.sender == owner, "Only owner");
        require(recipients.length == amounts.length, "Length mismatch");
        for (uint256 i = 0; i < recipients.length; i++) {
            _mint(recipients[i], amounts[i]);
        }
    }

    // ========== Burning ==========

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function burnFrom(address from, uint256 amount) external {
        _spendAllowance(from, msg.sender, amount);
        _burn(from, amount);
    }

    // ========== Permit (EIP-2612) ==========

    // Note: Solady ERC20 includes permit functionality via EIP-2612

    // ========== Safety Wrappers ==========

    function safeTransfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transfer(from, to, amount);
        return true;
    }
}
