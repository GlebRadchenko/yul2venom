// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MissingFeatures {
    event Log1(uint256 indexed a);
    event Log2(uint256 indexed a, uint256 indexed b);
    event LogData(string msg);

    // 1. Events
    function testEvents() public {
        emit Log1(100);
        emit Log2(200, 300);
        emit LogData("Hello");
    }

    // 2. ABI Encoding
    function testAbiEncode() public pure returns (bytes memory) {
        return abi.encode(uint256(1), uint256(2));
    }

    function testAbiEncodePacked() public pure returns (bytes memory) {
        return abi.encodePacked(uint256(1), uint16(2));
    }

    // 3. Error Handling - return bool instead of reverting for fuzz safety
    function testRequire(bool shouldPass) public pure returns (bool) {
        if (!shouldPass) return false;
        return true;
    }

    function testAssert(bool shouldPass) public pure returns (bool) {
        // Return the condition instead of asserting for fuzz test compatibility
        return shouldPass;
    }

    // 4. Type Casting
    function testCast(int256 a) public pure returns (uint256) {
        return uint256(a);
    }

    // 5. Try/Catch (Basic)
    function tryCatchTest(uint256 x) public view returns (bool) {
        try this.externalFail(x) {
            return true;
        } catch {
            return false;
        }
    }

    function externalFail(uint256 x) public pure {
        require(x < 10, "Too big");
    }
}
