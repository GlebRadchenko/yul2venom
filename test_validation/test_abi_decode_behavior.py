"""Test actual behavior differences for ABI decode patterns."""

import pytest
from textwrap import dedent
import subprocess
import tempfile
import os
from test_validation.revm_environment import RevmEnvironment
from test_validation.runners.yul_transpiler import YulTranspiler


def compile_and_execute(yul_code: str, calldata: bytes = b"") -> tuple[bool, bytes]:
    """Compile Yul code and execute with given calldata."""
    # Write Yul to temp file
    with tempfile.NamedTemporaryFile(mode='w', suffix='.yul', delete=False) as f:
        f.write(yul_code)
        f.flush()
        yul_file = f.name

    try:
        # Compile with yul transpiler
        transpiler = YulTranspiler()
        bytecode = transpiler.compile_yul_to_bytecode(yul_code)

        # Deploy and execute
        env = RevmEnvironment()
        success, address = env.deploy_contract(bytecode)
        if not success:
            return False, b""

        # Execute with calldata
        result = env.call_contract(address, calldata)
        return result.success, result.output
    finally:
        os.unlink(yul_file)


def test_hardcoded_tuple_uint256_uint256_behavior():
    """Test the hardcoded abi_decode_tuple_t_uint256t_uint256 optimization."""
    # This pattern IS hardcoded in the current implementation
    yul_code_hardcoded = dedent("""
        object "Test" {
            code {
                function abi_decode_t_uint256(offset, end) -> value {
                    value := calldataload(offset)
                }

                function abi_decode_tuple_t_uint256t_uint256(headStart, dataEnd) -> value0, value1 {
                    if iszero(slt(add(headStart, 63), dataEnd)) { revert(0, 0) }
                    value0 := abi_decode_t_uint256(add(headStart, 0), dataEnd)
                    value1 := abi_decode_t_uint256(add(headStart, 32), dataEnd)
                }

                // This pattern triggers the hardcoded path
                let x, y := abi_decode_tuple_t_uint256t_uint256(4, calldatasize())

                // Store and return
                mstore(0, x)
                mstore(32, y)
                return(0, 64)
            }
        }
    """)

    # Similar pattern but with THREE uint256s - NOT hardcoded
    yul_code_not_hardcoded = dedent("""
        object "Test" {
            code {
                function abi_decode_t_uint256(offset, end) -> value {
                    value := calldataload(offset)
                }

                function abi_decode_tuple_t_uint256t_uint256t_uint256(headStart, dataEnd) -> value0, value1, value2 {
                    if iszero(slt(add(headStart, 95), dataEnd)) { revert(0, 0) }
                    value0 := abi_decode_t_uint256(add(headStart, 0), dataEnd)
                    value1 := abi_decode_t_uint256(add(headStart, 32), dataEnd)
                    value2 := abi_decode_t_uint256(add(headStart, 64), dataEnd)
                }

                // This pattern is NOT hardcoded - goes through normal function path
                let x, y, z := abi_decode_tuple_t_uint256t_uint256t_uint256(4, calldatasize())

                // Store first two values for comparison
                mstore(0, x)
                mstore(32, y)
                return(0, 64)
            }
        }
    """)

    # Test data: selector (4 bytes) + two uint256 values
    calldata = bytes.fromhex("00000000")  # dummy selector
    calldata += (42).to_bytes(32, 'big')   # first uint256
    calldata += (99).to_bytes(32, 'big')   # second uint256
    calldata += (77).to_bytes(32, 'big')   # third uint256 (for 3-param version)

    success1, output1 = compile_and_execute(yul_code_hardcoded, calldata)
    success2, output2 = compile_and_execute(yul_code_not_hardcoded, calldata)

    assert success1, "Hardcoded version should succeed"
    assert success2, "Non-hardcoded version should succeed"

    # Both should return the same values
    assert output1 == output2, f"Outputs should match: {output1.hex()} vs {output2.hex()}"


