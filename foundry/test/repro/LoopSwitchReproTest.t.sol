// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

interface ILoopSwitchRepro {
    function processData(bytes calldata input) external view returns (uint256);
}

contract LoopSwitchReproTest is Test {
    address public sut;

    function setUp() public {
        // Load transpiled runtime bytecode
        bytes memory bytecode = vm.readFileBinary(
            "output/LoopSwitchRepro_opt_runtime.bin"
        );

        // Deploy directly using etch (puts bytecode at fixed address)
        sut = address(0x8888);
        vm.etch(sut, bytecode);
    }

    function test_basicProcessing() public view {
        // The Solidity contract does:
        // uint256 raw = uint256(bytes32(input[offset:offset + 32]));
        // data.field1 = uint8(raw >> 248);       // top byte
        // data.field2 = address(uint160(raw >> 88));  // next 20 bytes (after shifting off bottom 11 bytes)
        // data.field3 = raw & 0xFFFFFFFF;       // bottom 4 bytes

        // field1 = 1, field2 = 0x1234, field3 = 42
        bytes32 raw = bytes32(
            (uint256(1) << 248) | // field1 in top byte
                (uint256(0x1234) << 32) | // field2 shifted left by 4 bytes (32 bits)
                uint256(42) // field3 in bottom 4 bytes
        );

        bytes memory padded = abi.encodePacked(raw);

        uint256 result = ILoopSwitchRepro(sut).processData(padded);

        // When field1 == 1, we take the else-if branch:
        // total += data.field3 (42)
        // then total += data.field1 (1)
        // = 43
        assertEq(result, 43);
    }
}
