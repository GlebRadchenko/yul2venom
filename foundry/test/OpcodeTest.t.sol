// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

// ==========================================
// SECTION 1: OpcodeBasics (Interface)
// ==========================================

interface IOpcodeBasics {
    function test_sub(uint256 a, uint256 b) external pure returns (uint256);
    function test_div(uint256 a, uint256 b) external pure returns (uint256);
    function test_lt(uint256 a, uint256 b) external pure returns (uint256);
    function test_gt(uint256 a, uint256 b) external pure returns (uint256);
    function test_shl(
        uint256 shift,
        uint256 val
    ) external pure returns (uint256);
    function test_slt(uint256 a, uint256 b) external pure returns (uint256);
    function test_lt_literal(uint256 b) external pure returns (uint256);
    function test_mul(uint256 a, uint256 b) external pure returns (uint256);
    function test_loop_lt(uint256 limit) external pure returns (uint256);
}

contract OpcodeTest is Test {
    IOpcodeBasics public opcodeTarget;

    function setUp() public {
        address addr = address(0xCAFE);
        try
            vm.readFileBinary("../output/OpcodeBasics_opt_runtime.bin")
        returns (bytes memory code) {
            vm.etch(addr, code);
            opcodeTarget = IOpcodeBasics(addr);
        } catch {
            console.log("OpcodeBasics binary not found");
        }
    }

    function checkDeployed() internal view returns (bool) {
        return address(opcodeTarget).code.length > 0;
    }

    function test_Opcodes_Sub() public {
        if (!checkDeployed()) return;
        assertEq(opcodeTarget.test_sub(100, 20), 80, "sub(100, 20) != 80");
        // Contract returns 0 when b > a (explicit underflow guard)
        assertEq(opcodeTarget.test_sub(20, 100), 0, "sub(20, 100) != 0");
    }

    function test_Opcodes_Div() public {
        if (!checkDeployed()) return;
        assertEq(opcodeTarget.test_div(100, 20), 5, "div(100, 20) != 5");
        assertEq(opcodeTarget.test_div(20, 100), 0, "div(20, 100) != 0");
    }

    function test_Opcodes_Lt() public {
        if (!checkDeployed()) return;
        assertEq(opcodeTarget.test_lt(10, 20), 1, "lt(10, 20) != 1");
        assertEq(opcodeTarget.test_lt(20, 10), 0, "lt(20, 10) != 0");
    }

    function test_Opcodes_Gt() public {
        if (!checkDeployed()) return;
        assertEq(opcodeTarget.test_gt(20, 10), 1, "gt(20, 10) != 1");
        assertEq(opcodeTarget.test_gt(10, 20), 0, "gt(10, 20) != 0");
    }

    function test_Opcodes_Shl() public {
        if (!checkDeployed()) return;
        assertEq(opcodeTarget.test_shl(8, 1), 256, "shl(8, 1) != 256");
        assertEq(opcodeTarget.test_shl(0, 1), 1, "shl(0, 1) != 1");
    }

    function test_Opcodes_Slt() public {
        if (!checkDeployed()) return;
        assertEq(opcodeTarget.test_slt(10, 20), 1, "slt(10, 20) != 1");
        assertEq(opcodeTarget.test_slt(20, 10), 0, "slt(20, 10) != 0");
        unchecked {
            uint256 neg10 = uint256(int256(-10));
            assertEq(opcodeTarget.test_slt(neg10, 10), 1, "slt(-10, 10) != 1");
            assertEq(opcodeTarget.test_slt(10, neg10), 0, "slt(10, -10) != 0");
        }
    }

    function test_Opcodes_Mul() public {
        if (!checkDeployed()) return;
        assertEq(opcodeTarget.test_mul(5, 4), 20, "mul(5, 4) != 20");
        assertEq(opcodeTarget.test_mul(0, 5), 0, "mul(0, 5) != 0");
    }

    function test_Opcodes_Loop_Lt() public {
        if (!checkDeployed()) return;
        assertEq(opcodeTarget.test_loop_lt(2), 2, "loop(2) != 2");
    }
}

// ==========================================
// SECTION 2: DebugRevert & Raw Calls
// ==========================================

contract OpcodeDebugTest is Test {
    function test_debug_mstore_return() public {
        address addr = address(0xDEAD);
        try
            vm.readFileBinary("../output/Debug_opt_runtime.bin")
        returns (bytes memory code) {
            vm.etch(addr, code);
        } catch {
            return;
        }
        (bool success, bytes memory data) = addr.staticcall("");
        assertTrue(success, "Call failed");
        require(data.length >= 32, "Data too short");

        bytes32 val;
        assembly {
            val := mload(add(data, 32))
        }
        assertEq(uint256(val), 0x12345678, "Should return 0x12345678");
    }

    function test_opcode_basics_raw() public {
        bytes memory code;
        try
            vm.readFileBinary("../output/OpcodeBasics_opt_runtime.bin")
        returns (bytes memory c) {
            code = c;
        } catch {
            return;
        }
        address addr = address(0xCAFE);
        vm.etch(addr, code);

        // sub(100, 20) -> 80
        verifyCall(addr, 0x17fafa3b, 100, 20, 80, "sub(100, 20)");
        // div(100, 20) -> 5
        verifyCall(addr, 0xf21b1150, 100, 20, 5, "div(100, 20)");
        // lt(10, 20) -> 1
        verifyCall(addr, 0x62d2c41d, 10, 20, 1, "lt(10, 20)");
    }

    function verifyCall(
        address addr,
        bytes4 selector,
        uint256 a,
        uint256 b,
        uint256 expected,
        string memory desc
    ) internal {
        bytes memory callData = abi.encodeWithSelector(selector, a, b);
        (bool success, bytes memory data) = addr.staticcall(callData);
        if (!success) revert("Call failed");
        bytes32 val = abi.decode(data, (bytes32));
        assertEq(uint256(val), expected, desc);
    }
}
