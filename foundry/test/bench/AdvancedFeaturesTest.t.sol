// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/bench/AdvancedFeatures.sol";

/**
 * @title AdvancedFeaturesTest
 * @dev Tests for advanced Solidity features:
 *   - User-defined value types (TokenId, Amount, Percentage)
 *   - abi.encodeCall
 *   - Fixed-size byte arrays (bytes1-bytes32)
 *   - String/bytes concatenation
 */
contract AdvancedFeaturesTest is Test {
    AdvancedFeatures target;
    address payable targetAddr;

    address alice = address(0xA11CE);
    address bob = address(0xB0B);

    function setUp() public {
        string memory bytecodePath = vm.envOr(
            "BYTECODE_PATH",
            string("../output/AdvancedFeatures_opt.bin")
        );

        if (bytes(bytecodePath).length > 0) {
            try vm.readFileBinary(bytecodePath) returns (bytes memory code) {
                targetAddr = payable(address(0x4444));
                vm.etch(targetAddr, code);
                target = AdvancedFeatures(targetAddr);
            } catch {
                target = new AdvancedFeatures();
                targetAddr = payable(address(target));
            }
        } else {
            target = new AdvancedFeatures();
            targetAddr = payable(address(target));
        }
    }

    // ========== User-Defined Value Types ==========

    function test_mintToken() public {
        TokenId id = target.mintToken(alice);
        assertEq(TokenId.unwrap(id), 1);
        assertEq(target.getTokenOwner(id), alice);
    }

    function test_mintToken_multiple() public {
        TokenId id1 = target.mintToken(alice);
        TokenId id2 = target.mintToken(bob);
        TokenId id3 = target.mintToken(alice);

        assertEq(TokenId.unwrap(id1), 1);
        assertEq(TokenId.unwrap(id2), 2);
        assertEq(TokenId.unwrap(id3), 3);
        assertEq(target.getTokenOwner(id1), alice);
        assertEq(target.getTokenOwner(id2), bob);
    }

    function test_setAmount() public {
        Amount amt = Amount.wrap(1000);
        target.setAmount(alice, amt);
        assertEq(Amount.unwrap(target.getAmount(alice)), 1000);
    }

    function test_addAmounts() public view {
        Amount a = Amount.wrap(100);
        Amount b = Amount.wrap(200);
        Amount result = target.addAmounts(a, b);
        assertEq(Amount.unwrap(result), 300);
    }

    function test_percentageToUint() public view {
        Percentage p = Percentage.wrap(50);
        assertEq(target.percentageToUint(p), 50);
    }

    // ========== abi.encodeCall ==========

    function test_encodeTransfer() public view {
        bytes memory encoded = target.encodeTransfer(alice, 1000);
        bytes memory expected = abi.encodeWithSelector(
            IERC20.transfer.selector,
            alice,
            1000
        );
        assertEq(encoded, expected);
    }

    function test_encodeApprove() public view {
        bytes memory encoded = target.encodeApprove(bob, 500);
        bytes memory expected = abi.encodeWithSelector(
            IERC20.approve.selector,
            bob,
            500
        );
        assertEq(encoded, expected);
    }

    function test_encodeBalanceOf() public view {
        bytes memory encoded = target.encodeBalanceOf(alice);
        bytes memory expected = abi.encodeWithSelector(
            IERC20.balanceOf.selector,
            alice
        );
        assertEq(encoded, expected);
    }

    function test_encodeCall_matchesManual() public view {
        bytes memory viaEncodeCall = target.encodeTransfer(alice, 1000);
        bytes memory viaManual = target.encodeTransferManual(alice, 1000);
        assertEq(viaEncodeCall, viaManual);
    }

    // ========== Fixed-Size Byte Arrays ==========

    function test_bytes1() public {
        target.setBytes1(bytes1(0x42));
        assertEq(target.storedBytes1(), bytes1(0x42));
    }

    function test_bytes2() public {
        target.setBytes2(bytes2(0x1234));
        assertEq(target.storedBytes2(), bytes2(0x1234));
    }

    function test_bytes4() public {
        target.setBytes4(bytes4(0xDEADBEEF));
        assertEq(target.storedBytes4(), bytes4(0xDEADBEEF));
    }

    function test_bytes8() public {
        target.setBytes8(bytes8(0x123456789ABCDEF0));
        assertEq(target.storedBytes8(), bytes8(0x123456789ABCDEF0));
    }

    function test_bytes16() public {
        target.setBytes16(bytes16(0x0102030405060708090A0B0C0D0E0F10));
        assertEq(
            target.storedBytes16(),
            bytes16(0x0102030405060708090A0B0C0D0E0F10)
        );
    }

    function test_bytes20() public {
        target.setBytes20(bytes20(alice));
        assertEq(target.storedBytes20(), bytes20(alice));
    }

    function test_bytes32() public {
        bytes32 val = keccak256("test");
        target.setBytes32(val);
        assertEq(target.storedBytes32(), val);
    }

    // ========== Conversions ==========

    function test_addressToBytes20() public view {
        bytes20 result = target.addressToBytes20(alice);
        assertEq(result, bytes20(alice));
    }

    function test_bytes20ToAddress() public view {
        bytes20 b = bytes20(alice);
        address result = target.bytes20ToAddress(b);
        assertEq(result, alice);
    }

    function test_bytes4Selector() public view {
        bytes4 sel = target.bytes4Selector();
        assertEq(sel, IERC20.transfer.selector);
    }

    function test_extractBytes4FromBytes32() public view {
        bytes32 data = bytes32(
            0xDEADBEEF00000000000000000000000000000000000000000000000000000000
        );
        bytes4 result = target.extractBytes4FromBytes32(data);
        assertEq(result, bytes4(0xDEADBEEF));
    }

    function test_extractBytes8FromBytes32() public view {
        bytes32 data = bytes32(
            0x123456789ABCDEF0000000000000000000000000000000000000000000000000
        );
        bytes8 result = target.extractBytes8FromBytes32(data);
        assertEq(result, bytes8(0x123456789ABCDEF0));
    }

    // ========== Bitwise Operations ==========

    function test_xorBytes4() public view {
        bytes4 a = bytes4(0xFF00FF00);
        bytes4 b = bytes4(0x0F0F0F0F);
        bytes4 result = target.xorBytes4(a, b);
        assertEq(result, bytes4(0xF00FF00F));
    }

    function test_andBytes4() public view {
        bytes4 a = bytes4(0xFF00FF00);
        bytes4 b = bytes4(0x0F0F0F0F);
        bytes4 result = target.andBytes4(a, b);
        assertEq(result, bytes4(0x0F000F00));
    }

    function test_orBytes4() public view {
        bytes4 a = bytes4(0xFF00FF00);
        bytes4 b = bytes4(0x0F0F0F0F);
        bytes4 result = target.orBytes4(a, b);
        assertEq(result, bytes4(0xFF0FFF0F));
    }

    function test_notBytes4() public view {
        bytes4 a = bytes4(0xFF00FF00);
        bytes4 result = target.notBytes4(a);
        assertEq(result, bytes4(0x00FF00FF));
    }

    // ========== Concatenation ==========

    function test_concatBytes() public view {
        bytes memory result = target.concatBytes(bytes1(0x01), bytes1(0x02));
        assertEq(result.length, 2);
        assertEq(result[0], bytes1(0x01));
        assertEq(result[1], bytes1(0x02));
    }

    function test_concatMultiple() public view {
        bytes memory result = target.concatMultiple(
            bytes4(0x11111111),
            bytes4(0x22222222),
            bytes8(0x3333333333333333)
        );
        assertEq(result.length, 16);
    }

    function test_concatStrings() public view {
        string memory result = target.concatStrings("hello", " world");
        assertEq(result, "hello world");
    }

    function test_concatThreeStrings() public view {
        string memory result = target.concatThreeStrings("foo", "bar", "baz");
        assertEq(result, "foobarbaz");
    }

    // ========== Index Access (byte opcode) ==========

    function test_getByteAt_firstByte() public view {
        bytes32 data = bytes32(
            0xDEADBEEF00000000000000000000000000000000000000000000000000000000
        );
        bytes1 result = target.getByteAt(data, 0);
        assertEq(result, bytes1(0xDE));
    }

    function test_getByteAt_secondByte() public view {
        bytes32 data = bytes32(
            0xDEADBEEF00000000000000000000000000000000000000000000000000000000
        );
        bytes1 result = target.getByteAt(data, 1);
        assertEq(result, bytes1(0xAD));
    }

    function test_getByteAt_lastByte() public view {
        bytes32 data = bytes32(
            0x00000000000000000000000000000000000000000000000000000000000000FF
        );
        bytes1 result = target.getByteAt(data, 31);
        assertEq(result, bytes1(0xFF));
    }

    function test_getByteAt_outOfBounds() public {
        bytes32 data = bytes32(
            0xDEADBEEF00000000000000000000000000000000000000000000000000000000
        );
        vm.expectRevert("Index out of bounds");
        target.getByteAt(data, 32);
    }
}
