#!/usr/bin/env python3.11
"""
Test the validation infrastructure with known working Yul code.
"""
import sys

from test_validation.runners.yul_transpiler import YulTranspiler
from test_validation.validators.execution_validator import ExecutionValidator, ValidationResult

def test_known_yul():
    """Test with Yul code we know works."""
    
    # Simple Yul that we've tested before
    yul_code = """
    object "Test" {
        code {
            mstore(0, 42)
            return(0, 32)
        }
    }
    """
    
    print("Testing validation infrastructure...")
    print("=" * 50)
    
    # Initialize components
    transpiler = YulTranspiler()
    validator = ExecutionValidator()
    
    print("\n1. Testing YulTranspiler...")
    try:
        # Compile to bytecode (with optimization disabled)
        bytecode = transpiler.compile_yul_to_bytecode(yul_code, optimize=False)
        print(f"   [OK] Bytecode generated: {bytecode[:100]}...")
    except Exception as e:
        print(f"   [FAIL] Failed: {e}")
        return False
    
    print("\n2. Testing ExecutionValidator...")
    try:
        # Validate bytecode against itself (should pass)
        report = validator.validate_simple_bytecode(bytecode, bytecode)
        print(f"   [OK] Deployment validation: {report.status.value}")
        print(f"     Message: {report.message}")
    except Exception as e:
        print(f"   [FAIL] Failed: {e}")
        return False
    
    print("\n3. Testing Venom IR generation...")
    try:
        venom_ir = transpiler.compile_yul_to_venom_ir(yul_code)
        print(f"   [OK] Venom IR generated ({len(venom_ir)} chars)")
    except Exception as e:
        print(f"   [FAIL] Failed: {e}")
        return False
    
    print("\n4. Testing assembly generation...")
    try:
        asm = transpiler.compile_yul_to_assembly(yul_code, optimize=False)
        print(f"   [OK] Assembly generated ({len(asm)} chars)")
    except Exception as e:
        print(f"   [FAIL] Failed: {e}")
        return False
    
    print("\n" + "=" * 50)
    print("All infrastructure tests passed!")
    return True

if __name__ == "__main__":
    success = test_known_yul()
    sys.exit(0 if success else 1)
