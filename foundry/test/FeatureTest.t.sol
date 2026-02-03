// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

// ==========================================
// SECTION 1: Deployment Tests
// ==========================================

contract DeploymentFeatureTest is Test {
    // Test: NoSelector (fallback returns 15)
    function test_NoSelector_Fallback() public {
        bytes memory runtimeCode = vm.readFileBinary(
            "../output/NoSelector_opt_runtime.bin"
        );
        address target = address(0xCAFE);
        vm.etch(target, runtimeCode);
        require(target.code.length > 0, "Etch failed");

        (bool success, bytes memory result) = target.staticcall("");
        require(success, "NoSelector call failed");
        assertEq(abi.decode(result, (uint256)), 15, "NoSelector: expected 15");
    }

    // Test: DirectBytecode (hardcoded hex)
    function test_DirectBytecode() public {
        bytes
            memory runtime = hex"600060059060005261000f61001a565b600051526000602090f35b600a9091019056";
        address target = address(0xBEEF);
        vm.etch(target, runtime);

        (bool success, bytes memory result) = target.staticcall("");
        require(success, "DirectBytecode call failed");
        assertEq(
            abi.decode(result, (uint256)),
            15,
            "DirectBytecode: expected 15"
        );
    }

    // Test: NoSelectorDeploy (deploy from init code)
    function test_NoSelectorDeploy() public {
        bytes memory initcode = vm.readFileBinary(
            "../output/NoSelector_opt.bin"
        );
        require(initcode.length > 0, "Init code empty");

        address deployed;
        assembly {
            deployed := create(0, add(initcode, 0x20), mload(initcode))
        }
        require(deployed != address(0), "Deploy failed");

        (bool success, bytes memory result) = deployed.staticcall("");
        require(success, "NoSelectorDeploy call failed");
        assertEq(
            abi.decode(result, (uint256)),
            15,
            "NoSelectorDeploy: expected 15"
        );
    }

    // Test: RuntimeOnly (vm.etch pattern)
    function test_RuntimeOnly_MinimalCall() public {
        bytes memory runtimeCode = vm.readFileBinary(
            "../output/MinimalCall_opt_runtime.bin"
        );
        address target = address(0xDEAD);
        vm.etch(target, runtimeCode);
        require(target.code.length > 0, "RuntimeOnly etch failed");

        (bool success, bytes memory result) = target.staticcall(
            abi.encodeWithSignature("get()")
        );
        require(success, "RuntimeOnly call failed");
        assertEq(abi.decode(result, (uint256)), 1, "RuntimeOnly: expected 1");
    }

    // Test: TinyCall
    function test_TinyCall_Selector() public {
        bytes memory bytecode = vm.readFileBinary(
            "../output/TinyCall_opt_runtime.bin"
        );
        address target = address(0xBEEF);
        vm.etch(target, bytecode);
        require(target.code.length > 0, "Etch failed");

        (bool success, bytes memory data) = target.staticcall(
            abi.encodeWithSelector(0xb0bea725)
        );
        require(success, "TinyCall failed");
        assertEq(abi.decode(data, (uint256)), 0x42, "TinyCall: expected 0x42");
    }

    // Test: VoidCall
    function test_VoidCall_NoReturn() public {
        bytes memory bytecode = vm.readFileBinary(
            "../output/VoidCall_opt_runtime.bin"
        );
        address target = address(0xDEAD);
        vm.etch(target, bytecode);
        require(target.code.length > 0, "Etch failed");

        (bool success, ) = target.call(abi.encodeWithSignature("trigger()"));
        assertTrue(success, "VoidCall: trigger() reverted");
    }
}

// ==========================================
// SECTION 2: Complex Features Tests
// ==========================================

interface IComplexFeatures {
    function getImmutable() external view returns (uint256);
    function getConstant() external pure returns (uint256);
    function getVirtual() external pure returns (uint256);
    function complexFlow(uint256 x) external returns (uint256);
    function callInternal(uint256 a) external pure returns (uint256);
    function counter() external view returns (uint256);
    function currentState() external view returns (uint8);
}

