// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Test: Constructor creates child contracts using `new`
/// @dev Pattern from BootPath.sol - creates multiple child contracts in constructor

// Simple child contract to be created
contract ChildContractA {
    address public parent;
    uint256 public value;

    constructor(address _parent, uint256 _value) {
        parent = _parent;
        value = _value;
    }

    function getInfo() external view returns (address, uint256) {
        return (parent, value);
    }
}

contract ChildContractB {
    address public owner;
    string public name;

    constructor(address _owner, string memory _name) {
        owner = _owner;
        name = _name;
    }

    function getName() external view returns (string memory) {
        return name;
    }
}

/// @title InitNewChildTest
/// @dev Creates child contracts in constructor, stores their addresses
contract InitNewChildTest {
    // Immutable to store child address
    address public immutable childA;
    address public immutable childB;

    // Storage to store another child
    address public childC;

    // Values set in constructor
    uint256 public value;
    address public deployer;

    constructor(uint256 _value, string memory _name) {
        value = _value;
        deployer = msg.sender;

        // Create child contracts with `new`
        childA = address(new ChildContractA(address(this), _value));
        childB = address(new ChildContractB(msg.sender, _name));

        // Create another child and store in storage
        childC = address(new ChildContractA(address(this), _value * 2));
    }

    function getValue() external view returns (uint256) {
        return value;
    }

    function getChildA() external view returns (address) {
        return childA;
    }

    function getChildB() external view returns (address) {
        return childB;
    }

    function getChildC() external view returns (address) {
        return childC;
    }

    function getDeployer() external view returns (address) {
        return deployer;
    }

    // Call child contract to verify it was created correctly
    function verifyChildA() external view returns (address, uint256) {
        return ChildContractA(childA).getInfo();
    }

    function verifyChildB() external view returns (string memory) {
        return ChildContractB(childB).getName();
    }
}
