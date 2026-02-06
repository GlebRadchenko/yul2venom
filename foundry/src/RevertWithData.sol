// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title RevertWithData
 * @notice Tests revert-with-data pattern: revert(ptr, size) with actual data.
 *
 * This pattern passes computed values back to caller via revert data.
 * The transpiler MUST preserve:
 * 1. revert(ptr, N) - revert with N bytes of data (any N, including 0)
 * 2. The memory content at ptr before revert
 * 3. Caller's ability to extract data via returndatacopy
 */
contract RevertWithData {
    /// @notice Reverts with computed value as raw bytes
    function computeAndRevert(uint256 input) external pure {
        uint256 result = input * 2;

        /// @solidity memory-safe-assembly
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, result)
            revert(ptr, 32)
        }
    }

    /// @notice Reverts with multiple values packed
    function multiRevert(uint256 a, uint256 b) external pure {
        /// @solidity memory-safe-assembly
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, a)
            mstore(add(ptr, 32), b)
            revert(ptr, 64)
        }
    }

    /// @notice Calls computeAndRevert and extracts result from revert data
    function callAndExtract(
        uint256 input
    ) external view returns (uint256 result) {
        (bool success, bytes memory data) = address(this).staticcall(
            abi.encodeWithSelector(this.computeAndRevert.selector, input)
        );

        require(!success, "expected revert");
        require(data.length >= 32, "short data");

        assembly ("memory-safe") {
            result := mload(add(data, 32))
        }
    }

    /// @notice Extracts multiple values from revert data
    function callAndExtractMulti(
        uint256 a,
        uint256 b
    ) external view returns (uint256 ra, uint256 rb) {
        (bool success, bytes memory data) = address(this).staticcall(
            abi.encodeWithSelector(this.multiRevert.selector, a, b)
        );

        require(!success, "expected revert");
        require(data.length >= 64, "short data");

        assembly ("memory-safe") {
            ra := mload(add(data, 32))
            rb := mload(add(data, 64))
        }
    }

    /// @notice Simple identity for basic verification
    function identity(uint256 x) external pure returns (uint256) {
        return x;
    }
}
