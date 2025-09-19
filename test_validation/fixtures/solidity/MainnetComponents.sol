// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Extract key components from MainnetFlat for testing

interface IERC20Simple {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
}

contract SimpleStorage {
    uint256 private storedValue;
    mapping(address => uint256) private balances;
    address public owner;

    event ValueStored(uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function store(uint256 value) public {
        storedValue = value;
        emit ValueStored(value);
    }

    function retrieve() public view returns (uint256) {
        return storedValue;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    function getBalance(address account) public view returns (uint256) {
        return balances[account];
    }
}

contract MathOperations {
    using SafeMath for uint256;

    function testAdd(uint256 a, uint256 b) public pure returns (uint256) {
        return a.add(b);
    }

    function testSub(uint256 a, uint256 b) public pure returns (uint256) {
        return a.sub(b);
    }

    function testMul(uint256 a, uint256 b) public pure returns (uint256) {
        return a.mul(b);
    }

    function complexCalculation(uint256 x, uint256 y, uint256 z) public pure returns (uint256) {
        // (x + y) * z - y
        uint256 sum = x.add(y);
        uint256 product = sum.mul(z);
        return product.sub(y);
    }
}

// Patterns from MainnetFlat
contract ABIPatterns {
    struct SwapData {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 amountOutMin;
        bytes path;
    }

    function decodeSwapData(bytes calldata data) public pure returns (SwapData memory) {
        return abi.decode(data, (SwapData));
    }

    function encodePacked(address a, uint256 b) public pure returns (bytes memory) {
        return abi.encodePacked(a, b);
    }

    function hashData(bytes memory data) public pure returns (bytes32) {
        return keccak256(data);
    }
}

contract ErrorHandling {
    error InsufficientBalance(uint256 requested, uint256 available);
    error UnauthorizedAccess(address caller);
    error InvalidParameter(string param);

    uint256 private balance = 1000;
    address private authorized = address(0x123);

    function testRevert(uint256 amount) public view {
        if (amount > balance) {
            revert InsufficientBalance(amount, balance);
        }
    }

    function testRequire(address caller) public view {
        require(caller == authorized, "Not authorized");
    }

    function testAssert(uint256 x) public pure {
        assert(x > 0);
    }

    function testCustomError(string memory param) public pure {
        if (bytes(param).length == 0) {
            revert InvalidParameter(param);
        }
    }
}

contract MemoryPatterns {
    function allocateArray(uint256 size) public pure returns (uint256[] memory) {
        uint256[] memory arr = new uint256[](size);
        for (uint256 i = 0; i < size; i++) {
            arr[i] = i * 2;
        }
        return arr;
    }

    function copyBytes(bytes memory source) public pure returns (bytes memory) {
        bytes memory dest = new bytes(source.length);
        for (uint256 i = 0; i < source.length; i++) {
            dest[i] = source[i];
        }
        return dest;
    }

    function concatenate(string memory a, string memory b) public pure returns (string memory) {
        return string(abi.encodePacked(a, b));
    }
}

contract ControlFlowPatterns {
    function fibonacci(uint256 n) public pure returns (uint256) {
        if (n <= 1) return n;

        uint256 a = 0;
        uint256 b = 1;

        for (uint256 i = 2; i <= n; i++) {
            uint256 temp = a + b;
            a = b;
            b = temp;
        }

        return b;
    }

    function findMax(uint256[] memory arr) public pure returns (uint256) {
        require(arr.length > 0, "Empty array");

        uint256 max = arr[0];
        for (uint256 i = 1; i < arr.length; i++) {
            if (arr[i] > max) {
                max = arr[i];
            }
        }

        return max;
    }

    function switchCase(uint256 option) public pure returns (string memory) {
        if (option == 1) {
            return "Option One";
        } else if (option == 2) {
            return "Option Two";
        } else if (option == 3) {
            return "Option Three";
        } else {
            return "Default";
        }
    }
}