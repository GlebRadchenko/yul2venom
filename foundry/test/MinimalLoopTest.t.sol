// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";

interface IMinimalLoop {
    struct Element {
        uint256 id;
        uint256 value;
    }
    function process(
        Element[] calldata input
    ) external pure returns (uint256 id0, uint256 id1);
}

contract MinimalLoopTest is Test {
    function test_minimal() public {
        bytes memory code = vm.readFileBinary(
            "../output/MinimalLoop_opt_runtime.bin"
        );
        address addr = address(0x10094);
        vm.etch(addr, code);
        IMinimalLoop minimal = IMinimalLoop(addr);

        IMinimalLoop.Element[] memory input = new IMinimalLoop.Element[](2);
        input[0] = IMinimalLoop.Element({id: 10, value: 100});
        input[1] = IMinimalLoop.Element({id: 20, value: 200});

        (uint256 id0, uint256 id1) = minimal.process(input);

        assertEq(id0, 10, "First element id should be 10");
        assertEq(id1, 20, "Second element id should be 20");
    }
}