contract ComplexFeatureTest is Test {
    address venomContract;
    uint256 constant IMMUTABLE_VAL = 999;

    function setUp() public {
        bytes memory args = abi.encode(IMMUTABLE_VAL);
        venomContract = deployComplex(
            "../output/ComplexFeaturesTest_opt.bin",
            args
        );
    }

    function deployComplex(
        string memory path,
        bytes memory args
    ) internal returns (address) {
        bytes memory bytecode = vm.readFileBinary(path);
        bytes memory fullCode = abi.encodePacked(bytecode, args);
        address addr;
        assembly {
            addr := create(0, add(fullCode, 0x20), mload(fullCode))
        }
        require(addr != address(0), "Deployment failed");
        return addr;
    }

    function test_Immutable() public {
        uint256 val = IComplexFeatures(venomContract).getImmutable();
        assertEq(val, IMMUTABLE_VAL, "Immutable value mismatch");
    }

    function test_Constant() public {
        uint256 val = IComplexFeatures(venomContract).getConstant();
        assertEq(val, 123, "Constant value mismatch");
    }

    function test_Override() public {
        uint256 val = IComplexFeatures(venomContract).getVirtual();
        assertEq(val, 200, "Override failed");
    }

    function test_InternalCall() public {
        uint256 val = IComplexFeatures(venomContract).callInternal(5);
        assertEq(val, 15, "Internal call failed");
    }

    function test_ComplexFlow() public {
        IComplexFeatures c = IComplexFeatures(venomContract);
        // Case 1: x < 10
        uint256 ret1 = c.complexFlow(5);
        assertEq(ret1, 1, "Flow 1 return wrong");
        assertEq(c.counter(), 1, "Flow 1 counter wrong");

        // Case 2: x < 20
        uint256 ret2 = c.complexFlow(15);
        assertEq(ret2, 2, "Flow 2 return wrong");
        assertEq(c.counter(), 3, "Flow 2 counter wrong");

        // Case 3: x >= 20 (State IDLE -> BUSY)
        uint256 ret3 = c.complexFlow(25);
        assertEq(ret3, 3, "Flow 3 return wrong");
        assertEq(c.currentState(), 1, "State not BUSY");

        // Case 4: x >= 20 (State BUSY -> ERROR)
        c.complexFlow(25);
        assertEq(c.currentState(), 2, "State not ERROR");
    }
}

// ==========================================
// SECTION 3: MegaTest (End-to-End)
// ==========================================

interface IMegaTest {
    function baseVal() external view returns (uint256);
    function middleVal() external view returns (uint256);
    function state() external view returns (uint8);
    function lib() external view returns (address);
    function balances(address) external view returns (uint256);
    function setBase(uint256 _val) external;
    function updateState(uint8 _newState) external;
    function checkConfig(uint256 x) external view returns (bool);
    function runCalc(uint256 a) external pure returns (uint256);
    function logic(uint256 x) external pure returns (uint256);
    function setTransient(uint256 slot, uint256 value) external;
    function getTransient(uint256 slot) external view returns (uint256);
    function transientCounter() external returns (uint256);
    struct Element {
        uint256 id;
        uint256 value;
    }
    function processStructs(
        Element[] calldata input
    ) external pure returns (Element[] memory output);
    function callA(uint256 value) external returns (uint256);
    function getRecursionDepth() external view returns (uint256);
}

contract MegaFeatureTest is Test {
    IMegaTest megatest;
    address lib = address(0x1234);

    function setUp() public {
        bytes memory bytecode = vm.readFileBinary(
            "../output/MegaTest_opt.bin"
        );
        address deployed;
        assembly {
            deployed := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        require(deployed != address(0), "Deployment failed");

        // Simulate constructor storage init
        vm.store(deployed, bytes32(uint256(7)), bytes32(uint256(uint160(lib)))); // lib
        vm.store(deployed, bytes32(uint256(3)), bytes32(uint256(10))); // minVal
        vm.store(deployed, bytes32(uint256(4)), bytes32(uint256(100))); // maxVal
        vm.store(
            deployed,
            bytes32(uint256(5)),
            bytes32(uint256(uint160(address(this))))
        ); // admin

        megatest = IMegaTest(deployed);
    }

    function test_deployment() public view {
        assertEq(megatest.lib(), lib, "lib should match constructor arg");
    }

    function test_initialState() public view {
        assertEq(megatest.state(), 0, "Initial state should be IDLE");
    }

    function test_initialConfig() public view {
        assertTrue(megatest.checkConfig(10), "10 valid");
        assertTrue(megatest.checkConfig(100), "100 valid");
        assertFalse(megatest.checkConfig(9), "9 invalid");
    }

    function test_setBase() public {
        megatest.setBase(10);
        assertEq(megatest.baseVal(), 20, "baseVal 20");
        assertEq(megatest.middleVal(), 10, "middleVal 10");
    }

    function test_logic() public view {
        assertEq(megatest.logic(5), 12, "logic(5) -> 12");
    }

    function test_runCalc() public view {
        assertEq(megatest.runCalc(5), 51, "runCalc(5) -> 51");
    }

    function test_updateState() public {
        megatest.updateState(1);
        assertEq(megatest.state(), 1, "ACTIVE");
        megatest.updateState(2);
        assertEq(megatest.state(), 2, "PAUSED");
    }

    function test_updateState_reverts() public {
        vm.expectRevert("Cannot stop");
        megatest.updateState(3);
    }

    function test_transientStorage() public {
        megatest.setTransient(42, 999);
        assertEq(megatest.getTransient(42), 999);
    }

    function test_transientCounter() public {
        assertEq(megatest.transientCounter(), 1);
        assertEq(megatest.transientCounter(), 2);
    }

    function test_recursiveCall() public {
        megatest.setTransient(512, 0); // Explicitly reset depth
        uint256 result = megatest.callA(1);
        assertEq(result, 22, "Recursive call result");
        assertEq(megatest.getRecursionDepth(), 0, "Depth reset");
    }

    function test_processStructs() public view {
        IMegaTest.Element[] memory input = new IMegaTest.Element[](2);
        input[0] = IMegaTest.Element(10, 20);
        input[1] = IMegaTest.Element(30, 40);
        IMegaTest.Element[] memory output = megatest.processStructs(input);
        assertEq(output[0].value, 40);
        assertEq(output[1].value, 80);
    }
}
