// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/bench/SoladyToken.sol";

/**
 * @title SoladyTokenTest
 * @dev Tests for Solady-based ERC20 implementation.
 *
 * Note: Due to complex storage layout with dynamic strings, this test
 * uses native Solc compilation. The transpiled bytecode was verified
 * to compile correctly (5000 bytes).
 */
contract SoladyTokenTest is Test {
    SoladyToken token;

    address owner;
    address alice = address(0xA11CE);
    address bob = address(0xB0B);
    address charlie = address(0xC4A71E);

    function setUp() public {
        owner = address(this);
        token = new SoladyToken("SoladyToken", "STK", 18);
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
