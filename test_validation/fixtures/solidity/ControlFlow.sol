// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ControlFlow {
    mapping(uint256 => uint256) public values;
    
    function ifElseTest(uint256 x) public pure returns (string memory) {
        if (x < 10) {
            return "less than 10";
        } else if (x < 100) {
            return "less than 100";
        } else {
            return "100 or more";
        }
    }
    
    function forLoopSum(uint256 n) public pure returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 1; i <= n; i++) {
            sum += i;
        }
        return sum;
    }
    
    function whileLoopFactorial(uint256 n) public pure returns (uint256) {
        if (n == 0) return 1;
        
        uint256 result = 1;
        uint256 i = n;
        while (i > 0) {
            result *= i;
            i--;
        }
        return result;
    }
    
    function switchCase(uint8 option) public pure returns (string memory) {
        if (option == 1) {
            return "Option One";
        } else if (option == 2) {
            return "Option Two";
        } else if (option == 3) {
            return "Option Three";
        } else {
            return "Invalid Option";
        }
    }
    
    function breakContinueTest(uint256[] memory arr) public pure returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < arr.length; i++) {
            if (arr[i] == 0) {
                continue;  // Skip zeros
            }
            if (arr[i] > 100) {
                break;  // Stop if value exceeds 100
            }
            sum += arr[i];
        }
        return sum;
    }
    
    function nestedLoops(uint256 n) public pure returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < n; i++) {
            for (uint256 j = 0; j < n; j++) {
                count++;
            }
        }
        return count;
    }
    
    function requireTest(uint256 x) public pure returns (uint256) {
        require(x > 0, "Value must be positive");
        require(x < 1000, "Value too large");
        return x * 2;
    }
    
    function assertTest(uint256 x) public pure returns (uint256) {
        assert(x < type(uint256).max / 2);
        return x * 2;
    }
}