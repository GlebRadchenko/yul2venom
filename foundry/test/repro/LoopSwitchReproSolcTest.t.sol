// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/repro/LoopSwitchRepro.sol";

contract LoopSwitchReproSolcTest is Test {
    LoopSwitchRepro public sut;

    function setUp() public {
        sut = new LoopSwitchRepro();
    }

    function test_basicProcessing() public view {
        // The Solidity contract does:
        // uint256 raw = uint256(bytes32(input[offset:offset + 32]));
        // data.field1 = uint8(raw >> 248);       // top byte
        // data.field2 = address(uint160(raw >> 88));  // next 20 bytes (after shifting off bottom 11 bytes)
        // data.field3 = raw & 0xFFFFFFFF;       // bottom 4 bytes

        // So the layout should be:
        // [field1: 1 byte][padding: 7 bytes][field2: 20 bytes][field3: 4 bytes]
        // = 32 bytes total

        // field1 = 1, field2 = 0x1234, field3 = 42
        // raw = 0x01_00000000000000_0000000000000000000000001234_0000002a
        //       ^1 byte            ^7 bytes padding        ^20 bytes          ^4 bytes

        bytes32 raw = bytes32(
            (uint256(1) << 248) | // field1 in top byte
                (uint256(0x1234) << 32) | // field2 shifted left by 4 bytes (32 bits)
                uint256(42) // field3 in bottom 4 bytes
        );

        bytes memory padded = abi.encodePacked(raw);

        uint256 result = sut.processData(padded);

        // When field1 == 1, we take the else-if branch:
        // total += data.field3 (42)
        // then total += data.field1 (1)
        // = 43
        assertEq(result, 43);
    }
}
