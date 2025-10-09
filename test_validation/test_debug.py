#!/usr/bin/env python3.11
"""
Debug test to isolate the assertion error.
"""
from yul_to_venom.cli import yul as yul_module
from vyper.compiler.settings import OptimizationLevel
from vyper.venom import generate_assembly_experimental

def test_patterns():
    """Test different Yul patterns to find the issue."""
    
    test_cases = [
        ("Simple", """
            object "Test" {
                code {
                    mstore(0, 42)
                    return(0, 32)
                }
            }
        """),
        
        ("With if", """
            object "Test" {
                code {
                    if callvalue() { revert(0, 0) }
                    mstore(0, 42)
                    return(0, 32)
                }
            }
        """),
        
        ("With function", """
            object "Test" {
                code {
                    helper()
                    return(0, 32)
                    
                    function helper() {
                        mstore(0, 42)
                    }
                }
            }
        """),
        
        ("With switch", """
            object "Test" {
                code {
                    let x := 1
                    switch x
                    case 0 { mstore(0, 0) }
                    case 1 { mstore(0, 42) }
                    default { mstore(0, 99) }
                    return(0, 32)
                }
            }
        """),
        
        ("With nested object", """
            object "Test" {
                code {
                    datacopy(0, dataoffset("runtime"), datasize("runtime"))
                    return(0, datasize("runtime"))
                }
                object "runtime" {
                    code {
                        mstore(0, 42)
                        return(0, 32)
                    }
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
            print(f"  ✓ Assembly generated: {len(asm)} instructions")
            
        except AssertionError as e:
            print(f"  ✗ AssertionError: {e}")
            import traceback
            tb = traceback.extract_tb(e.__traceback__)
            for frame in tb:
                if "venom_to_assembly.py" in frame.filename:
                    print(f"     at line {frame.lineno}: {frame.line}")
        except Exception as e:
            print(f"  ✗ Error: {type(e).__name__}: {e}")

if __name__ == "__main__":
    test_patterns()
