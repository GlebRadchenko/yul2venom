// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

contract DebugLoopCheckTest is Test {
    ILoopCheckCalldata loopCheck;

    function setUp() public {
        address target = address(0x10092);
        bytes memory code = vm.readFileBinary(
            "../output/LoopCheckCalldata_opt_runtime.bin"
        );
        vm.etch(target, code);
        loopCheck = ILoopCheckCalldata(target);
    }

    function test_debugReturnData() public {
        ILoopCheckCalldata.Element[]
            memory input = new ILoopCheckCalldata.Element[](2);
        input[0] = ILoopCheckCalldata.Element({id: 10, value: 100});
        input[1] = ILoopCheckCalldata.Element({id: 20, value: 200});

        // Call and capture raw return data
        (bool success, bytes memory data) = address(loopCheck).staticcall(
            abi.encodeCall(loopCheck.processStructs, (input))
        );

        assertTrue(success, "Call failed");

        console.log("Return data length:", data.length);

        // Decode as raw words
        uint256 numWords = data.length / 32;
        for (uint256 i = 0; i < numWords; i++) {
            uint256 word;
            assembly {
                word := mload(add(add(data, 32), mul(i, 32)))
            }
            console.log("Word", i, ":", word);
        }
    }
}
