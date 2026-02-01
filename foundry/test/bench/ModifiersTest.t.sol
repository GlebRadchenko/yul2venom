// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/bench/Modifiers.sol";

/**
 * @title ModifiersTest
 * @dev Comprehensive tests for function modifiers with bytecode injection support.
 *
 * Tests cover:
 *   - Basic modifiers (onlyOwner, onlyAdmin, whenNotPaused)
 *   - Modifiers with arguments (valueInRange, minValue)
 *   - Nested modifiers (noReentrancy, logged)
 *   - Multiple modifiers on single function
 *   - Edge cases and failure modes
 */
contract ModifiersTest is Test {
    Modifiers target;
    address payable targetAddr;

    address owner;
    address admin;
    address user;

    function setUp() public {
        owner = address(this);
        admin = address(0x1111);
        user = address(0x2222);

        string memory bytecodePath = vm.envOr(
            "BYTECODE_PATH",
            string("../output/Modifiers_opt.bin")
        );

        if (bytes(bytecodePath).length > 0) {
            try vm.readFileBinary(bytecodePath) returns (bytes memory code) {
                targetAddr = payable(address(0x9999));
                vm.etch(targetAddr, code);
                target = Modifiers(targetAddr);
                // Storage layout:
                // slot 0: owner (offset 0, 20 bytes) | paused (offset 20, 1 byte)
                // slot 1: counter
                // slot 2: admins mapping
                vm.store(
                    targetAddr,
                    bytes32(0),
                    bytes32(uint256(uint160(owner)))
                );
                // Set owner as admin in mapping (slot 2 + keccak256(abi.encode(owner, 2)))
                bytes32 adminSlot = keccak256(abi.encode(owner, uint256(2)));
                vm.store(targetAddr, adminSlot, bytes32(uint256(1)));
            } catch {
                target = new Modifiers();
                targetAddr = payable(address(target));
            }
        } else {
            target = new Modifiers();
            targetAddr = payable(address(target));
        }
    }

    // ========== Basic Modifier: onlyOwner ==========

    function test_setOwner_asOwner() public {
        address newOwner = address(0x3333);
        target.setOwner(newOwner);
        assertEq(target.owner(), newOwner);
    }

    function test_setOwner_notOwner() public {
        vm.prank(user);
        vm.expectRevert(Modifiers.NotOwner.selector);
        target.setOwner(user);
    }

    function test_setPaused_asOwner() public {
        target.setPaused(true);
        assertTrue(target.paused());
        target.setPaused(false);
        assertFalse(target.paused());
    }

    function test_setPaused_notOwner() public {
        vm.prank(user);
        vm.expectRevert(Modifiers.NotOwner.selector);
        target.setPaused(true);
    }

    function test_addAdmin_asOwner() public {
        target.addAdmin(admin);
        assertTrue(target.admins(admin));
    }

    function test_addAdmin_notOwner() public {
        vm.prank(user);
        vm.expectRevert(Modifiers.NotOwner.selector);
        target.addAdmin(admin);
    }

    function test_removeAdmin_asOwner() public {
        target.addAdmin(admin);
        assertTrue(target.admins(admin));
        target.removeAdmin(admin);
        assertFalse(target.admins(admin));
    }

    // ========== Basic Modifier: onlyAdmin ==========

    function test_adminAction_asAdmin() public {
        // Owner is already admin from constructor
        bool result = target.adminAction();
        assertTrue(result);
        assertEq(target.counter(), 1);
    }

    function test_adminAction_notAdmin() public {
        vm.prank(user);
        vm.expectRevert(Modifiers.NotAdmin.selector);
        target.adminAction();
    }

    // ========== Basic Modifier: whenNotPaused ==========

    function test_adminAction_whenPaused() public {
        target.setPaused(true);
        vm.expectRevert(Modifiers.Paused.selector);
        target.adminAction();
    }

    // ========== Multiple Modifiers ==========

    function test_ownerAction_asOwner() public {
        uint256 result = target.ownerAction();
        assertEq(result, 10);
        assertEq(target.counter(), 10);
    }

    function test_ownerAction_notOwner() public {
        vm.prank(user);
        vm.expectRevert(Modifiers.NotOwner.selector);
        target.ownerAction();
    }

    function test_ownerAction_whenPaused() public {
        target.setPaused(true);
        vm.expectRevert(Modifiers.Paused.selector);
        target.ownerAction();
    }

    function test_restrictedAction_fullAccess() public {
        // Owner is admin and not paused
        target.restrictedAction();
        assertEq(target.counter(), 100);
    }

    function test_restrictedAction_onlyAdminNotOwner() public {
        target.addAdmin(admin);
        vm.prank(admin);
        vm.expectRevert(Modifiers.NotOwner.selector);
        target.restrictedAction();
    }

    // ========== Modifiers with Arguments ==========

    function test_depositInRange_valid() public {
        target.depositInRange{value: 0.5 ether}();
        assertEq(target.counter(), 0.5 ether);
    }

    function test_depositInRange_tooLow() public {
        vm.expectRevert(
            abi.encodeWithSelector(Modifiers.InvalidValue.selector, 0.05 ether)
        );
        target.depositInRange{value: 0.05 ether}();
    }

    function test_depositInRange_tooHigh() public {
        vm.expectRevert(
            abi.encodeWithSelector(Modifiers.InvalidValue.selector, 2 ether)
        );
        target.depositInRange{value: 2 ether}();
    }

    function test_depositMin_valid() public {
        target.depositMin{value: 0.1 ether}();
        assertEq(target.counter(), 0.1 ether);
    }

    function test_depositMin_tooLow() public {
        vm.expectRevert("Below minimum");
        target.depositMin{value: 0.001 ether}();
    }

    // ========== Nested Modifiers (before and after _) ==========

    function test_safeIncrement() public {
        target.safeIncrement();
        assertEq(target.counter(), 1);
    }

    function test_loggedIncrement() public {
        vm.expectEmit(false, false, false, true);
        emit Modifiers.GuardTriggered("increment");

        target.loggedIncrement();

        assertEq(target.counter(), 1);
    }

    // ========== Complex: Multiple + Nested ==========

    function test_fullProtection_success() public {
        vm.expectEmit(false, false, false, true);
        emit Modifiers.GuardTriggered("full");

        target.fullProtection();

        assertEq(target.counter(), 1);
    }

    function test_fullProtection_notOwner() public {
        vm.prank(user);
        vm.expectRevert(Modifiers.NotOwner.selector);
        target.fullProtection();
    }

    function test_fullProtection_whenPaused() public {
        target.setPaused(true);
        vm.expectRevert(Modifiers.Paused.selector);
        target.fullProtection();
    }

    // ========== View Function with Modifier ==========

    function test_getCounter_asAdmin() public view {
        uint256 count = target.getCounter();
        assertEq(count, 0);
    }

    function test_getCounter_notAdmin() public {
        vm.prank(user);
        vm.expectRevert(Modifiers.NotAdmin.selector);
        target.getCounter();
    }

    // ========== No Modifier (baseline) ==========

    function test_pureAdd() public view {
        assertEq(target.pureAdd(10, 20), 30);
    }

    function test_getState() public view {
        (address o, bool p, uint256 c) = target.getState();
        assertEq(o, owner);
        assertFalse(p);
        assertEq(c, 0);
    }

    // ========== Edge Cases ==========

    function test_multipleAdminActions() public {
        target.adminAction();
        target.adminAction();
        target.adminAction();
        assertEq(target.counter(), 3);
    }

    function test_ownerTransfer() public {
        address newOwner = address(0x4444);
        target.setOwner(newOwner);

        // Original owner can't act anymore
        vm.expectRevert(Modifiers.NotOwner.selector);
        target.setOwner(owner);

        // New owner can act
        vm.prank(newOwner);
        target.setOwner(owner);
        assertEq(target.owner(), owner);
    }

    // ========== Edge Case: _ Placement ==========

    /// @notice Test _ at beginning (post-execution code only)
    function test_afterOnlyModifier() public {
        target.incrementWithAfterMod();
        // Function adds 5, then modifier adds 1000
        assertEq(target.counter(), 1005);
    }

    /// @notice Test _ in middle (code before and after)
    function test_middlePlacementModifier() public {
        target.incrementWithMiddleMod();
        // Function adds 10, modifier validates increase
        assertEq(target.counter(), 10);
    }

    /// @notice Test no _ (blocking modifier)
    function test_blockedFunction() public {
        vm.expectRevert("Blocked by modifier");
        target.blockedFunction();
        // Counter should remain 0 - function never executed
        assertEq(target.counter(), 0);
    }

    /// @notice Test conditional _ execution - should run
    function test_conditionalExec_true() public {
        target.conditionalIncrement(true);
        assertEq(target.counter(), 50);
    }

    /// @notice Test conditional _ execution - should not run
    function test_conditionalExec_false() public {
        target.conditionalIncrement(false);
        // Function body didn't execute
        assertEq(target.counter(), 0);
    }

    /// @notice Test complex wrapper with before and after code
    function test_complexWrapper() public {
        target.wrappedIncrement();
        // 100 (before) + 1 (function) + 200 (after) = 301
        assertEq(target.counter(), 301);
    }

    /// @notice Test multiple edge case modifiers stacked
    function test_multiEdgeCaseModifiers() public {
        target.multiEdgeCase();
        // middlePlacement validates increase, afterOnly adds 1000
        // 7 (function) + 1000 (afterOnly) = 1007
        assertEq(target.counter(), 1007);
    }
}
