// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

contract RuntimeDirectTest is Test {
    function test_runtime_only() public {
        bytes memory runtime = vm.readFileBinary(
            "../output/InitConstructorArgsTest_opt_runtime.bin"
        );
        console.log("Runtime size:", runtime.length);

        // Deploy runtime directly with etch
        address target = address(0x1234);
        vm.etch(target, runtime);

        // Set storage manually (what constructor would do)
        vm.store(target, bytes32(0), bytes32(uint256(999)));
        // slot 1: address(0xBEEF) packed with bool active=true at bit 160
        vm.store(
            target,
            bytes32(uint256(1)),
            bytes32(uint256(uint160(0xBEEF)) | (uint256(1) << 160))
        );

        // Try calling getValue - selector 0x20965255
        (bool success, bytes memory result) = target.staticcall(
            abi.encodeWithSignature("getValue()")
        );
        console.log("getValue success:", success);
        if (success) {
            console.log("value:", abi.decode(result, (uint256)));
        }
        assertTrue(success, "getValue failed");
        assertEq(abi.decode(result, (uint256)), 999);
    }
}
