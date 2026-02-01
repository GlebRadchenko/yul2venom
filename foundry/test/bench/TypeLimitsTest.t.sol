// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/bench/TypeLimits.sol";

/**
 * @title TypeLimitsTest
 * @dev Tests for type(T).max, type(T).min and related type introspection.
 */
contract TypeLimitsTest is Test {
    TypeLimits target;
    address payable targetAddr;

    function setUp() public {
        string memory bytecodePath = vm.envOr(
            "BYTECODE_PATH",
            string("../output/TypeLimits_opt.bin")
        );

        if (bytes(bytecodePath).length > 0) {
            try vm.readFileBinary(bytecodePath) returns (bytes memory code) {
                targetAddr = payable(address(0x7777));
                vm.etch(targetAddr, code);
                target = TypeLimits(targetAddr);
            } catch {
                target = new TypeLimits();
                targetAddr = payable(address(target));
            }
        } else {
            target = new TypeLimits();
            targetAddr = payable(address(target));
        }
    }

    // ========== Unsigned Integer Limits ==========

    function test_uint8Limits() public view {
        (uint8 min, uint8 max) = target.uint8Limits();
        assertEq(min, 0);
        assertEq(max, 255);
    }

    function test_uint16Limits() public view {
        (uint16 min, uint16 max) = target.uint16Limits();
        assertEq(min, 0);
        assertEq(max, 65535);
    }

    function test_uint32Limits() public view {
        (uint32 min, uint32 max) = target.uint32Limits();
        assertEq(min, 0);
        assertEq(max, 4294967295);
    }

    function test_uint64Limits() public view {
        (uint64 min, uint64 max) = target.uint64Limits();
        assertEq(min, 0);
        assertEq(max, 18446744073709551615);
    }

    function test_uint128Limits() public view {
        (uint128 min, uint128 max) = target.uint128Limits();
        assertEq(min, 0);
        assertEq(max, type(uint128).max);
    }

    function test_uint256Limits() public view {
        (uint256 min, uint256 max) = target.uint256Limits();
        assertEq(min, 0);
        assertEq(max, type(uint256).max);
    }

    // ========== Signed Integer Limits ==========

    function test_int8Limits() public view {
        (int8 min, int8 max) = target.int8Limits();
        assertEq(min, -128);
        assertEq(max, 127);
    }

    function test_int16Limits() public view {
        (int16 min, int16 max) = target.int16Limits();
        assertEq(min, -32768);
        assertEq(max, 32767);
    }

    function test_int32Limits() public view {
        (int32 min, int32 max) = target.int32Limits();
        assertEq(min, -2147483648);
        assertEq(max, 2147483647);
    }

    function test_int64Limits() public view {
        (int64 min, int64 max) = target.int64Limits();
        assertEq(min, type(int64).min);
        assertEq(max, type(int64).max);
    }

    function test_int128Limits() public view {
        (int128 min, int128 max) = target.int128Limits();
        assertEq(min, type(int128).min);
        assertEq(max, type(int128).max);
    }

    function test_int256Limits() public view {
        (int256 min, int256 max) = target.int256Limits();
        assertEq(min, type(int256).min);
        assertEq(max, type(int256).max);
    }

    // ========== Practical Use Cases ==========

    function test_wouldOverflow() public view {
        assertTrue(target.wouldOverflow(type(uint256).max, 1));
        assertTrue(target.wouldOverflow(type(uint256).max - 10, 20));
        assertFalse(target.wouldOverflow(100, 200));
        assertFalse(target.wouldOverflow(0, type(uint256).max));
    }

    function test_wouldUnderflow() public view {
        assertTrue(target.wouldUnderflow(10, 20));
        assertTrue(target.wouldUnderflow(0, 1));
        assertFalse(target.wouldUnderflow(100, 50));
        assertFalse(target.wouldUnderflow(100, 100));
    }

    function test_safeAdd() public view {
        assertEq(target.safeAdd(100, 200), 300);
        assertEq(target.safeAdd(0, 0), 0);
    }

    function test_safeAdd_overflow() public {
        vm.expectRevert("overflow");
        target.safeAdd(type(uint256).max, 1);
    }

    function test_clampToUint8() public view {
        assertEq(target.clampToUint8(50), 50);
        assertEq(target.clampToUint8(255), 255);
        assertEq(target.clampToUint8(256), 255);
        assertEq(target.clampToUint8(1000), 255);
    }

    function test_clampToInt128() public view {
        assertEq(target.clampToInt128(100), 100);
        assertEq(target.clampToInt128(-100), -100);
        assertEq(target.clampToInt128(type(int256).max), type(int128).max);
        assertEq(target.clampToInt128(type(int256).min), type(int128).min);
    }

    function test_fitsInUint128() public view {
        assertTrue(target.fitsInUint128(0));
        assertTrue(target.fitsInUint128(type(uint128).max));
        assertFalse(target.fitsInUint128(uint256(type(uint128).max) + 1));
        assertFalse(target.fitsInUint128(type(uint256).max));
    }

    function test_fitsInInt64() public view {
        assertTrue(target.fitsInInt64(0));
        assertTrue(target.fitsInInt64(type(int64).max));
        assertTrue(target.fitsInInt64(type(int64).min));
        assertFalse(target.fitsInInt64(int256(type(int64).max) + 1));
        assertFalse(target.fitsInInt64(int256(type(int64).min) - 1));
    }

    // ========== Interface ID ==========

    function test_getInterfaceId() public view {
        bytes4 id = target.getInterfaceId();
        // ERC165 interface ID is 0x01ffc9a7
        assertTrue(id == bytes4(0x01ffc9a7));
    }

    // ========== Constants ==========

    function test_getConstants() public view {
        (
            uint256 maxUint,
            int256 minInt,
            int256 maxInt,
            uint128 maxUint128
        ) = target.getConstants();
        assertEq(maxUint, type(uint256).max);
        assertEq(minInt, type(int256).min);
        assertEq(maxInt, type(int256).max);
        assertEq(maxUint128, type(uint128).max);
    }

    function test_isMaxUint256() public view {
        assertTrue(target.isMaxUint256(type(uint256).max));
        assertFalse(target.isMaxUint256(type(uint256).max - 1));
        assertFalse(target.isMaxUint256(0));
    }

    function test_isMinInt256() public view {
        assertTrue(target.isMinInt256(type(int256).min));
        assertFalse(target.isMinInt256(type(int256).min + 1));
        assertFalse(target.isMinInt256(0));
    }

    // ========== Bitwise Calculations ==========

    function test_maxForBits() public view {
        assertEq(target.maxForBits(1), 1);
        assertEq(target.maxForBits(8), 255);
        assertEq(target.maxForBits(16), 65535);
        assertEq(target.maxForBits(32), 4294967295);
        // Note: Can't test 256 as param is uint8 (max 255)
    }

    function test_maxForBits_invalid() public {
        vm.expectRevert("Invalid bits");
        target.maxForBits(0);
    }
}