def test_mixed_type_decode_not_optimized():
    """Test that mixed-type decodes are not optimized."""
    # Address + uint256 pattern - NOT hardcoded
    yul_code = dedent("""
        object "Test" {
            code {
                function abi_decode_t_address(offset, end) -> value {
                    value := and(calldataload(offset), 0xffffffffffffffffffffffffffffffffffffffff)
                }

                function abi_decode_t_uint256(offset, end) -> value {
                    value := calldataload(offset)
                }

                function abi_decode_tuple_t_addresst_uint256(headStart, dataEnd) -> value0, value1 {
                    if iszero(slt(add(headStart, 63), dataEnd)) { revert(0, 0) }
                    value0 := abi_decode_t_address(add(headStart, 0), dataEnd)
                    value1 := abi_decode_t_uint256(add(headStart, 32), dataEnd)
                }

                let addr, amount := abi_decode_tuple_t_addresst_uint256(4, calldatasize())

                mstore(0, addr)
                mstore(32, amount)
                return(0, 64)
            }
        }
    """)

    # Test data
    calldata = bytes.fromhex("00000000")  # dummy selector
    # Address (padded to 32 bytes)
    calldata += bytes.fromhex("000000000000000000000000" + "1234567890123456789012345678901234567890")
    calldata += (1000).to_bytes(32, 'big')  # amount

    success, output = compile_and_execute(yul_code, calldata)
    assert success, "Should compile and execute"

    # Check the output contains our values
    addr_from_output = int.from_bytes(output[:32], 'big')
    amount_from_output = int.from_bytes(output[32:64], 'big')

    expected_addr = 0x1234567890123456789012345678901234567890
    assert addr_from_output == expected_addr, f"Address mismatch: {hex(addr_from_output)} vs {hex(expected_addr)}"
    assert amount_from_output == 1000, f"Amount mismatch: {amount_from_output} vs 1000"


def test_fromMemory_pattern_optimization():
    """Test the fromMemory decode pattern optimization."""
    yul_code = dedent("""
        object "Test" {
            code {
                // Set up some test data in memory
                mstore(0, 42)
                mstore(32, 99)

                function abi_decode_t_uint256_fromMemory(offset, end) -> value {
                    value := mload(offset)
                }

                function abi_decode_tuple_t_uint256_fromMemory(headStart, dataEnd) -> value0 {
                    value0 := abi_decode_t_uint256_fromMemory(headStart, dataEnd)
                }

                // This pattern IS optimized in the current code
                let x := abi_decode_tuple_t_uint256_fromMemory(0, 32)

                mstore(64, x)
                return(64, 32)
            }
        }
    """)

    success, output = compile_and_execute(yul_code, b"")
    assert success, "Should compile and execute"

    result = int.from_bytes(output, 'big')
    assert result == 42, f"Should return 42, got {result}"


def test_performance_difference_measurement():
    """Measure if there's an actual performance difference with hardcoding."""

    # Get bytecode size for hardcoded pattern
    yul_hardcoded = dedent("""
        object "Test" {
            code {
                function abi_decode_tuple_t_uint256t_uint256(headStart, dataEnd) -> value0, value1 {
                    value0 := calldataload(headStart)
                    value1 := calldataload(add(headStart, 32))
                }
                let x, y := abi_decode_tuple_t_uint256t_uint256(4, calldatasize())
                stop()
            }
        }
    """)

    # Get bytecode size for non-hardcoded (function call)
    yul_function = dedent("""
        object "Test" {
            code {
                function abi_decode_tuple_t_uint256t_uint256t_uint256(headStart, dataEnd) -> value0, value1, value2 {
                    value0 := calldataload(headStart)
                    value1 := calldataload(add(headStart, 32))
                    value2 := calldataload(add(headStart, 64))
                }
                let x, y, z := abi_decode_tuple_t_uint256t_uint256t_uint256(4, calldatasize())
                stop()
            }
        }
    """)

    transpiler = YulTranspiler()
    bytecode1 = transpiler.compile_yul_to_bytecode(yul_hardcoded)
    bytecode2 = transpiler.compile_yul_to_bytecode(yul_function)

    print(f"Hardcoded pattern bytecode size: {len(bytecode1)} bytes")
    print(f"Function pattern bytecode size: {len(bytecode2)} bytes")

    # The hardcoded optimization should result in smaller bytecode
    # since it avoids function call overhead