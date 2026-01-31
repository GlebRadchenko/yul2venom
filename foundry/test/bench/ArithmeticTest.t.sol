// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/bench/Arithmetic.sol";

/**
 * @title ArithmeticTest
 * @dev Test contract for Arithmetic with bytecode injection support.
 *      Supports BYTECODE_PATH env var for testing different bytecode versions.
 *
 * Usage:
 *   # Test with default path (output/bench/Arithmetic_opt.bin)
 *   forge test --match-contract ArithmeticTest
 *
 *   # Test with custom bytecode path
 *   BYTECODE_PATH="path/to/bytecode.bin" forge test --match-contract ArithmeticTest
 *
 *   # Test with native Solc (no injection)
 *   BYTECODE_PATH="" forge test --match-contract ArithmeticTest
 */
contract ArithmeticTest is Test {
    Arithmetic target;
    address targetAddr;

    // Event to emit gas measurements for parsing
    event GasUsed(string func, uint256 gas);

    function setUp() public {
        // Check for custom bytecode path, default to transpiled output
        string memory bytecodePath = vm.envOr(
            "BYTECODE_PATH",
            string("output/bench/Arithmetic_opt.bin")
        );

        if (bytes(bytecodePath).length > 0) {
            // Inject bytecode from file
            try vm.readFileBinary(bytecodePath) returns (bytes memory code) {
                targetAddr = address(0x1111);
                vm.etch(targetAddr, code);
                target = Arithmetic(targetAddr);
            } catch {
                // Fallback to native Solc contract
                target = new Arithmetic();
                targetAddr = address(target);
            }
        } else {
            // Empty path = use native Solc contract
            target = new Arithmetic();
            targetAddr = address(target);
        }
    }

    // ========== Safe Addition ==========
    function test_safeAdd() public {
        uint256 result = target.safeAdd(10, 20);
        assertEq(result, 30);
    }

    function test_safeAdd_overflow() public {
        vm.expectRevert();
        target.safeAdd(type(uint256).max, 1);
    }

    // ========== Unsafe Addition ==========
    function test_unsafeAdd() public {
        uint256 result = target.unsafeAdd(10, 20);
        assertEq(result, 30);
    }

    function test_unsafeAdd_wraps() public view {
        assertEq(target.unsafeAdd(type(uint256).max, 1), 0);
    }

    // ========== Safe Subtraction ==========
    function test_safeSub() public {
        uint256 gasBefore = gasleft();
        uint256 result = target.safeSub(30, 10);
        uint256 gasUsed = gasBefore - gasleft();
        emit GasUsed("safeSub", gasUsed);
        assertEq(result, 20);
    }

    function test_safeSub_underflow() public {
        vm.expectRevert();
        target.safeSub(10, 30);
    }

    // ========== Unsafe Subtraction ==========
    function test_unsafeSub() public view {
        assertEq(target.unsafeSub(30, 10), 20);
    }

    function test_unsafeSub_wraps() public view {
        assertEq(target.unsafeSub(0, 1), type(uint256).max);
    }

    // ========== Safe Multiplication ==========
    function test_safeMul() public {
        uint256 gasBefore = gasleft();
        uint256 result = target.safeMul(6, 7);
        uint256 gasUsed = gasBefore - gasleft();
        emit GasUsed("safeMul", gasUsed);
        assertEq(result, 42);
    }

    function test_safeMul_overflow() public {
        vm.expectRevert();
        target.safeMul(type(uint256).max, 2);
    }

    // ========== Unsafe Multiplication ==========
    function test_unsafeMul() public {
        uint256 gasBefore = gasleft();
        uint256 result = target.unsafeMul(6, 7);
        uint256 gasUsed = gasBefore - gasleft();
        emit GasUsed("unsafeMul", gasUsed);
        assertEq(result, 42);
    }

    // ========== Division ==========
    function test_safeDiv() public {
        uint256 gasBefore = gasleft();
        uint256 result = target.safeDiv(100, 10);
        uint256 gasUsed = gasBefore - gasleft();
        emit GasUsed("safeDiv", gasUsed);
        assertEq(result, 10);
    }

    function test_safeDiv_byZero() public {
        vm.expectRevert();
        target.safeDiv(100, 0);
    }

    function test_unsafeDiv() public view {
        assertEq(target.unsafeDiv(100, 10), 10);
    }

    // ========== Modulo ==========
    function test_safeMod() public view {
        assertEq(target.safeMod(17, 5), 2);
    }

    function test_unsafeMod() public view {
        assertEq(target.unsafeMod(17, 5), 2);
    }

    // ========== Shifts ==========
    function test_shl() public view {
        assertEq(target.shl(2, 1), 4);
    }

    function test_shr() public view {
        assertEq(target.shr(2, 16), 4);
    }

    function test_sar() public view {
        assertEq(target.sar(-16, 2), -4);
    }

    // ========== Comparisons ==========
    function test_lt() public view {
        assertTrue(target.lt(5, 10));
        assertFalse(target.lt(10, 5));
    }

    function test_gt() public view {
        assertTrue(target.gt(10, 5));
        assertFalse(target.gt(5, 10));
    }

    function test_eq() public view {
        assertTrue(target.eq(42, 42));
        assertFalse(target.eq(1, 2));
    }

    function test_lte() public view {
        assertTrue(target.lte(5, 10));
        assertTrue(target.lte(10, 10));
        assertFalse(target.lte(11, 10));
    }

    function test_gte() public view {
        assertTrue(target.gte(10, 5));
        assertTrue(target.gte(10, 10));
        assertFalse(target.gte(9, 10));
    }

    function test_slt() public view {
        assertTrue(target.slt(-5, 5));
        assertFalse(target.slt(5, -5));
    }

    function test_sgt() public view {
        assertTrue(target.sgt(5, -5));
        assertFalse(target.sgt(-5, 5));
    }

    function test_iszero() public view {
        assertTrue(target.iszero(0));
        assertFalse(target.iszero(1));
    }

    // ========== Bitwise ==========
    function test_and() public view {
        assertEq(target.and_(0xFF, 0x0F), 0x0F);
    }

    function test_or() public view {
        assertEq(target.or_(0xF0, 0x0F), 0xFF);
    }

    function test_xor() public view {
        assertEq(target.xor_(0xFF, 0x0F), 0xF0);
    }

    function test_not() public view {
        assertEq(target.not_(0), type(uint256).max);
    }

    // ========== Exponentiation ==========
    function test_safeExp() public view {
        assertEq(target.safeExp(2, 10), 1024);
    }

    function test_unsafeExp() public view {
        assertEq(target.unsafeExp(2, 10), 1024);
    }

    // ========== Sign Extension ==========
    function test_signExtend8() public view {
        assertEq(target.signExtend8(0xFF), -1);
        assertEq(target.signExtend8(0x7F), 127);
    }

    function test_signExtend16() public view {
        assertEq(target.signExtend16(0xFFFF), -1);
        assertEq(target.signExtend16(0x7FFF), 32767);
    }
}
