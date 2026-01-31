// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

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
    function test_solcCompiled() public {
        bytes memory code = vm.readFileBinary(
            "yul2venom/output/LoopCheckCalldata_solc_runtime.bin"
        );
        address addr = address(0x10099);
        vm.etch(addr, code);

        ILoopCheckCalldata.Element[]
            memory input = new ILoopCheckCalldata.Element[](2);
        input[0] = ILoopCheckCalldata.Element({id: 10, value: 100});
        input[1] = ILoopCheckCalldata.Element({id: 20, value: 200});

        ILoopCheckCalldata.Element[] memory output = ILoopCheckCalldata(addr)
            .processStructs(input);

        assertEq(output[0].id, 10, "solc: first id");
        assertEq(output[0].value, 101, "solc: first value");
        assertEq(output[1].id, 20, "solc: second id");
        assertEq(output[1].value, 201, "solc: second value");
    }

    function test_transpilerCompiled() public {
        bytes memory code = vm.readFileBinary(
            "yul2venom/output/LoopCheckCalldata_opt_runtime.bin"
        );
        address addr = address(0x10098);
        vm.etch(addr, code);

        ILoopCheckCalldata.Element[]
            memory input = new ILoopCheckCalldata.Element[](2);
        input[0] = ILoopCheckCalldata.Element({id: 10, value: 100});
        input[1] = ILoopCheckCalldata.Element({id: 20, value: 200});

        ILoopCheckCalldata.Element[] memory output = ILoopCheckCalldata(addr)
            .processStructs(input);

        assertEq(output[0].id, 10, "transpiler: first id");
        assertEq(output[0].value, 101, "transpiler: first value");
        assertEq(output[1].id, 20, "transpiler: second id");
        assertEq(output[1].value, 201, "transpiler: second value");
    }
}
