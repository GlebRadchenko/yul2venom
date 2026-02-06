// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

struct Element {
    uint256 id;
    uint256 value;
}

contract LoopDebugTest is Test {
    address deployed;

    function setUp() public {
        bytes memory bytecode = vm.readFileBinary(
            "../output/LoopCheckCalldata_opt.bin"
        );
        address addr;
        assembly {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        require(addr != address(0), "Deployment failed");
        deployed = addr;
    }

    function test_debugRawReturn() public {
        // Create input
        Element[] memory input = new Element[](2);
        input[0] = Element({id: 10, value: 100});
        input[1] = Element({id: 20, value: 200});

        bytes memory callData = abi.encodeWithSignature(
            "processStructs((uint256,uint256)[])",
            input
        );

        (bool success, bytes memory returnData) = deployed.call(callData);
        require(success, "Call failed");

        console.log("Return data length:", returnData.length);

        // Print raw return data in 32-byte chunks
        for (uint i = 0; i < returnData.length && i < 256; i += 32) {
            uint256 value;
            assembly {
                value := mload(add(add(returnData, 32), i))
            }
            console.log("  Offset", i, ":", value);
        }

        // Decode and check
        (Element[] memory output) = abi.decode(returnData, (Element[]));
        console.log("Decoded length:", output.length);
        console.log("output[0].id:", output[0].id);
        console.log("output[0].value:", output[0].value);
        if (output.length > 1) {
            console.log("output[1].id:", output[1].id);
            console.log("output[1].value:", output[1].value);
        }
    }
}
