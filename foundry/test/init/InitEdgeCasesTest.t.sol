// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

/**
 * @title InitEdgeCasesTestRunner
 * @notice Test harness for all constructor edge cases.
 * @dev Tests deployment and verification of each edge case contract.
 */
contract InitEdgeCasesTestRunner is Test {
    // Helper to deploy bytecode with optional constructor args and value
    function deployBytecode(
        bytes memory initCode,
        bytes memory args,
        uint256 value
    ) internal returns (address deployed) {
        bytes memory fullCode = abi.encodePacked(initCode, args);
        assembly {
            deployed := create(value, add(fullCode, 0x20), mload(fullCode))
        }
        require(deployed != address(0), "Deployment failed");
    }

    function deployBytecode(
        bytes memory initCode,
        bytes memory args
    ) internal returns (address deployed) {
        return deployBytecode(initCode, args, 0);
    }

    function deployBytecode(
        bytes memory initCode
    ) internal returns (address deployed) {
        return deployBytecode(initCode, "", 0);
    }

    // =============================================================
    // Test: InitCodeTest (no-arg constructor)
    // =============================================================
    function test_noArg_deploy() public {
        string memory path = vm.envOr(
            "INIT_NOARG_PATH",
            string("../output/InitCodeTest.bin")
        );
        bytes memory code = vm.readFileBinary(path);
        address deployed = deployBytecode(code);

        (bool success, bytes memory result) = deployed.staticcall(
            abi.encodeWithSignature("getValue()")
        );
        assertTrue(success);
        assertEq(abi.decode(result, (uint256)), 42);
    }

    // =============================================================
    // Test: InitConstructorArgsTest (value args: uint, address, bool)
    // =============================================================
    function test_valueArgs_deploy() public {
        string memory path = vm.envOr(
            "INIT_ARGS_PATH",
            string("../output/InitConstructorArgsTest.bin")
        );
        bytes memory code = vm.readFileBinary(path);

        // Encode constructor args
        bytes memory args = abi.encode(uint256(999), address(0xBEEF), true);
        address deployed = deployBytecode(code, args);

        // Verify values
        (bool success, bytes memory result) = deployed.staticcall(
            abi.encodeWithSignature("getValue()")
        );
        assertTrue(success);
        assertEq(abi.decode(result, (uint256)), 999);

        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("getOwner()")
        );
        assertTrue(success);
        assertEq(abi.decode(result, (address)), address(0xBEEF));

        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("isActive()")
        );
        assertTrue(success);
        assertTrue(abi.decode(result, (bool)));
    }

    // =============================================================
    // Test: InitPayableTest (payable constructor)
    // =============================================================
    function test_payable_deploy() public {
        string memory path = vm.envOr(
            "INIT_PAYABLE_PATH",
            string("../output/InitPayableTest.bin")
        );
        bytes memory code = vm.readFileBinary(path);

        // Deploy with 1 ETH
        vm.deal(address(this), 10 ether);
        address deployed = deployBytecode(code, "", 1 ether);

        // Verify initial balance recorded
        (bool success, bytes memory result) = deployed.staticcall(
            abi.encodeWithSignature("getInitialBalance()")
        );
        assertTrue(success);
        assertEq(abi.decode(result, (uint256)), 1 ether);

        // Verify contract balance
        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("getBalance()")
        );
        assertTrue(success);
        assertEq(abi.decode(result, (uint256)), 1 ether);
    }

    // =============================================================
    // Test: InitImmutableTest (immutable variables)
    // =============================================================
    function test_immutable_deploy() public {
        string memory path = vm.envOr(
            "INIT_IMMUTABLE_PATH",
            string("../output/InitImmutableTest.bin")
        );
        bytes memory code = vm.readFileBinary(path);

        // Encode constructor args
        bytes memory args = abi.encode(uint256(12345), address(0xDEAD));
        address deployed = deployBytecode(code, args);

        // Verify immutable values
        (bool success, bytes memory result) = deployed.staticcall(
            abi.encodeWithSignature("getImmutableValue()")
        );
        assertTrue(success);
        assertEq(abi.decode(result, (uint256)), 12345);

        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("getImmutableOwner()")
        );
        assertTrue(success);
        assertEq(abi.decode(result, (address)), address(0xDEAD));

        // Verify mutable still works
        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("getMutable()")
        );
        assertTrue(success);
        assertEq(abi.decode(result, (uint256)), 100);
    }

    // =============================================================
    // Test: InitStringTest (string args)
    // =============================================================
    function test_string_deploy() public {
        string memory path = vm.envOr(
            "INIT_STRING_PATH",
            string("../output/InitStringTest.bin")
        );
        bytes memory code = vm.readFileBinary(path);

        // Encode constructor args (strings are dynamic)
        bytes memory args = abi.encode("TestToken", "TT");
        address deployed = deployBytecode(code, args);

        // Verify string values
        (bool success, bytes memory result) = deployed.staticcall(
            abi.encodeWithSignature("getName()")
        );
        assertTrue(success);
        assertEq(abi.decode(result, (string)), "TestToken");

        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("getSymbol()")
        );
        assertTrue(success);
        assertEq(abi.decode(result, (string)), "TT");
    }

    // =============================================================
    // Test: InitArrayTest (array args)
    // =============================================================
    function test_array_deploy() public {
        string memory path = vm.envOr(
            "INIT_ARRAY_PATH",
            string("../output/InitArrayTest.bin")
        );
        bytes memory code = vm.readFileBinary(path);

        // Encode constructor args (dynamic array)
        uint256[] memory initialValues = new uint256[](3);
        initialValues[0] = 10;
        initialValues[1] = 20;
        initialValues[2] = 30;
        bytes memory args = abi.encode(initialValues);
        address deployed = deployBytecode(code, args);

        // Verify array length
        (bool success, bytes memory result) = deployed.staticcall(
            abi.encodeWithSignature("getLength()")
        );
        assertTrue(success);
        assertEq(abi.decode(result, (uint256)), 3);

        // Verify individual values
        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("getValueAt(uint256)", 0)
        );
        assertTrue(success);
        assertEq(abi.decode(result, (uint256)), 10);

        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("getValueAt(uint256)", 2)
        );
        assertTrue(success);
        assertEq(abi.decode(result, (uint256)), 30);
    }

    // =============================================================
    // Test: InitComplexTest (args + require + internal call + event)
    // =============================================================
    function test_complex_deploy() public {
        string memory path = vm.envOr(
            "INIT_COMPLEX_PATH",
            string("../output/InitComplexTest.bin")
        );
        bytes memory code = vm.readFileBinary(path);

        // Encode constructor args
        bytes memory args = abi.encode(address(0xCAFE), uint256(1000));
        address deployed = deployBytecode(code, args);

        // Verify owner
        (bool success, bytes memory result) = deployed.staticcall(
            abi.encodeWithSignature("getOwner()")
        );
        assertTrue(success);
        assertEq(abi.decode(result, (address)), address(0xCAFE));

        // Verify total supply
        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("getTotalSupply()")
        );
        assertTrue(success);
        assertEq(abi.decode(result, (uint256)), 1000);

        // Verify ownerBalance (internal _mint was called)
        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("balanceOf()")
        );
        assertTrue(success);
        assertEq(abi.decode(result, (uint256)), 1000);
    }

    // =============================================================
    // Test: Revert on invalid args (require in constructor)
    // =============================================================
    function test_complex_revert_invalidOwner() public {
        string memory path = vm.envOr(
            "INIT_COMPLEX_PATH",
            string("../output/InitComplexTest.bin")
        );
        bytes memory code = vm.readFileBinary(path);

        // Try to deploy with address(0) - should revert
        bytes memory args = abi.encode(address(0), uint256(1000));
        bytes memory fullCode = abi.encodePacked(code, args);

        address deployed;
        assembly {
            deployed := create(0, add(fullCode, 0x20), mload(fullCode))
        }
        assertEq(deployed, address(0), "Should have reverted");
    }

    // =============================================================
    // Test: InitNewChildTest (constructor creates child contracts with `new`)
    // =============================================================
    function test_newChild_deploy() public {
        string memory path = vm.envOr(
            "INIT_NEWCHILD_PATH",
            string("../output/InitNewChildTest.bin")
        );
        bytes memory code = vm.readFileBinary(path);

        // Constructor: (uint256 _value, string memory _name)
        bytes memory args = abi.encode(uint256(42), "TestChild");
        address deployed = deployBytecode(code, args);

        // Verify value
        (bool success, bytes memory result) = deployed.staticcall(
            abi.encodeWithSignature("getValue()")
        );
        assertTrue(success, "getValue failed");
        assertEq(abi.decode(result, (uint256)), 42);

        // Verify deployer
        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("getDeployer()")
        );
        assertTrue(success, "getDeployer failed");
        assertEq(abi.decode(result, (address)), address(this));

        // Verify child contracts were created (addresses should be non-zero)
        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("getChildA()")
        );
        assertTrue(success, "getChildA failed");
        address childA = abi.decode(result, (address));
        assertTrue(childA != address(0), "ChildA not created");

        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("getChildB()")
        );
        assertTrue(success, "getChildB failed");
        address childB = abi.decode(result, (address));
        assertTrue(childB != address(0), "ChildB not created");

        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("getChildC()")
        );
        assertTrue(success, "getChildC failed");
        address childC = abi.decode(result, (address));
        assertTrue(childC != address(0), "ChildC not created");
    }

    // =============================================================
    // Test: InitInheritanceTest (4-level inheritance chain with immutables)
    // =============================================================
    function test_inheritance_deploy() public {
        string memory path = vm.envOr(
            "INIT_INHERITANCE_PATH",
            string("../output/InitInheritanceTest.bin")
        );
        bytes memory code = vm.readFileBinary(path);

        // Constructor: (weth, owner, config, sender0, sender1)
        address weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        address owner = address(0xBEEF);
        uint256 config = 12345;
        address sender0 = address(0x1111);
        address sender1 = address(0x2222);

        bytes memory args = abi.encode(weth, owner, config, sender0, sender1);
        address deployed = deployBytecode(code, args);

        // Verify inherited immutables from all levels
        (bool success, bytes memory result) = deployed.staticcall(
            abi.encodeWithSignature("getWeth()")
        );
        assertTrue(success, "getWeth failed");
        assertEq(abi.decode(result, (address)), weth);

        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("getOwner()")
        );
        assertTrue(success, "getOwner failed");
        assertEq(abi.decode(result, (address)), owner);

        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("getConfig()")
        );
        assertTrue(success, "getConfig failed");
        assertEq(abi.decode(result, (uint256)), config);

        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("getSender0()")
        );
        assertTrue(success, "getSender0 failed");
        assertEq(abi.decode(result, (address)), sender0);

        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("getSender1()")
        );
        assertTrue(success, "getSender1 failed");
        assertEq(abi.decode(result, (address)), sender1);

        // Verify storage variables
        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("isActive()")
        );
        assertTrue(success, "isActive failed");
        assertEq(abi.decode(result, (bool)), true);
    }

    // =============================================================
    // Test: InitMultiImmutableTest (9 immutables of different types)
    // =============================================================
    function test_multiImmutable_deploy() public {
        string memory path = vm.envOr(
            "INIT_MULTIIMMUTABLE_PATH",
            string("../output/InitMultiImmutableTest.bin")
        );
        bytes memory code = vm.readFileBinary(path);

        // Constructor: (addr1, addr2, addr3, uint1, uint2, uint128val, flag1, flag2, hash)
        address addr1 = address(0x1111);
        address addr2 = address(0x2222);
        address addr3 = address(0x3333);
        uint256 uint1 = 100;
        uint256 uint2 = 200;
        uint128 uint128val = 12345678;
        bool flag1 = true;
        bool flag2 = false;
        bytes32 hash = keccak256("test");

        bytes memory args = abi.encode(
            addr1,
            addr2,
            addr3,
            uint1,
            uint2,
            uint128val,
            flag1,
            flag2,
            hash
        );
        address deployed = deployBytecode(code, args);

        // Verify all immutables
        (bool success, bytes memory result) = deployed.staticcall(
            abi.encodeWithSignature("getAddr1()")
        );
        assertTrue(success, "getAddr1 failed");
        assertEq(abi.decode(result, (address)), addr1);

        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("getAddr2()")
        );
        assertTrue(success, "getAddr2 failed");
        assertEq(abi.decode(result, (address)), addr2);

        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("getUint1()")
        );
        assertTrue(success, "getUint1 failed");
        assertEq(abi.decode(result, (uint256)), uint1);

        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("getHash()")
        );
        assertTrue(success, "getHash failed");
        assertEq(abi.decode(result, (bytes32)), hash);

        // Verify storage counter
        (success, result) = deployed.staticcall(
            abi.encodeWithSignature("getCounter()")
        );
        assertTrue(success, "getCounter failed");
        assertEq(abi.decode(result, (uint256)), 1);
    }
}
