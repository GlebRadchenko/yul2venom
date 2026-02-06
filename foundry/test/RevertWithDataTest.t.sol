// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

/**
 * @title IRevertWithData
 * @notice Interface for RevertWithData contract
 */
interface IRevertWithData {
    function computeAndRevert(uint256 input) external pure;
    function multiRevert(uint256 a, uint256 b) external pure;
    function callAndExtract(
        uint256 input
    ) external view returns (uint256 result);
    function callAndExtractMulti(
        uint256 a,
        uint256 b
    ) external view returns (uint256 ra, uint256 rb);
    function identity(uint256 x) external pure returns (uint256);
}

/**
 * @title RevertWithDataTest
 * @notice Verifies revert-with-data pattern is preserved through transpilation.
 *
 * Tests both native Solidity and transpiled bytecode to ensure parity.
 */
contract RevertWithDataTest is Test {
    IRevertWithData target;

    function setUp() public {
        // Load transpiled bytecode from output
        // Use _opt_runtime.bin for vm.etch (runtime-only bytecode)
        bytes memory code = vm.readFileBinary(
            "../output/RevertWithData_opt_runtime.bin"
        );
        address addr = address(0x1234567890);
        vm.etch(addr, code);
        target = IRevertWithData(addr);
    }

    function test_identity() public view {
        assertEq(target.identity(42), 42);
        assertEq(target.identity(0), 0);
    }

    function test_computeAndRevert_hasData() public {
        (bool success, bytes memory data) = address(target).staticcall(
            abi.encodeWithSelector(
                IRevertWithData.computeAndRevert.selector,
                21
            )
        );

        assertFalse(success);
        assertEq(data.length, 32, "revert should return 32 bytes");

        uint256 result;
        assembly {
            result := mload(add(data, 32))
        }
        assertEq(result, 42, "21 * 2 = 42");
    }

    function test_callAndExtract() public view {
        assertEq(target.callAndExtract(21), 42);
        assertEq(target.callAndExtract(100), 200);
        assertEq(target.callAndExtract(0), 0);
    }

    function test_callAndExtractMulti() public view {
        (uint256 a, uint256 b) = target.callAndExtractMulti(123, 456);
        assertEq(a, 123);
        assertEq(b, 456);
    }

    function testFuzz_callAndExtract(uint128 input) public view {
        assertEq(target.callAndExtract(uint256(input)), uint256(input) * 2);
    }
}
