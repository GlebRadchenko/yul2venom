#!/usr/bin/env python3
"""
Isolated test for invoke/ret calling convention using local IR module.
Tests that the calling convention between transpiler and backend is aligned.
"""

import sys
sys.path.insert(0, '.')

from ir.context import IRContext
from ir.function import IRFunction
from ir.basicblock import IRBasicBlock, IRInstruction, IRLabel, IRVariable, IRLiteral

def create_test_function():
    """
    Create a test function that simulates abi_decode:
    - Takes 1 arg (calldatasize), has PC on stack
    - Returns 2 values + PC
    
    Expected IR:
      %1 = param           ; arg (calldatasize)
      %2 = param           ; PC
      %3 = calldataload 4  ; return value 1
      %4 = calldataload 36 ; return value 2
      ret %3, %4, %2       ; multi-return
    """
    ctx = IRContext()
    
    fn = ctx.create_function(IRLabel("test_helper"))
    entry = fn.get_basic_block(fn.entry.label.value)
    
    # Params
    arg = entry.append_instruction("param")  # %1 = arg
    pc = entry.append_instruction("param")   # %2 = PC
    
    # Compute return values
    r1 = entry.append_instruction("calldataload", IRLiteral(4))
    r2 = entry.append_instruction("calldataload", IRLiteral(36))
    
    # ret with multi-return
    entry.append_instruction("ret", r1, r2, pc)
    
    return ctx, fn

def test_ir_structure():
    """Test that IR structure is correct."""
    print("=" * 60)
    print("TEST: IR Structure for multi-return function")
    print("=" * 60)
    
    ctx, fn = create_test_function()
    
    print("\n--- Generated IR ---")
    for bb in fn.get_basic_blocks():
        print(f"Block: {bb.label}")
        for inst in bb.instructions:
            print(f"  {inst}")
    
    # Verify structure
    entry = fn.entry
    insts = entry.instructions
    
    print("\n--- Verification ---")
    
    # Check params
    assert insts[0].opcode == "param", f"First inst should be param, got {insts[0].opcode}"
    assert insts[1].opcode == "param", f"Second inst should be param, got {insts[1].opcode}"
    print("✓ Params are first two instructions")
    
    # Check ret has 3 operands (val1, val2, pc)
    ret_inst = insts[-1]
    assert ret_inst.opcode == "ret", f"Last inst should be ret, got {ret_inst.opcode}"
    assert len(ret_inst.operands) == 3, f"ret should have 3 operands, got {len(ret_inst.operands)}"
    print(f"✓ ret has 3 operands: {ret_inst.operands}")
    
    # Check ret has no outputs (it's a terminator)
    outputs = ret_inst.get_outputs()
    assert len(outputs) == 0, f"ret should have no outputs, got {outputs}"
    print("✓ ret has no outputs (terminator)")
    
    return True

def test_invoke_structure():
    """Test invoke instruction structure."""
    print("\n" + "=" * 60)
    print("TEST: Invoke instruction structure")
    print("=" * 60)
    
    ctx = IRContext()
    
    # Create caller function
    caller = ctx.create_function(IRLabel("caller"))
    entry = caller.get_basic_block(caller.entry.label.value)
    
    # Setup
    entry.append_instruction("mstore", IRLiteral(64), IRLiteral(0x80))
    arg = entry.append_instruction("calldatasize")
    
    # Create invoke instruction manually with multi-return outputs
    invoke_inst = IRInstruction(
        "invoke",
        [IRLabel("helper"), arg],
        outputs=[IRVariable("%ret1"), IRVariable("%ret2")]
    )
    invoke_inst.parent = entry
    entry.instructions.append(invoke_inst)
    
    # Use returns
    entry.append_instruction("mstore", IRLiteral(0x80), invoke_inst.get_outputs()[0])
    entry.append_instruction("return", IRLiteral(0x80), IRLiteral(32))
    
    print("\n--- Generated IR ---")
    for bb in caller.get_basic_blocks():
        print(f"Block: {bb.label}")
        for inst in bb.instructions:
            print(f"  {inst}")
    
    # Verify invoke
    invoke = entry.instructions[2]  # mstore, calldatasize, invoke
    assert invoke.opcode == "invoke", f"Expected invoke, got {invoke.opcode}"
    
    print("\n--- Invoke Analysis ---")
    print(f"Operands: {invoke.operands}")
    print(f"  - Target: {invoke.operands[0]} (type: {type(invoke.operands[0]).__name__})")
    print(f"  - Args: {invoke.operands[1:]} (count: {len(invoke.operands) - 1})")
    print(f"Outputs: {invoke.get_outputs()} (count: {len(invoke.get_outputs())})")
    
    num_args = len(invoke.operands) - 1
    num_outputs = len(invoke.get_outputs())
    print(f"\n✓ invoke has {num_args} args and {num_outputs} outputs")
    
    # This is the key question: after invoke returns, what should be on stack?
    # Current broken logic expects: [args..., outputs...]
    # Correct behavior: [outputs...] (args consumed inside callee)
    print(f"\n--- Stack Expectation Analysis ---")
    print(f"After invoke returns, stack should have:")
    print(f"  - Outputs only: {invoke.get_outputs()}")
    print(f"  - Args are CONSUMED inside callee (not on stack)")
    
    return True

if __name__ == "__main__":
    try:
        test_ir_structure()
        test_invoke_structure()
        print("\n" + "=" * 60)
        print("ALL TESTS PASSED")
        print("=" * 60)
    except Exception as e:
        print(f"\nTEST FAILED: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
