#!/usr/bin/env python3.11
"""
Test workarounds for the CFG issue.
"""

import sys
from pathlib import Path

# Add paths
sys.path.insert(0, str(Path(__file__).parent.parent))
sys.path.insert(0, "/Users/harkal/projects/charles_cooper/repos/vyper")
sys.path.insert(0, str(Path(__file__).parent.parent / "vyper" / "cli"))

import yul as yul_module
from vyper.venom import generate_assembly_experimental
from vyper.compiler.settings import OptimizationLevel
from vyper.compiler.phases import generate_bytecode

def test_workarounds():
    """Test different Yul patterns that might work."""
    
    test_cases = [
        ("Direct code (no if)", """
            object "Test" {
                code {
                    let v := callvalue()
                    mstore(0, v)
                    return(0, 32)
                }
            }
        """),
        
        ("If with else", """
            object "Test" {
                code {
                    if callvalue() { 
                        revert(0, 0) 
                    } else {
                        mstore(0, 42)
                    }
                    return(0, 32)
                }
            }
        """),
        
        ("Multiple conditions (creates real join)", """
            object "Test" {
                code {
                    let x := callvalue()
                    if eq(x, 1) { mstore(0, 1) }
                    if eq(x, 2) { mstore(0, 2) }
                    return(0, 32)
                }
            }
        """),
        
        ("Using leave instead of revert", """
            object "Test" {
                code {
                    if callvalue() { leave }
                    mstore(0, 42)
                    return(0, 32)
                }
            }
        """),
    ]
    
    for name, yul_code in test_cases:
        print(f"\nTesting: {name}")
        print("-" * 40)
        
        try:
            # Parse Yul
            tree = yul_module.yul_parser.parse(yul_code)
            ast = yul_module.YulTransformer().transform(tree)
            
            if isinstance(ast, list) and len(ast) > 0:
                ast = ast[0]
            
            # Compile to Venom IR
            ctx = yul_module.compile_to_venom(ast)
            print(f"  ✓ Venom IR generated")
            
            # Generate assembly without optimization
            asm = generate_assembly_experimental(ctx, OptimizationLevel.NONE)
            print(f"  ✓ Assembly generated")
            
            # Generate bytecode
            bytecode, _ = generate_bytecode(asm)
            hex_bytecode = "0x" + bytecode.hex()
            print(f"  ✓ Bytecode: {hex_bytecode[:20]}...")
            
        except AssertionError as e:
            print(f"  ✗ AssertionError")
        except Exception as e:
            print(f"  ✗ {type(e).__name__}: {e}")

if __name__ == "__main__":
    test_workarounds()