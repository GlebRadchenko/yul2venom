// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CallOrderRepro {
    function readBalance(address token, address account) external view returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly ("memory-safe") {
            mstore(0x14, account)
            mstore(0x00, shl(96, 0x70a08231))
            amount := mul(mload(0x20), and(gt(returndatasize(), 0x1f), staticcall(gas(), token, 0x10, 0x24, 0x20, 0x20)))
        }
    }
}

