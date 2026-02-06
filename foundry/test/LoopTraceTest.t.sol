// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

struct Element {
    uint256 id;
    uint256 value;
}

contract LoopTraceTest is Test {
    function test_traceBytes() public {
        // Load transpiled bytecode
        bytes memory bytecode = vm.readFileBinary(
            "../output/LoopCheckCalldata_opt.bin"
        );
        address deployed;
        assembly {
            deployed := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        require(deployed != address(0), "Deployment failed");

        // Create input
        Element[] memory input = new Element[](2);
        input[0] = Element({id: 10, value: 100});
        input[1] = Element({id: 20, value: 200});

        // Call with vm.expectCall to trace
        vm.recordLogs();
        (bool success, bytes memory returnData) = deployed.call(
            abi.encodeWithSignature(
                "processStructs((uint256,uint256)[])",
                input
            )
        );
        require(success, "Call failed");

        console.log("=== Return Data Analysis ===");
        console.log("Length:", returnData.length);

        // Expected layout:
        // [0]: 32 (offset to array)
        // [32]: 2 (length)
        // [64]: 10 (output[0].id) - correct
        // [96]: 101 (output[0].value) - correct
        // [128]: 20 (output[1].id) - WRONG: we get 32
        // [160]: 201 (output[1].value) - WRONG: we get 2

        for (uint i = 0; i < returnData.length && i < 256; i += 32) {
            uint256 val;
            assembly {
                val := mload(add(add(returnData, 32), i))
            }

            string memory expected;
            if (i == 0) expected = "ABI offset (expect 32)";
            else if (i == 32) expected = "Array length (expect 2)";
            else if (i == 64) expected = "output[0].id (expect 10)";
            else if (i == 96) expected = "output[0].value (expect 101)";
            else if (i == 128) expected = "output[1].id (expect 20)";
            else if (i == 160) expected = "output[1].value (expect 201)";
            else expected = "extra";

            console.log(expected);
        }

        // Decode properly
        Element[] memory output = abi.decode(returnData, (Element[]));

        console.log("\n=== Decoded Output ===");
        console.log("Length:", output.length);
        for (uint i = 0; i < output.length; i++) {
            console.log("output[", i, "].id:", output[i].id);
            console.log("output[", i, "].value:", output[i].value);
        }

        // The key insight: output[1].id = 32 and output[1].value = 2
        // These are EXACTLY the values at offset 0 and offset 32 in the return buffer!
        // This means on iteration 2, mload(srcPtr) is reading from memPos (return buffer)
        // instead of from the actual source array.
        //
        // This can only happen if:
        // 1. srcPtr didn't increment (still at memPtr+32 on iter 2) - unlikely, the IR shows add
        // 2. srcPtr incremented but to wrong value (e.g., memPos instead of memPtr+64)
        // 3. The mload is reading from wrong register due to stack misalignment

        assertEq(output[0].id, 10, "output[0].id wrong");
        assertEq(output[0].value, 101, "output[0].value wrong");
        assertEq(output[1].id, 20, "output[1].id wrong");
        assertEq(output[1].value, 201, "output[1].value wrong");
    }
}
