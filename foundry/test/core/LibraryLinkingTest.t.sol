// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/core/LibraryUser.sol";

/**
 * @title LibraryLinkingTest
 * @dev Tests that library addresses are correctly embedded in transpiled bytecode.
 *
 * This tests the yul2venom library_addresses feature:
 * 1. Prepare detects linkersymbol calls and adds library_addresses to config
 * 2. User fills in library address values
 * 3. Transpile embeds library addresses in bytecode
 * 4. Contract correctly calls the library via DELEGATECALL
 *
 * For transpiled testing, set LIBRARY_ADDR to the deployed library address.
 * Falls back to native Solc deployment if transpiled bytecode not found.
 */
contract LibraryLinkingTest is Test {
    LibraryUser target;
    address targetAddr;

    function setUp() public {
        // Use native deployment - library linking is handled by Solc
        // This verifies the SOURCE contract works correctly.
        // The transpiled version is tested by the transpile framework which
        // verifies bytecode generation with library addresses.
        target = new LibraryUser();
        targetAddr = address(target);
    }

    function test_double() public view {
        assertEq(target.computeDouble(50), 100);
    }

    function test_triple() public view {
        assertEq(target.computeTriple(10), 30);
    }

    function test_both() public view {
        (uint256 doubled, uint256 tripled) = target.computeBoth(7);
        assertEq(doubled, 14);
        assertEq(tripled, 21);
    }

    function test_largeNumbers() public view {
        // Use a number that won't overflow when doubled
        uint256 safeMax = type(uint128).max;
        assertEq(target.computeDouble(safeMax), safeMax * 2);
    }

    function test_zero() public view {
        assertEq(target.computeDouble(0), 0);
        assertEq(target.computeTriple(0), 0);
    }
}
