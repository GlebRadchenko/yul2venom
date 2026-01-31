// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

interface ILoopCheckCalldata {
    struct Element {
        uint256 id;
        uint256 value;
    }
    function processStructs(
        Element[] calldata input
    ) external pure returns (Element[] memory output);
}

contract SolcRefTest is Test {
    ILoopCheckCalldata target;

    function setUp() public {
        try
            vm.readFileBinary(
                "yul2venom/output/LoopCheckCalldata_solc_runtime.bin"
            )
        returns (bytes memory code) {
            address addr = address(0xDEAD);
            vm.etch(addr, code);
            target = ILoopCheckCalldata(addr);
        } catch {
            console.log("Skipping SolcRefTest - solc binary not found");
        }
    }

    function test_processStructs_solc_ref() public {
        if (address(target) == address(0)) return;

        ILoopCheckCalldata.Element[]
            memory input = new ILoopCheckCalldata.Element[](2);
        input[0] = ILoopCheckCalldata.Element({id: 10, value: 100});
        input[1] = ILoopCheckCalldata.Element({id: 20, value: 200});

        ILoopCheckCalldata.Element[] memory output = target.processStructs(
            input
        );

        assertEq(output.length, 2, "Length");
        assertEq(output[0].id, 10, "id0");
        assertEq(output[0].value, 101, "value0");
        assertEq(output[1].id, 20, "id1");
        assertEq(output[1].value, 201, "value1");
    }
}
