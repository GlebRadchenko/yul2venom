// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

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
    function test_processStructs_solc_ref() public {
        bytes memory code = vm.readFileBinary(
            "yul2venom/output/LoopCheckCalldata_solc_runtime.bin"
        );
        address target = address(0xDEAD);
        vm.etch(target, code);

        ILoopCheckCalldata.Element[]
            memory input = new ILoopCheckCalldata.Element[](2);
        input[0] = ILoopCheckCalldata.Element({id: 10, value: 100});
        input[1] = ILoopCheckCalldata.Element({id: 20, value: 200});

        ILoopCheckCalldata.Element[] memory output = ILoopCheckCalldata(target)
            .processStructs(input);

        assertEq(output.length, 2, "Length");
        assertEq(output[0].id, 10, "id0");
        assertEq(output[0].value, 101, "value0");
        assertEq(output[1].id, 20, "id1");
        assertEq(output[1].value, 201, "value1");
    }
}
