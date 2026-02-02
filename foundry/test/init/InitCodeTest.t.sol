// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

/**
 * @title InitCodeTestRunner
 * @notice Test harness for init bytecode verification.
 * @dev Uses CREATE opcode to deploy from init bytecode.
 */
contract InitCodeTestRunner is Test {
    bytes public initBytecode;

    function setUp() public {
        // Load init bytecode from file (consistent with InitEdgeCasesTest)
        string memory path = vm.envOr(
            "INIT_BYTECODE_PATH",
            string("../output/InitCodeTest_opt.bin")
        );
        initBytecode = vm.readFileBinary(path);
        require(initBytecode.length > 0, "Init bytecode is empty");
    }

    function test_deploy_and_call() public {
        // Deploy using CREATE
        address deployed;
        bytes memory code = initBytecode;
        assembly {
            deployed := create(0, add(code, 0x20), mload(code))
        }
        require(deployed != address(0), "Deployment failed");

        // Verify contract has code
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(deployed)
        }
        assertGt(codeSize, 0, "Deployed contract has no code");

        // Call getValue() - selector: 0x20965255
        (bool success, bytes memory result) = deployed.staticcall(
            abi.encodeWithSignature("getValue()")
        );
        assertTrue(success, "getValue() call failed");
        uint256 value = abi.decode(result, (uint256));
        assertEq(value, 42, "Constructor did not set value correctly");

        // Call setValue(100)
        (success, ) = deployed.call(
            abi.encodeWithSignature("setValue(uint256)", 100)
        );
        assertTrue(success, "setValue() call failed");

        // Verify new value
        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("getValue()")
        );
        assertTrue(success, "getValue() call failed after setValue");
        value = abi.decode(result, (uint256));
        assertEq(value, 100, "setValue did not work correctly");
    }

    function test_init_bytecode_size() public view {
        // Sanity check: init bytecode should be reasonably sized
        assertGt(initBytecode.length, 10, "Init bytecode too small");
        assertLt(initBytecode.length, 50000, "Init bytecode too large");
    }
}
