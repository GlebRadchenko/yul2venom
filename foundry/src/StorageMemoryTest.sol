// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StorageMemoryTest {
    uint256 public val;
    mapping(address => uint256) public balances;

    function setVal(uint256 _val) public {
        val = _val;
    }

    function getVal() public view returns (uint256) {
        return val;
    }
    
    function setBalance(address user, uint256 amount) public {
        balances[user] = amount;
    }
    
    function getBalance(address user) public view returns (uint256) {
        return balances[user];
    }

    function memoryArraySum(uint256[] memory arr) public pure returns (uint256) {
        uint256 sum = 0;
        for(uint256 i = 0; i < arr.length; i++) {
            sum += arr[i];
        }
        return sum;
    }
}
