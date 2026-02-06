// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title LoopSwitchRepro
 * @notice Minimal reproduction for "Variable not in stack" bug
 *
 * Pattern that triggers the bug:
 * 1. Loop body allocates memory (mload 64)
 * 2. Switch/if statement branches from the allocation
 * 3. Variable used after the switch merge point
 * 4. SSA renaming creates %var:1 which crosses merge without phi
 */
contract LoopSwitchRepro {
    struct Data {
        uint8 field1;
        address field2;
        uint256 field3;
    }

    // This function reproduces a pattern that triggers SSA renaming issues
    function processData(bytes calldata input) external pure returns (uint256) {
        uint256 total = 0;
        uint256 offset = 0;

        // Loop with memory allocation + switch pattern
        while (offset < input.length) {
            // Allocate memory for struct (like %1827 = mload 64)
            Data memory data;

            // Read from calldata
            uint256 raw = uint256(bytes32(input[offset:offset + 32]));

            // Parse struct fields
            data.field1 = uint8(raw >> 248);
            data.field2 = address(uint160(raw >> 88));
            data.field3 = raw & 0xFFFFFFFF;

            // Switch-like pattern - the bug happens when variable crosses this
            if (data.field1 == 0) {
                // Case 0: use data.field2
                total += uint160(data.field2);
            } else if (data.field1 == 1) {
                // Case 1: use data.field3
                total += data.field3;
            } else {
                // Default: use field1
                total += data.field1;
            }

            // Use memory pointer AFTER the switch (this triggers the bug)
            // data is the memory pointer that becomes unavailable
            total += data.field1;

            offset += 32;
        }

        return total;
    }
}
