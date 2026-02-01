// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/bench/SoladyToken.sol";

/**
 * @title SoladyTokenTest
 * @dev Test contract for SoladyToken with bytecode injection support.
 *      Supports BYTECODE_PATH env var for testing different bytecode versions.
 *
 * Usage:
 *   # Test with default path (../output/SoladyToken_opt.bin)
 *   forge test --match-contract SoladyTokenTest
 *
 *   # Test with custom bytecode path
 *   BYTECODE_PATH="path/to/bytecode.bin" forge test --match-contract SoladyTokenTest
 *
 *   # Test with native Solc (no injection)
 *   BYTECODE_PATH="" forge test --match-contract SoladyTokenTest
 */
contract SoladyTokenTest is Test {
    SoladyToken token;
    address tokenAddr;

    address owner;
    address alice = address(0xA11CE);
    address bob = address(0xB0B);
    address charlie = address(0xC4A71E);

    function setUp() public {
        owner = address(this);

        // Check for custom bytecode path, default to transpiled output
        string memory bytecodePath = vm.envOr(
            "BYTECODE_PATH",
            string("../output/SoladyToken_opt.bin")
        );

        if (bytes(bytecodePath).length > 0) {
            // Inject bytecode from file
            try vm.readFileBinary(bytecodePath) returns (bytes memory code) {
                tokenAddr = address(0x1111);
                vm.etch(tokenAddr, code);
                token = SoladyToken(tokenAddr);

                // Initialize storage for the token (name, symbol, decimals, owner)
                // Slot 0: _name (string)
                // Slot 1: _symbol (string)
                // Slot 2: _decimals (uint8)
                // Slot 3: owner (address)

                // Solidity short-string format (for strings <= 31 bytes):
                // - String data is LEFT-aligned (starts at high byte)
                // - Length * 2 is stored in the LOWEST byte

                // _name = "SoladyToken" (11 chars = 0x16 length*2)
                // "SoladyToken" in hex = 536f6c616479546f6b656e (22 hex chars = 11 bytes)
                // Pad to 31 bytes, then length byte = 0x16 (11*2 = 22) in lowest byte
                // Total = 32 bytes = 64 hex chars
                vm.store(
                    tokenAddr,
                    bytes32(uint256(0)),
                    hex"536f6c616479546f6b656e000000000000000000000000000000000000000016"
                );

                // _symbol = "STK" (3 chars = 0x06 length*2)
                // "STK" in hex = 53544b (6 hex chars = 3 bytes)
                vm.store(
                    tokenAddr,
                    bytes32(uint256(1)),
                    hex"53544b0000000000000000000000000000000000000000000000000000000006"
                );

                // Slot 2 is PACKED: low 8 bits = decimals, bits 8-167 = owner address
                // The Yul reads owner as: and(shr(8, sload(0x02)), sub(shl(160, 1), 1))
                // So we need to store: (owner << 8) | decimals
                // decimals = 18 = 0x12
                // owner = address(this) shifted left by 8 bits
                bytes32 packedSlot2 = bytes32(
                    (uint256(uint160(owner)) << 8) | uint256(18)
                );
                vm.store(tokenAddr, bytes32(uint256(2)), packedSlot2);
            } catch {
                // Fallback to native Solc contract
                token = new SoladyToken("SoladyToken", "STK", 18);
                tokenAddr = address(token);
            }
        } else {
            // Empty path = use native Solc contract
            token = new SoladyToken("SoladyToken", "STK", 18);
            tokenAddr = address(token);
        }
    }

    // ========== Metadata ==========

    function test_name() public view {
        assertEq(token.name(), "SoladyToken");
    }

    function test_symbol() public view {
        assertEq(token.symbol(), "STK");
    }

    function test_decimals() public view {
        assertEq(token.decimals(), 18);
    }

    // ========== Minting ==========

    function test_mint() public {
        token.mint(alice, 1000 ether);
        assertEq(token.balanceOf(alice), 1000 ether);
        assertEq(token.totalSupply(), 1000 ether);
    }

    function test_mint_multiple() public {
        token.mint(alice, 100 ether);
        token.mint(bob, 200 ether);
        token.mint(charlie, 300 ether);

        assertEq(token.balanceOf(alice), 100 ether);
        assertEq(token.balanceOf(bob), 200 ether);
        assertEq(token.balanceOf(charlie), 300 ether);
        assertEq(token.totalSupply(), 600 ether);
    }

    function test_mintBatch() public {
        address[] memory recipients = new address[](3);
        recipients[0] = alice;
        recipients[1] = bob;
        recipients[2] = charlie;

        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 100 ether;
        amounts[1] = 200 ether;
        amounts[2] = 300 ether;

        token.mintBatch(recipients, amounts);

        assertEq(token.balanceOf(alice), 100 ether);
        assertEq(token.balanceOf(bob), 200 ether);
        assertEq(token.balanceOf(charlie), 300 ether);
    }

    // ========== Transfer ==========

    function test_transfer() public {
        token.mint(alice, 1000 ether);

        vm.prank(alice);
        token.transfer(bob, 100 ether);

        assertEq(token.balanceOf(alice), 900 ether);
        assertEq(token.balanceOf(bob), 100 ether);
    }

    function test_transfer_toSelf() public {
        token.mint(alice, 1000 ether);

        vm.prank(alice);
        token.transfer(alice, 100 ether);

        assertEq(token.balanceOf(alice), 1000 ether);
    }

    function test_safeTransfer() public {
        token.mint(alice, 1000 ether);

        vm.prank(alice);
        bool success = token.safeTransfer(bob, 100 ether);

        assertTrue(success);
        assertEq(token.balanceOf(bob), 100 ether);
    }

    // ========== Approve & TransferFrom ==========

    function test_approve() public {
        vm.prank(alice);
        token.approve(bob, 500 ether);

        assertEq(token.allowance(alice, bob), 500 ether);
    }

    function test_transferFrom() public {
        token.mint(alice, 1000 ether);

        vm.prank(alice);
        token.approve(bob, 500 ether);

        vm.prank(bob);
        token.transferFrom(alice, charlie, 200 ether);

        assertEq(token.balanceOf(alice), 800 ether);
        assertEq(token.balanceOf(charlie), 200 ether);
        assertEq(token.allowance(alice, bob), 300 ether);
    }

    function test_safeTransferFrom() public {
        token.mint(alice, 1000 ether);

        vm.prank(alice);
        token.approve(bob, 500 ether);

        vm.prank(bob);
        bool success = token.safeTransferFrom(alice, charlie, 200 ether);

        assertTrue(success);
        assertEq(token.balanceOf(charlie), 200 ether);
    }

    // ========== Burning ==========

    function test_burn() public {
        token.mint(alice, 1000 ether);

        vm.prank(alice);
        token.burn(300 ether);

        assertEq(token.balanceOf(alice), 700 ether);
        assertEq(token.totalSupply(), 700 ether);
    }

    function test_burnFrom() public {
        token.mint(alice, 1000 ether);

        vm.prank(alice);
        token.approve(bob, 500 ether);

        vm.prank(bob);
        token.burnFrom(alice, 200 ether);

        assertEq(token.balanceOf(alice), 800 ether);
        assertEq(token.allowance(alice, bob), 300 ether);
    }

    // ========== Edge Cases ==========

    function test_transfer_zero() public {
        token.mint(alice, 1000 ether);

        vm.prank(alice);
        token.transfer(bob, 0);

        assertEq(token.balanceOf(alice), 1000 ether);
        assertEq(token.balanceOf(bob), 0);
    }

    function test_approve_overwrite() public {
        vm.prank(alice);
        token.approve(bob, 500 ether);

        vm.prank(alice);
        token.approve(bob, 100 ether);

        assertEq(token.allowance(alice, bob), 100 ether);
    }

    function test_totalSupply_afterOperations() public {
        assertEq(token.totalSupply(), 0);

        token.mint(alice, 1000 ether);
        assertEq(token.totalSupply(), 1000 ether);

        token.mint(bob, 500 ether);
        assertEq(token.totalSupply(), 1500 ether);

        vm.prank(alice);
        token.burn(200 ether);
        assertEq(token.totalSupply(), 1300 ether);
    }
}
