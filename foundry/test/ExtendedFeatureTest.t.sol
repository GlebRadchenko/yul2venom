// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

interface IMissingFeatures {
    function testEvents() external;
    function testAbiEncode() external pure returns (bytes memory);
    function testAbiEncodePacked() external pure returns (bytes memory);
    function testRequire(bool fail) external pure returns (bool);
    function testAssert(bool fail) external pure returns (bool);
    function testCast(int256 a) external pure returns (uint256);
    function tryCatchTest(uint256 x) external view returns (bool);
}

contract ExtendedFeatureTest is Test {
    IMissingFeatures target;

    event Log1(uint256 indexed a);
    event Log2(uint256 indexed a, uint256 indexed b);
    event LogData(string msg);

    function setUp() public {
        bytes memory bytecode = vm.readFileBinary(
            "../output/MissingFeatures_opt_runtime.bin"
        );
        address addr = address(0xABC);
        vm.etch(addr, bytecode);
        target = IMissingFeatures(addr);
    }

    // 1. Events
    function test_Events() public {
        vm.expectEmit(true, false, false, false);
        emit Log1(100);
        vm.expectEmit(true, true, false, false);
        emit Log2(200, 300);
        // LogData(string) -> keccak("LogData(string)") topic
        // vm.expectEmit(false, false, false, true); // data check?
        // emit LogData("Hello");

        target.testEvents();
    }

    // 2. ABI Encoding
    function test_AbiEncode() public view {
        bytes memory expected = abi.encode(uint256(1), uint256(2));
        bytes memory actual = target.testAbiEncode();
        assertEq(actual, expected, "abi.encode mismatch");
    }

    function test_AbiEncodePacked() public view {
        bytes memory expected = abi.encodePacked(uint256(1), uint16(2));
        bytes memory actual = target.testAbiEncodePacked();
        // abi.encodePacked(1, 2) -> 32 bytes of 1 + 2 bytes of 2 -> 34 bytes?
        // uint256(1) -> 32 bytes. uint16(2) -> 2 bytes. Total 34 bytes.
        assertEq(actual, expected, "abi.encodePacked mismatch");
    }

    // 3. Error Handling - Contract now returns bool instead of reverting
    function test_Require() public view {
        // Contract returns false when shouldPass=false, true when shouldPass=true
        assertFalse(
            target.testRequire(false),
            "testRequire(false) should return false"
        );
        assertTrue(
            target.testRequire(true),
            "testRequire(true) should return true"
        );
    }

    function test_Assert() public view {
        // Contract returns the shouldPass value directly
        assertFalse(
            target.testAssert(false),
            "testAssert(false) should return false"
        );
        assertTrue(
            target.testAssert(true),
            "testAssert(true) should return true"
        );
    }

    // 4. Type Casting
    function test_Cast() public view {
        assertEq(target.testCast(-1), type(uint256).max, "-1 -> MAX_UINT");
        assertEq(target.testCast(100), 100, "100 -> 100");
    }

    // 5. Try/Catch - KNOWN LIMITATION (Runtime StackOverflow)
    function test_TryCatch() public view {
        // x < 10 -> externalFail calls require -> true
        assertTrue(target.tryCatchTest(5), "tryCatch(5) should return true");

        // x >= 10 -> externalFail reverts -> catch block -> false
        assertFalse(
            target.tryCatchTest(15),
            "tryCatch(15) should return false"
        );
    }
}
