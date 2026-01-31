// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";

interface ILoopCheckCalldata {
    struct Element {
        uint256 id;
        uint256 value;
    }
    function processStructs(
        Element[] calldata input
    ) external pure returns (Element[] memory output);
}

contract NativeLoopCheckTest is Test {
    function test_nativeVersion() public {
        bytes memory code = vm.readFileBinary(
            "yul2venom/output_native/LoopCheckCalldata_runtime.bin"
        );
        address addr = address(0x10095);
        vm.etch(addr, code);
        ILoopCheckCalldata loopCheck = ILoopCheckCalldata(addr);

        ILoopCheckCalldata.Element[]
            memory input = new ILoopCheckCalldata.Element[](2);
        input[0] = ILoopCheckCalldata.Element({id: 10, value: 100});
        input[1] = ILoopCheckCalldata.Element({id: 20, value: 200});

        ILoopCheckCalldata.Element[] memory output = loopCheck.processStructs(
            input
        );

        assertEq(output.length, 2);
        assertEq(output[0].id, 10);
        assertEq(output[0].value, 101);
        assertEq(output[1].id, 20);
        assertEq(output[1].value, 201);
    }
}
