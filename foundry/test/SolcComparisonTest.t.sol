// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";

interface ILoopCheckCalldata {
    struct Element {
        uint256 id;
        uint256 value;
    }
    function processStructs(
        Element[] calldata input
    ) external pure returns (Element[] memory output);
}

contract SolcComparisonTest is Test {
    ILoopCheckCalldata solcTarget;
    ILoopCheckCalldata transpilerTarget;

    function setUp() public {
        // Load solc binary (optional)
        try
            vm.readFileBinary(
                "../output/LoopCheckCalldata_solc_runtime.bin"
            )
        returns (bytes memory code) {
            address addr = address(0x10099);
            vm.etch(addr, code);
            solcTarget = ILoopCheckCalldata(addr);
        } catch {
            console.log(
                "SolcComparisonTest: solc binary not found (skipping solc test)"
            );
        }
        // Load transpiler binary (optional)
        try
            vm.readFileBinary(
                "../output/LoopCheckCalldata_opt_runtime.bin"
            )
        returns (bytes memory code) {
            address addr = address(0x10098);
            vm.etch(addr, code);
            transpilerTarget = ILoopCheckCalldata(addr);
        } catch {
            console.log(
                "SolcComparisonTest: transpiler binary not found (skipping transpiler test)"
            );
        }
    }

    function test_solcCompiled() public {
        if (address(solcTarget) == address(0)) {
            console.log("Skipping test_solcCompiled - no solc binary");
            return;
        }

        ILoopCheckCalldata.Element[]
            memory input = new ILoopCheckCalldata.Element[](2);
        input[0] = ILoopCheckCalldata.Element({id: 10, value: 100});
        input[1] = ILoopCheckCalldata.Element({id: 20, value: 200});

        ILoopCheckCalldata.Element[] memory output = solcTarget.processStructs(
            input
        );

        assertEq(output[0].id, 10, "solc: first id");
        assertEq(output[0].value, 101, "solc: first value");
        assertEq(output[1].id, 20, "solc: second id");
        assertEq(output[1].value, 201, "solc: second value");
    }

    function test_transpilerCompiled() public {
        if (address(transpilerTarget) == address(0)) {
            console.log(
                "Skipping test_transpilerCompiled - no transpiler binary"
            );
            return;
        }

        ILoopCheckCalldata.Element[]
            memory input = new ILoopCheckCalldata.Element[](2);
        input[0] = ILoopCheckCalldata.Element({id: 10, value: 100});
        input[1] = ILoopCheckCalldata.Element({id: 20, value: 200});

        ILoopCheckCalldata.Element[] memory output = transpilerTarget
            .processStructs(input);

        assertEq(output[0].id, 10, "transpiler: first id");
        assertEq(output[0].value, 101, "transpiler: first value");
        assertEq(output[1].id, 20, "transpiler: second id");
        assertEq(output[1].value, 201, "transpiler: second value");
    }
}
