#!/usr/bin/env python3
"""
Trace Memory Operations - Analyze memory operations in Venom IR.

Usage:
    python3 trace_memory.py <vnm_file> [--verbose]
    
Parses Venom IR and traces mstore/mload operations, phi nodes,
and loop back-edge patterns useful for debugging memory issues.
"""

import sys
import os
import argparse
import re


def parse_blocks(vnm_source: str) -> dict:
    """Parse Venom IR source into basic blocks."""
    blocks = {}
    current_block = None
    current_instrs = []
    
    for line in vnm_source.split('\n'):
        line = line.strip()
        if not line or line.startswith(';') or line.startswith('function'):
            continue
        if line.startswith('}'):
            if current_block:
                blocks[current_block] = current_instrs
            continue
            
        # Block label
        if line.endswith(':'):
            if current_block:
                blocks[current_block] = current_instrs
            current_block = line[:-1].split()[0]
            current_instrs = []
            continue
            
        current_instrs.append(line)
    
    if current_block:
        blocks[current_block] = current_instrs
    
    return blocks


def analyze_memory(vnm_source: str, verbose: bool = True) -> dict:
    """
    Analyze memory operations in Venom IR.
    
    Args:
        vnm_source: Venom IR source code
        verbose: Print detailed output
        
    Returns:
        Dict with analysis results
    """
    blocks = parse_blocks(vnm_source)
    
    results = {
        "block_count": len(blocks),
        "mstore_ops": [],
        "mload_ops": [],
        "phi_nodes": [],
        "identity_ops": [],
        "increment_ops": []
    }
    
    if verbose:
        print(f"Parsed {len(blocks)} blocks")
        for name in list(blocks.keys())[:10]:
            print(f"  - {name}: {len(blocks[name])} instructions")
    
    # Find memory operations
    if verbose:
        print("\n=== Memory Store Operations ===")
    for block_name, instrs in blocks.items():
        for instr in instrs:
            if 'mstore' in instr.lower():
                results["mstore_ops"].append({"block": block_name, "instr": instr})
                if verbose:
                    print(f"[{block_name}] {instr}")
    
    if verbose:
        print(f"Total mstore: {len(results['mstore_ops'])}")
    
    # Find phi nodes
    if verbose:
        print("\n=== Phi Nodes ===")
    for block_name, instrs in blocks.items():
        for instr in instrs:
            if '= phi' in instr:
                results["phi_nodes"].append({"block": block_name, "instr": instr})
                if verbose:
                    print(f"[{block_name}] {instr}")
    
    if verbose:
        print(f"Total phi: {len(results['phi_nodes'])}")
    
    # Track loop back-edge patterns
    if verbose:
        print("\n=== Loop Back-Edge Variables ===")
    for block_name, instrs in blocks.items():
        if 'loop_post' in block_name or 'end_if' in block_name:
            for instr in instrs:
                if '= add' in instr and ', 0' in instr:
                    results["identity_ops"].append({"block": block_name, "instr": instr})
                    if verbose:
                        print(f"[{block_name}] IDENTITY: {instr}")
                elif '= add' in instr and ', 1' in instr:
                    results["increment_ops"].append({"block": block_name, "instr": instr})
                    if verbose:
                        print(f"[{block_name}] INCREMENT: {instr}")
    
    return results


def main():
    parser = argparse.ArgumentParser(
        description="Analyze memory operations in Venom IR"
    )
    parser.add_argument("vnm_file", help="Path to .vnm file")
    parser.add_argument(
        "--quiet", "-q",
        action="store_true",
        help="Suppress detailed output"
    )
    args = parser.parse_args()
    
    if not os.path.exists(args.vnm_file):
        print(f"Error: File not found: {args.vnm_file}", file=sys.stderr)
        sys.exit(1)
    
    with open(args.vnm_file, 'r') as f:
        source = f.read()
    
    print(f"Analyzing: {args.vnm_file} ({len(source)} bytes)")
    print("=" * 60)
    
    results = analyze_memory(source, verbose=not args.quiet)
    
    print(f"\n✓ Analysis complete: {results['block_count']} blocks, "
          f"{len(results['mstore_ops'])} mstore, {len(results['phi_nodes'])} phi nodes")


if __name__ == "__main__":
    main()
