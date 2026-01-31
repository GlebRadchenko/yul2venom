// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

struct Element {
    uint256 id;
    uint256 value;
}

contract MemoryLayoutTest is Test {
    function test_memoryLayout() public {
        // Recreate the memory layout that LoopCheckCalldata creates
        // Input: 2 elements with id=10,value=100 and id=20,value=200

        // Simulate what the transpiled code does:
        // 1. Allocate output array (memPtr)
        // 2. Allocate structs in processing loop
        // 3. Allocate return buffer (memPos)

        Element[] memory input = new Element[](2);
        input[0] = Element({id: 10, value: 100});
        input[1] = Element({id: 20, value: 200});

        // Get current free memory pointer
        uint256 initialFreePtr;
        assembly {
            initialFreePtr := mload(0x40)
        }
        console.log("Initial free ptr:", initialFreePtr);

        // After array allocation for output (length=2, each slot=32 bytes)
        // memPtr = initialFreePtr
        // newFreePtr = memPtr + 32 (length) + 2*32 (slots) = memPtr + 96
        uint256 memPtr = initialFreePtr;
        uint256 afterArrayAlloc = memPtr + 96; // 32 + 64
        console.log("memPtr (output array):", memPtr);
        console.log("memPtr + 32 (slot 0):", memPtr + 32);
        console.log("memPtr + 64 (slot 1):", memPtr + 64);
        console.log("After array alloc:", afterArrayAlloc);

        // Then for each element, allocate a 64-byte struct
        // Struct 0: afterArrayAlloc
        // Struct 1: afterArrayAlloc + 64
        uint256 struct0 = afterArrayAlloc;
        uint256 struct1 = afterArrayAlloc + 64;
        console.log("struct0 address:", struct0);
        console.log("struct1 address:", struct1);

        // After both structs, free ptr is afterArrayAlloc + 128
        uint256 afterStructs = afterArrayAlloc + 128;
        console.log("After structs:", afterStructs);

        // Now allocate return buffer (memPos = mload(64) = afterStructs)
        uint256 memPos = afterStructs;
        console.log("memPos (return buffer):", memPos);

        // srcPtr starts at memPtr + 32
        uint256 srcPtr = memPtr + 32;
        console.log("\n=== Serialization Loop ===");
        console.log("Initial srcPtr:", srcPtr);
        console.log("srcPtr[0] should point to:", struct0);
        console.log("srcPtr[1] = srcPtr + 32 =", srcPtr + 32);
        console.log("srcPtr[1] should point to:", struct1);

        // Check if there's overlap
        console.log("\n=== Memory Check ===");
        console.log("memPos:", memPos);
        console.log("memPtr + 64:", memPtr + 64);
        console.log(
            "Are they equal?",
            memPos == memPtr + 64 ? "YES - OVERLAP!" : "no"
        );

        // The struct POINTERS are stored at memPtr+32 and memPtr+64
        // Those slots should contain the addresses of struct0 and struct1
        // NOT the values 32 and 2!
    }
}
