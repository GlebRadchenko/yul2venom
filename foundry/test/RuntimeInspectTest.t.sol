// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

struct Element {
    uint256 id;
    uint256 value;
}

/**
 * This test inspects the actual mload values in the serialization loop
 * by checking memory at the addresses that SHOULD be read
 */
contract RuntimeInspectTest is Test {
    function test_inspectRuntime() public {
        // Load transpiled bytecode
        bytes memory bytecode = vm.readFileBinary(
            "../output/LoopCheckCalldata_opt.bin"
        );
        address deployed;
        assembly {
            deployed := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        require(deployed != address(0), "Deployment failed");

        // Input: 2 elements
        Element[] memory input = new Element[](2);
        input[0] = Element({id: 10, value: 100});
        input[1] = Element({id: 20, value: 200});

        // Call and capture raw return
        (bool success, bytes memory returnData) = deployed.call(
            abi.encodeWithSignature(
                "processStructs((uint256,uint256)[])",
                input
            )
        );
        require(success, "Call failed");

        console.log("=== Raw Return Data ===");
        for (uint i = 0; i < returnData.length && i < 224; i += 32) {
            uint256 val;
            assembly {
                val := mload(add(add(returnData, 32), i))
            }
            console.log("  Offset", i);
            console.log("    Value:", val);
        }

        // Decode
        Element[] memory output = abi.decode(returnData, (Element[]));
        console.log("\n=== Decoded ===");
        console.log("Length:", output.length);

        for (uint i = 0; i < output.length; i++) {
            console.log("output[", i, "]:");
            console.log("  id:", output[i].id);
            console.log("  value:", output[i].value);
        }

        // The bug: output[1].id = 32, output[1].value = 2
        // These are the values at retBuf offset 0 and 32 (the ABI encoding header)
        //
        // What SHOULD happen in serialization loop iteration 1:
        //   srcPtr = memPtr + 64 (pointing to output array slot 1)
        //   struct_ptr = mload(srcPtr) = address of struct1 (should be ~640+)
        //   id = mload(struct_ptr) = 20
        //
        // What IS happening:
        //   mload(srcPtr) apparently returns an address whose mload gives 32
        //   The only place 32 is stored is at memPos (return buffer header)
        //   So struct_ptr = memPos, and mload(memPos) = 32 (the ABI offset)
        //
        // This can only happen if:
        //   1. srcPtr on iter 1 points to a slot that contains memPos
        //   2. Or the stack is misaligned so mload reads wrong value

        assertEq(output[0].id, 10, "output[0].id wrong");
        assertEq(output[0].value, 101, "output[0].value wrong");
        assertEq(output[1].id, 20, "output[1].id wrong - got 32 (ABI header)!");
        assertEq(
            output[1].value,
            201,
            "output[1].value wrong - got 2 (array length)!"
        );
    }
}
