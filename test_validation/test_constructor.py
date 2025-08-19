#!/usr/bin/env python3
"""
Test Yul constructor transpilation to Venom.
Tests that constructor functions are properly handled when converting from Yul to Venom IR.
"""

import sys
from pathlib import Path

# Add paths
sys.path.insert(0, str(Path(__file__).parent.parent))
sys.path.insert(0, "/Users/harkal/projects/charles_cooper/repos/vyper")

from test_validation.runners.yul_transpiler import YulTranspiler
from test_validation.validators.execution_validator import ExecutionValidator
from test_validation.revm_environment import RevmEnvironment

def test_constructor_with_storage():
    """Test constructor that stores a value in storage."""
    
    print("\nTesting Constructor with Storage...")
    print("=" * 60)
    
    # Load the Yul fixture
    fixture_path = Path(__file__).parent / "fixtures" / "yul" / "constructor_storage.yul"
    with open(fixture_path, 'r') as f:
        yul_code = f.read()
    
    transpiler = YulTranspiler()
    
    # Test 1: Compile to Venom IR and check structure
    print("\n1. Compiling to Venom IR...")
    try:
        venom_ir = transpiler.compile_yul_to_venom_ir(yul_code)
        print(f"   ✓ Venom IR generated successfully")
        
        # Check that constructor function exists in IR
        if "constructor_StorageTest" in venom_ir:
            print(f"   ✓ Constructor function found in Venom IR")
        else:
            print(f"   ✗ Constructor function NOT found in Venom IR")
            return False
            
    except Exception as e:
        print(f"   ✗ Failed to generate Venom IR: {e}")
        return False
    
    # Test 2: Compile to bytecode
    print("\n2. Compiling to bytecode...")
    try:
        bytecode = transpiler.compile_yul_to_bytecode(yul_code)
        print(f"   ✓ Bytecode generated: {(len(bytecode)-2)//2} bytes")  # -2 for 0x prefix
        print(f"   Bytecode: {bytecode[:100]}...")
    except Exception as e:
        print(f"   ✗ Failed to compile: {e}")
        return False
    
    # Test 3: Deploy and test execution
    print("\n3. Deploying and testing contract execution...")
    try:
        # Initialize REVM environment
        env = RevmEnvironment()
        
        # Deploy the contract (constructor runs here)
        try:
            success, contract_address = env.deploy_contract(bytecode)
        except Exception as deploy_error:
            print(f"   ✗ Deployment error: {deploy_error}")
            import traceback
            traceback.print_exc()
            return False
        
        if not success or not contract_address:
            print(f"   ✗ Deployment failed (success={success}, address={contract_address})")
            return False
            
        print(f"   ✓ Contract deployed at: {contract_address}")
        
        # Call the contract with empty calldata to retrieve the stored value
        # We need to use the low-level message call since our contract doesn't have function selectors
        from eth_utils import to_bytes
        
        # Empty calldata for our simple getter
        call_result = env.evm.message_call(
            caller="0x1000000000000000000000000000000000000001",  # deployer address
            to=contract_address,
            value=0,
            calldata=b"",  # Empty calldata
            gas=100000,
            is_static=False
        )
        
        if call_result is None:
            print(f"   ✗ Contract call failed")
            return False
        
        # Convert bytes result to hex string for parsing
        return_data_hex = call_result.hex()
        
        # Convert hex to integer (32 bytes = 64 hex chars)
        if len(return_data_hex) == 64:
            returned_value = int(return_data_hex, 16)
            expected_value = 42
            
            if returned_value == expected_value:
                print(f"   ✓ Constructor correctly stored value: {returned_value}")
            else:
                print(f"   ✗ Wrong value returned: got {returned_value}, expected {expected_value}")
                return False
        else:
            print(f"   ✗ Unexpected return data length: {len(return_data_hex)} chars")
            print(f"   Return data: {return_data_hex}")
            return False
            
    except Exception as e:
        print(f"   ✗ Execution test failed: {e}")
        import traceback
        traceback.print_exc()
        return False
    
    print("\n✓ All constructor tests passed!")
    return True

def test_constructor_with_parameters():
    """Test constructor that takes parameters (future test)."""
    # This would test a more complex constructor with parameters
    pass

if __name__ == "__main__":
    success = test_constructor_with_storage()
    sys.exit(0 if success else 1)