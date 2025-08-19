#!/usr/bin/env python3.11
"""
Test to examine the Venom IR structure for problematic patterns.
"""

import sys
from pathlib import Path

# Add paths
sys.path.insert(0, str(Path(__file__).parent.parent))
sys.path.insert(0, "/Users/harkal/projects/charles_cooper/repos/vyper")
sys.path.insert(0, str(Path(__file__).parent.parent / "vyper" / "cli"))

import yul as yul_module

def examine_venom_ir():
    """Examine the Venom IR for the problematic if pattern."""
    
    yul_code = """
        object "Test" {
            code {
                if callvalue() { revert(0, 0) }
                mstore(0, 42)
                return(0, 32)
            }
        }
    """
    
    print("Yul Code:")
    print(yul_code)
    print("\n" + "="*50 + "\n")
    
    # Parse Yul
    tree = yul_module.yul_parser.parse(yul_code)
    ast = yul_module.YulTransformer().transform(tree)
    
    if isinstance(ast, list) and len(ast) > 0:
        ast = ast[0]
    
    # Compile to Venom IR
    ctx = yul_module.compile_to_venom(ast)
    
    print("Venom IR:")
    print(str(ctx))
    print("\n" + "="*50 + "\n")
    
    # Analyze the CFG structure
    print("CFG Analysis:")
    for fn_name, fn in ctx.functions.items():
        print(f"\nFunction: {fn_name}")
        for bb in fn.get_basic_blocks():
            print(f"  Block: {bb.label}")
            print(f"    Instructions: {len(bb.instructions)}")
            
            # Show the last instruction (usually control flow)
            if bb.instructions:
                last_inst = bb.instructions[-1]
                print(f"    Terminator: {last_inst.opcode}")
                if last_inst.opcode in ["jmp", "jnz"]:
                    print(f"    Operands: {last_inst.operands}")

if __name__ == "__main__":
    examine_venom_ir()