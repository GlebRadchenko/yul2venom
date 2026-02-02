// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/bench/Functions.sol";

/**
 * @title FunctionsTest
 * @dev Benchmark test for Functions contract with bytecode injection support.
 *
 * Usage:
 *   # Test with default path
 *   forge test --match-contract FunctionsTest
 *
 *   # Test with custom bytecode
 *   BYTECODE_PATH="path/to/bytecode.bin" forge test --match-contract FunctionsTest
 *
 *   # Test with native Solc (no injection)
 *   BYTECODE_PATH="" forge test --match-contract FunctionsTest
 */
contract FunctionsTest is Test {
    Functions target;
    address payable targetAddr;

    function setUp() public {
        string memory bytecodePath = vm.envOr(
            "BYTECODE_PATH",
            string("../output/Functions_opt_runtime.bin")
        );

        if (bytes(bytecodePath).length > 0) {
            try vm.readFileBinary(bytecodePath) returns (bytes memory code) {
                targetAddr = payable(address(0x5555));
                vm.etch(targetAddr, code);
                target = Functions(targetAddr);
            } catch {
                target = new Functions();
                targetAddr = payable(address(target));
            }
        } else {
            target = new Functions();
            targetAddr = payable(address(target));
        }
    }

    // ========== Simple Returns ==========
    function test_returnSingle() public view {
        assertEq(target.returnSingle(), 42);
    }

    function test_returnMultiple() public view {
        (uint256 a, uint256 b, uint256 c) = target.returnMultiple();
        assertEq(a, 1);
        assertEq(b, 2);
        assertEq(c, 3);
    }

    function test_returnNothing() public view {
        target.returnNothing();
    }

    // ========== Interface ==========
    function test_interfaceFunc() public view {
        assertEq(target.interfaceFunc(), 999);
    }

    // ========== Diamond Inheritance ==========
    function test_virtualA() public view {
        assertEq(target.callVirtualA(), 111); // 100 + 10 + 1
    }

    function test_virtualB() public view {
        assertEq(target.callVirtualB(), 222); // 200 + 20 + 2
    }

    // ========== Internal Calls ==========
    function test_callInternal() public view {
        assertEq(target.callInternal(10, 20), 30);
    }

    function test_nestedInternal() public view {
        // _level3(5) = 15, _level2(5) = 30, _level1(5) = 31
        assertEq(target.nestedInternal(5), 31);
    }

    // ========== Recursion ==========
    function test_factorial() public view {
        assertEq(target.factorial(0), 1);
        assertEq(target.factorial(5), 120);
        assertEq(target.factorial(10), 3628800);
    }

    function test_fibonacci() public view {
        assertEq(target.fibonacci(0), 0);
        assertEq(target.fibonacci(1), 1);
        assertEq(target.fibonacci(10), 55);
    }

    // ========== External Self-Call ==========
    function test_callSelf() public view {
        assertEq(target.callSelf(100, 200), 300);
    }
}
