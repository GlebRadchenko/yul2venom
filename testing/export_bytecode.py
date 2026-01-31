#!/usr/bin/env python3
"""
Export Bytecode - Compile Yul to EVM bytecode via solc standard-json.

Usage:
    python3 export_bytecode.py <input.yul> <output.bin> [--optimizer-runs N]
    
This tool uses solc's standard JSON interface with Foundry-compatible
optimizer settings for consistent bytecode output.
"""

import subprocess
import sys
import os
import json
import argparse


def compile_yul_standard_json(
    yul_path: str,
    output_path: str,
    optimizer_runs: int = 3_000_000,
    optimizer_steps: str = "dhfoDgvulfnTUtnIf[xarrscLMcCTU]uljmul"
) -> bool:
    """
    Compile Yul to bytecode using solc standard-json interface.
    
    Args:
        yul_path: Path to input .yul file
        output_path: Path for output bytecode file
        optimizer_runs: Number of optimizer runs (default: 3M for Foundry compatibility)
        optimizer_steps: Yul optimizer step sequence
        
    Returns:
        True if compilation succeeded, False otherwise
    """
    abs_yul_path = os.path.abspath(yul_path)
    if not os.path.exists(abs_yul_path):
        print(f"Error: File not found: {abs_yul_path}", file=sys.stderr)
        return False

    with open(abs_yul_path, 'r') as f:
        yul_content = f.read()

    # Foundry-compatible optimizer settings
    input_json = {
        "language": "Yul",
        "sources": {
            "contract.yul": {"content": yul_content}
        },
        "settings": {
            "optimizer": {
                "enabled": True,
                "runs": optimizer_runs,
                "details": {
                    "yul": True,
                    "cse": True,
                    "peephole": True,
                    "orderLiterals": True,
                    "deduplicate": True,
                    "constantOptimizer": True,
                    "jumpdestRemover": True,
                    "yulDetails": {
                        "stackAllocation": True,
                        "optimizerSteps": optimizer_steps
                    }
                }
            },
            "outputSelection": {
                "*": {"*": ["evm.bytecode.object"]}
            }
        }
    }

    try:
        process = subprocess.Popen(
            ["solc", "--standard-json"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        stdout, stderr = process.communicate(input=json.dumps(input_json))
        
        if process.returncode != 0:
            print(f"Solc failed: {stderr}", file=sys.stderr)
            return False

        output = json.loads(stdout)
        
        # Check for errors
        if "errors" in output:
            has_error = False
            for err in output["errors"]:
                if err["severity"] == "error":
                    print(f"Error: {err['formattedMessage']}", file=sys.stderr)
                    has_error = True
                else:
                    print(f"Warning: {err['formattedMessage']}", file=sys.stderr)
            if has_error:
                return False

        # Extract bytecode
        if "contracts" not in output or "contract.yul" not in output["contracts"]:
            print("Error: Could not find contract bytecode in output.", file=sys.stderr)
            return False
            
        contract_name = list(output["contracts"]["contract.yul"].keys())[0]
        bytecode = output["contracts"]["contract.yul"][contract_name]["evm"]["bytecode"]["object"]
        
        with open(output_path, 'w') as f:
            f.write(bytecode)
            
        print(f"✓ Bytecode written to {output_path} ({len(bytecode)//2} bytes)")
        return True

    except FileNotFoundError:
        print("Error: solc not found. Install with: brew install solidity", file=sys.stderr)
        return False
    except Exception as e:
        print(f"Exception during compilation: {e}", file=sys.stderr)
        return False


def main():
    parser = argparse.ArgumentParser(
        description="Compile Yul to EVM bytecode via solc standard-json"
    )
    parser.add_argument("input", help="Path to input .yul file")
    parser.add_argument("output", help="Path for output bytecode file")
    parser.add_argument(
        "--optimizer-runs", "-r",
        type=int,
        default=3_000_000,
        help="Number of optimizer runs (default: 3000000)"
    )
    args = parser.parse_args()
    
    success = compile_yul_standard_json(args.input, args.output, args.optimizer_runs)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
