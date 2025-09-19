#!/usr/bin/env python3
"""Test to understand the hardcoded optimization behavior."""

from textwrap import dedent
import subprocess
import tempfile
import os

def get_venom_ir(yul_code: str) -> str:
    """Get Venom IR output for Yul code."""
    with tempfile.NamedTemporaryFile(mode='w', suffix='.yul', delete=False) as f:
        f.write(yul_code)
        f.flush()
        yul_file = f.name

    try:
        cmd = [
            'python',
            'vyper/cli/yul.py',
            '--venom',
            yul_file
        ]
        env = os.environ.copy()
        env['PYTHONPATH'] = '/Users/harkal/projects/charles_cooper/repos/vyper:.'

        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            env=env
        )

        if result.returncode != 0:
            raise RuntimeError(f"Yul compilation failed: {result.stderr}")

        return result.stdout
    finally:
        os.unlink(yul_file)


def main():
    # Pattern that should trigger hardcoding
    yul_hardcoded = dedent("""
        object "Test" {
            code {
                function abi_decode_tuple_t_uint256t_uint256(headStart, dataEnd) -> value0, value1 {
                    value0 := calldataload(headStart)
                    value1 := calldataload(add(headStart, 32))
                }

                let x, y := abi_decode_tuple_t_uint256t_uint256(4, calldatasize())
                mstore(0, x)
                mstore(32, y)
            }
        }
    """)

    # Pattern that should NOT trigger hardcoding (three params)
    yul_three_params = dedent("""
        object "Test" {
            code {
                function abi_decode_tuple_t_uint256t_uint256t_uint256(headStart, dataEnd) -> value0, value1, value2 {
                    value0 := calldataload(headStart)
                    value1 := calldataload(add(headStart, 32))
                    value2 := calldataload(add(headStart, 64))
                }

                let x, y, z := abi_decode_tuple_t_uint256t_uint256t_uint256(4, calldatasize())
                mstore(0, x)
                mstore(32, y)
                mstore(64, z)
            }
        }
    """)

    print("=== VENOM IR for 2-param abi_decode (potentially hardcoded) ===")
    ir2 = get_venom_ir(yul_hardcoded)
    print(ir2)

    print("\n=== VENOM IR for 3-param abi_decode (not hardcoded) ===")
    ir3 = get_venom_ir(yul_three_params)
    print(ir3)

    # Check for function invocation vs inline
    if "invoke" in ir2 and "abi_decode" in ir2:
        print("\n✓ 2-param version uses function invocation (NOT inlined)")
    else:
        print("\n✗ 2-param version appears to be inlined")

    if "invoke" in ir3 and "abi_decode" in ir3:
        print("✓ 3-param version uses function invocation")
    else:
        print("✗ 3-param version appears to be inlined")


if __name__ == "__main__":
    main()