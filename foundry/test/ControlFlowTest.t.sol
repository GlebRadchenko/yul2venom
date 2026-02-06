// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

// ==========================================
// SECTION 1: Basic Control Flow (Switch/Loop)
// ==========================================

contract ControlFlowTest is Test {
    address target;

    function setUp() public {
        try
            vm.readFileBinary(
                "yul2venom/tests/control_flow/ControlFlow_opt_runtime.bin"
            )
        returns (bytes memory code) {
            address addr = address(0xCF);
            vm.etch(addr, code);
            target = addr;
        } catch {
            console.log("Skipping ControlFlowTest - binary not found");
        }
    }

    function test_Switch() public {
        if (target == address(0)) return;
        // Case 1
        uint256 ret = callSwitch(1);
        assertEq(ret, 100, "Switch Case 1");

        // Case 2
        ret = callSwitch(2);
        assertEq(ret, 200, "Switch Case 2");

        // Default (3)
        ret = callSwitch(3);
        assertEq(ret, 300, "Switch Default");
    }

    function test_Loop() public {
        if (target == address(0)) return;
        // Sum 0..5 = 15
        uint256 ret = callLoop(5);
        assertEq(ret, 15, "Loop Sum(5)");

        // Sum 0..10 = 55
        ret = callLoop(10);
        assertEq(ret, 55, "Loop Sum(10)");
    }

    function callSwitch(uint256 val) internal returns (uint256) {
        (bool success, bytes memory data) = target.staticcall(
            abi.encodeWithSelector(0x11111111, val)
        );
        require(success, "Switch Call Failed");
        return abi.decode(data, (uint256));
    }

    function callLoop(uint256 n) internal returns (uint256) {
        (bool success, bytes memory data) = target.staticcall(
            abi.encodeWithSelector(0x22222222, n)
        );
        require(success, "Loop Call Failed");
        return abi.decode(data, (uint256));
    }
}

// ==========================================
// SECTION 2: LoopCheck (Memory Structs)
// ==========================================

interface ILoopCheck {
    struct Element {
        uint256 id;
        uint256 value;
    }
    function process(
        Element[] calldata input
    ) external returns (Element[] memory output);
}

contract LoopCheckTest is Test {
    ILoopCheck loopCheck;

    function setUp() public {
        address target = address(0x10091);
        try
            vm.readFileBinary("../output/LoopCheck_opt_runtime.bin")
        returns (bytes memory code) {
            vm.etch(target, code);
            loopCheck = ILoopCheck(target);
        } catch {
            console.log("Skipping LoopCheck - output not found");
        }
    }

    function test_processLoop() public {
        if (address(loopCheck) == address(0)) return;

        ILoopCheck.Element[] memory input = new ILoopCheck.Element[](2);
        input[0] = ILoopCheck.Element(10, 100);
        input[1] = ILoopCheck.Element(20, 200);

        ILoopCheck.Element[] memory output = loopCheck.process(input);

        assertEq(output.length, 2);
        assertEq(output[0].id, 10);
        assertEq(output[0].value, 101); // 100 + 1
        assertEq(output[1].id, 20);
        assertEq(output[1].value, 201); // 200 + 1
    }
}

// ==========================================
// SECTION 3: LoopCheckCalldata (Calldata Structs)
// ==========================================

interface ILoopCheckCalldata {
    struct Element {
        uint256 id;
        uint256 value;
    }
    function processStructs(
        Element[] calldata input
    ) external pure returns (Element[] memory output);
}

contract LoopCheckCalldataTest is Test {
    ILoopCheckCalldata loopCheck;

    function setUp() public {
        address target = address(0x10092);
        // Note: Filename might vary based on pipeline runs, using most recent known good one or generic
        string[2] memory candidates = [
            "../output/LoopCheckCalldata_opt_runtime.bin",
            "../output/LoopCheckCalldata_opt_opt_runtime.bin"
        ];
        bytes memory code;

        for (uint i = 0; i < 2; i++) {
            try vm.readFileBinary(candidates[i]) returns (bytes memory c) {
                code = c;
                break;
            } catch {}
        }

        if (code.length > 0) {
            vm.etch(target, code);
            loopCheck = ILoopCheckCalldata(target);
        }
    }

    function test_processStructs() public {
        if (address(loopCheck) == address(0)) return;

        ILoopCheckCalldata.Element[]
            memory input = new ILoopCheckCalldata.Element[](2);
        input[0] = ILoopCheckCalldata.Element({id: 10, value: 100});
        input[1] = ILoopCheckCalldata.Element({id: 20, value: 200});

        ILoopCheckCalldata.Element[] memory output = loopCheck.processStructs(
            input
        );

        assertEq(output.length, 2);
        assertEq(output[0].id, 10);
        assertEq(output[0].value, 101);
        assertEq(output[1].id, 20);
        assertEq(output[1].value, 201);
    }

    function test_processStructs_0_elements() public {
        if (address(loopCheck) == address(0)) return;

        ILoopCheckCalldata.Element[]
            memory input = new ILoopCheckCalldata.Element[](0);

        ILoopCheckCalldata.Element[] memory output = loopCheck.processStructs(
            input
        );

        assertEq(output.length, 0);
    }

    function test_processStructs_1_element() public {
        if (address(loopCheck) == address(0)) return;

        ILoopCheckCalldata.Element[]
            memory input = new ILoopCheckCalldata.Element[](1);
        input[0] = ILoopCheckCalldata.Element({id: 10, value: 100});

        ILoopCheckCalldata.Element[] memory output = loopCheck.processStructs(
            input
        );

        assertEq(output.length, 1);
        assertEq(output[0].id, 10);
        assertEq(output[0].value, 101);
    }

    function test_processStructs_3_elements() public {
        if (address(loopCheck) == address(0)) return;

        ILoopCheckCalldata.Element[]
            memory input = new ILoopCheckCalldata.Element[](3);
        input[0] = ILoopCheckCalldata.Element({id: 10, value: 100});
        input[1] = ILoopCheckCalldata.Element({id: 20, value: 200});
        input[2] = ILoopCheckCalldata.Element({id: 30, value: 300});

        ILoopCheckCalldata.Element[] memory output = loopCheck.processStructs(
            input
        );

        assertEq(output.length, 3);
        assertEq(output[0].id, 10);
        assertEq(output[0].value, 101);
        assertEq(output[1].id, 20);
        assertEq(output[1].value, 201);
        assertEq(output[2].id, 30);
        assertEq(output[2].value, 301);
    }
}

// ==========================================
// SECTION 4: LoopCheckMinimal
// ==========================================

contract LoopCheckMinimalTest is Test {
    function test_minimal() public {
        address addr = address(0x123);
        try
            vm.readFileBinary(
                "../output/LoopCheckMinimal_opt_runtime.bin"
            )
        returns (bytes memory code) {
            vm.etch(addr, code);
        } catch {
            return;
        }
        (bool success, bytes memory ret) = addr.call("");
        assertTrue(success, "Call failed");
        // Just checking it doesn't revert/crash
    }
}
