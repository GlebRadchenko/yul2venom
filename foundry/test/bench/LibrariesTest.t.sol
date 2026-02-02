// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/bench/Libraries.sol";

/**
 * @title LibrariesTest
 * @dev Tests for library patterns with `using X for Y` syntax.
 *
 * Tests cover:
 *   - SafeMath library (add, sub, mul, div, mod)
 *   - StringUtils library (length, isEmpty, equals)
 *   - AddressUtils library (isContract, toBytes)
 *   - ArrayUtils library (sum, max, min, contains)
 *   - Chained library calls
 *   - State-modifying with library
 */
contract LibrariesTest is Test {
    Libraries target;
    address payable targetAddr;

    function setUp() public {
        string memory bytecodePath = vm.envOr(
            "BYTECODE_PATH",
            string("../output/Libraries_opt_runtime.bin")
        );

        if (bytes(bytecodePath).length > 0) {
            try vm.readFileBinary(bytecodePath) returns (bytes memory code) {
                targetAddr = payable(address(0x8888));
                vm.etch(targetAddr, code);
                target = Libraries(targetAddr);
            } catch {
                target = new Libraries();
                targetAddr = payable(address(target));
            }
        } else {
            target = new Libraries();
            targetAddr = payable(address(target));
        }
    }

    // ========== SafeMath Tests ==========

    function test_add() public view {
        assertEq(target.testAdd(10, 20), 30);
    }

    function test_add_zero() public view {
        assertEq(target.testAdd(0, 100), 100);
        assertEq(target.testAdd(100, 0), 100);
    }

    function test_sub() public view {
        assertEq(target.testSub(100, 30), 70);
    }

    function test_sub_toZero() public view {
        assertEq(target.testSub(50, 50), 0);
    }

    function test_sub_underflow() public {
        vm.expectRevert("SafeMath: subtraction underflow");
        target.testSub(10, 20);
    }

    function test_mul() public view {
        assertEq(target.testMul(7, 8), 56);
    }

    function test_mul_byZero() public view {
        assertEq(target.testMul(1000, 0), 0);
        assertEq(target.testMul(0, 1000), 0);
    }

    function test_mul_byOne() public view {
        assertEq(target.testMul(42, 1), 42);
    }

    function test_div() public view {
        assertEq(target.testDiv(100, 5), 20);
    }

    function test_div_byZero() public {
        vm.expectRevert("SafeMath: division by zero");
        target.testDiv(100, 0);
    }

    function test_mod() public view {
        assertEq(target.testMod(17, 5), 2);
    }

    function test_mod_byZero() public {
        vm.expectRevert("SafeMath: modulo by zero");
        target.testMod(17, 0);
    }

    // ========== Chained Math ==========

    function test_chainedMath() public view {
        // a + b * c = 10 + 5 * 3 = 25
        assertEq(target.testChainedMath(10, 5, 3), 25);
    }

    function test_complexMath() public view {
        // (x + 10) * 2 - 5 = (20 + 10) * 2 - 5 = 55
        assertEq(target.testComplexMath(20), 55);
    }

    // ========== StringUtils Tests ==========

    function test_stringLength() public view {
        assertEq(target.testStringLength("hello"), 5);
        assertEq(target.testStringLength(""), 0);
        assertEq(target.testStringLength("a"), 1);
    }

    function test_stringEmpty() public view {
        assertTrue(target.testStringEmpty(""));
        assertFalse(target.testStringEmpty("x"));
    }

    function test_stringEquals() public view {
        assertTrue(target.testStringEquals("abc", "abc"));
        assertFalse(target.testStringEquals("abc", "ABC"));
        assertFalse(target.testStringEquals("abc", "abcd"));
    }

    // ========== AddressUtils Tests ==========

    function test_isContract() public view {
        // The target itself is a contract
        assertTrue(target.testIsContract(targetAddr));
        // EOA is not a contract
        assertFalse(target.testIsContract(address(0x1234)));
    }

    function test_addressToBytes() public view {
        address testAddr = address(0xABCD);
        bytes memory result = target.testAddressToBytes(testAddr);
        assertEq(result.length, 20);
    }

    // ========== ArrayUtils Tests ==========

    function test_arraySum() public view {
        uint256[] memory arr = new uint256[](3);
        arr[0] = 10;
        arr[1] = 20;
        arr[2] = 30;
        assertEq(target.testArraySum(arr), 60);
    }

    function test_arraySum_empty() public view {
        uint256[] memory arr = new uint256[](0);
        assertEq(target.testArraySum(arr), 0);
    }

    function test_arrayMax() public view {
        uint256[] memory arr = new uint256[](4);
        arr[0] = 5;
        arr[1] = 100;
        arr[2] = 3;
        arr[3] = 50;
        assertEq(target.testArrayMax(arr), 100);
    }

    function test_arrayMin() public view {
        uint256[] memory arr = new uint256[](4);
        arr[0] = 50;
        arr[1] = 3;
        arr[2] = 100;
        arr[3] = 5;
        assertEq(target.testArrayMin(arr), 3);
    }

    function test_arrayContains() public view {
        uint256[] memory arr = new uint256[](3);
        arr[0] = 10;
        arr[1] = 20;
        arr[2] = 30;
        assertTrue(target.testArrayContains(arr, 20));
        assertFalse(target.testArrayContains(arr, 25));
    }

    // ========== State-Modifying with Library ==========

    function test_incrementBy() public {
        target.setStoredValue(100);
        assertEq(target.incrementBy(50), 150);
        assertEq(target.getStoredValue(), 150);
    }

    function test_decrementBy() public {
        target.setStoredValue(100);
        assertEq(target.decrementBy(30), 70);
        assertEq(target.getStoredValue(), 70);
    }

    function test_multiplyBy() public {
        target.setStoredValue(10);
        assertEq(target.multiplyBy(5), 50);
        assertEq(target.getStoredValue(), 50);
    }

    // ========== Mixed Library Usage ==========

    function test_processData() public view {
        uint256[] memory arr = new uint256[](3);
        arr[0] = 10;
        arr[1] = 20;
        arr[2] = 30;

        (uint256 total, uint256 maxVal, uint256 minVal) = target.processData(
            arr,
            2
        );

        // sum = 60, * 2 = 120
        assertEq(total, 120);
        assertEq(maxVal, 30);
        assertEq(minVal, 10);
    }

    // ========== Direct Library Call ==========

    function test_directLibraryCall() public view {
        assertEq(target.directLibraryCall(15, 25), 40);
    }
}
