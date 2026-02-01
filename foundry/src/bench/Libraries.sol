// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Libraries Benchmark
/// @notice Tests library patterns: using X for Y, internal functions, and type extensions

// ========== Math Library ==========
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction underflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// ========== String Library ==========
library StringUtils {
    function length(string memory s) internal pure returns (uint256) {
        return bytes(s).length;
    }

    function isEmpty(string memory s) internal pure returns (bool) {
        return bytes(s).length == 0;
    }

    function equals(
        string memory a,
        string memory b
    ) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}

// ========== Address Library ==========
library AddressUtils {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function toBytes(address a) internal pure returns (bytes memory) {
        return abi.encodePacked(a);
    }
}

// ========== Array Library ==========
library ArrayUtils {
    function sum(uint256[] memory arr) internal pure returns (uint256 total) {
        for (uint256 i = 0; i < arr.length; i++) {
            total += arr[i];
        }
    }

    function max(uint256[] memory arr) internal pure returns (uint256 maxVal) {
        require(arr.length > 0, "Empty array");
        maxVal = arr[0];
        for (uint256 i = 1; i < arr.length; i++) {
            if (arr[i] > maxVal) {
                maxVal = arr[i];
            }
        }
    }

    function min(uint256[] memory arr) internal pure returns (uint256 minVal) {
        require(arr.length > 0, "Empty array");
        minVal = arr[0];
        for (uint256 i = 1; i < arr.length; i++) {
            if (arr[i] < minVal) {
                minVal = arr[i];
            }
        }
    }

    function contains(
        uint256[] memory arr,
        uint256 value
    ) internal pure returns (bool) {
        for (uint256 i = 0; i < arr.length; i++) {
            if (arr[i] == value) return true;
        }
        return false;
    }
}

// ========== Main Contract ==========
contract Libraries {
    using SafeMath for uint256;
    using StringUtils for string;
    using AddressUtils for address;
    using ArrayUtils for uint256[];

    uint256 public storedValue;
    string public storedString;

    // ========== SafeMath Tests ==========

    function testAdd(uint256 a, uint256 b) external pure returns (uint256) {
        return a.add(b);
    }

    function testSub(uint256 a, uint256 b) external pure returns (uint256) {
        return a.sub(b);
    }

    function testMul(uint256 a, uint256 b) external pure returns (uint256) {
        return a.mul(b);
    }

    function testDiv(uint256 a, uint256 b) external pure returns (uint256) {
        return a.div(b);
    }

    function testMod(uint256 a, uint256 b) external pure returns (uint256) {
        return a.mod(b);
    }

    function testChainedMath(
        uint256 a,
        uint256 b,
        uint256 c
    ) external pure returns (uint256) {
        // a + b * c
        return a.add(b.mul(c));
    }

    function testComplexMath(uint256 x) external pure returns (uint256) {
        // (x + 10) * 2 - 5
        return x.add(10).mul(2).sub(5);
    }

    // ========== StringUtils Tests ==========

    function testStringLength(
        string calldata s
    ) external pure returns (uint256) {
        return s.length();
    }

    function testStringEmpty(string calldata s) external pure returns (bool) {
        return s.isEmpty();
    }

    function testStringEquals(
        string calldata a,
        string calldata b
    ) external pure returns (bool) {
        return a.equals(b);
    }

    // ========== AddressUtils Tests ==========

    function testIsContract(address account) external view returns (bool) {
        return account.isContract();
    }

    function testAddressToBytes(
        address a
    ) external pure returns (bytes memory) {
        return a.toBytes();
    }

    // ========== ArrayUtils Tests ==========

    function testArraySum(
        uint256[] calldata arr
    ) external pure returns (uint256) {
        return arr.sum();
    }

    function testArrayMax(
        uint256[] calldata arr
    ) external pure returns (uint256) {
        return arr.max();
    }

    function testArrayMin(
        uint256[] calldata arr
    ) external pure returns (uint256) {
        return arr.min();
    }

    function testArrayContains(
        uint256[] calldata arr,
        uint256 value
    ) external pure returns (bool) {
        return arr.contains(value);
    }

    // ========== State-Modifying with Library ==========

    function incrementBy(uint256 amount) external returns (uint256) {
        storedValue = storedValue.add(amount);
        return storedValue;
    }

    function decrementBy(uint256 amount) external returns (uint256) {
        storedValue = storedValue.sub(amount);
        return storedValue;
    }

    function multiplyBy(uint256 factor) external returns (uint256) {
        storedValue = storedValue.mul(factor);
        return storedValue;
    }

    // ========== Mixed Library Usage ==========

    function processData(
        uint256[] calldata values,
        uint256 multiplier
    ) external pure returns (uint256 total, uint256 maxVal, uint256 minVal) {
        total = values.sum().mul(multiplier);
        maxVal = values.max();
        minVal = values.min();
    }

    // ========== Direct Library Calls (not via using) ==========

    function directLibraryCall(
        uint256 a,
        uint256 b
    ) external pure returns (uint256) {
        return SafeMath.add(a, b);
    }

    // ========== View/Pure Helpers ==========

    function getStoredValue() external view returns (uint256) {
        return storedValue;
    }

    function setStoredValue(uint256 val) external {
        storedValue = val;
    }
}
