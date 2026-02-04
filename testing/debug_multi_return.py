#!/usr/bin/env python3
"""
Multi-Return Function Debug Tool

Automated debugging for multi-return function issues in the Yul2Venom transpiler.
Traces ret/invoke operand ordering, simulates stack behavior, and correlates with test results.

Usage:
    python3 debug_multi_return.py [--config CONFIG] [--function FUNC] [--verbose]
    
Examples:
    python3 debug_multi_return.py --function fun_fibonacci
    python3 debug_multi_return.py --config configs/MultiReturnTest.yul2venom.json
    
Features:
    1. Traces ret operand ordering in raw vs optimized IR
    2. Simulates stack behavior through invoke/ret cycles
    3. Runs forge tests and extracts actual vs expected values
    4. Identifies specific ordering/reversal issues
"""

import sys
import os
import argparse
import subprocess
import re
import json
from dataclasses import dataclass, field
from typing import List, Dict, Optional, Tuple

# Setup path for imports
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
VYPER_PATH = os.path.join(PROJECT_ROOT, "vyper")
sys.path.insert(0, PROJECT_ROOT)
sys.path.insert(0, VYPER_PATH)


@dataclass
class RetInfo:
    """Information about a ret instruction."""
    block: str
    display_operands: List[str]  # As displayed in IR
    internal_operands: List[str]  # Reversed (actual internal order)
    is_base_case: bool = False
    
@dataclass
class InvokeInfo:
    """Information about an invoke instruction."""
    block: str
    target: str
    args: List[str]
    outputs: List[str]
    is_internal: bool = False  # True if inside user function, False if in __main_entry

@dataclass
class FunctionAnalysis:
    """Analysis results for a function."""
    name: str
    rets: List[RetInfo] = field(default_factory=list)
    invokes: List[InvokeInfo] = field(default_factory=list)
    return_count: int = 0

@dataclass
class TestResult:
    """Test case result."""
    input_n: int
    expected_a: int
    expected_b: int
    actual_a: int
    actual_b: int
    matches: bool


def parse_vnm_file(vnm_path: str) -> Dict[str, FunctionAnalysis]:
    """Parse a .vnm file and extract ret/invoke information."""
    
    if not os.path.exists(vnm_path):
        print(f"ERROR: File not found: {vnm_path}")
        return {}
    
    with open(vnm_path, 'r') as f:
        content = f.read()
    
    results = {}
    current_function = None
    current_block = None
    
    for line in content.split('\n'):
        line = line.strip()
        
        # Function declaration
        if line.startswith('function '):
            match = re.match(r'function\s+(\S+)', line)
            if match:
                current_function = match.group(1)
                results[current_function] = FunctionAnalysis(name=current_function)
        
        # Block label
        if ':' in line and not line.startswith('%') and not line.startswith('#'):
            block_match = re.match(r'(\S+):', line)
            if block_match:
                current_block = block_match.group(1)
        
        # ret instruction
        if 'ret ' in line or line.startswith('ret '):
            if current_function and current_block:
                # Extract operands from display format: ret %PC, %val1, %val2
                ret_match = re.search(r'ret\s+(.+)', line)
                if ret_match:
                    operands_str = ret_match.group(1)
                    # Split on comma, handling possible spaces
                    display_ops = [op.strip() for op in operands_str.split(',')]
                    
                    # Internal order is reversed (except for control flow)
                    # For ret: display [PC, val1, val2] → internal [val2, val1, PC]
                    internal_ops = list(reversed(display_ops))
                    
                    is_base = 'then' in current_block.lower() or '1_then' in current_block
                    
                    ret_info = RetInfo(
                        block=current_block,
                        display_operands=display_ops,
                        internal_operands=internal_ops,
                        is_base_case=is_base
                    )
                    results[current_function].rets.append(ret_info)
        
        # invoke instruction
        if 'invoke @' in line:
            if current_function:
                # Match: %out1, %out2 = invoke @target, %arg1 OR just invoke @target, %arg
                invoke_match = re.search(r'((?:%\d+(?:,\s*%\d+)*)\s*=\s*)?invoke\s+@(\S+)(?:,\s*(.+))?', line)
                if invoke_match:
                    outputs_str = invoke_match.group(1)
                    target = invoke_match.group(2)
                    args_str = invoke_match.group(3) or ""
                    
                    outputs = []
                    if outputs_str:
                        outputs_str = outputs_str.replace('=', '').strip()
                        outputs = [o.strip() for o in outputs_str.split(',')]
                    
                    args = [a.strip() for a in args_str.split(',')] if args_str else []
                    
                    is_internal = not current_function.startswith('__')
                    
                    invoke_info = InvokeInfo(
                        block=current_block,
                        target=target,
                        args=args,
                        outputs=outputs,
                        is_internal=is_internal
                    )
                    results[current_function].invokes.append(invoke_info)
    
    return results


def compare_raw_vs_opt(raw_path: str, opt_path: str, function: str) -> Dict:
    """Compare raw and optimized IR for a specific function."""
    raw = parse_vnm_file(raw_path)
    opt = parse_vnm_file(opt_path)
    
    comparison = {
        "function": function,
        "raw": raw.get(function),
        "opt": opt.get(function),
        "issues": []
    }
    
    raw_fn = raw.get(function)
    opt_fn = opt.get(function)
    
    if not raw_fn or not opt_fn:
        comparison["issues"].append(f"Function {function} not found in one or both IR files")
        return comparison
    
    # Compare ret count
    if len(raw_fn.rets) != len(opt_fn.rets):
        comparison["issues"].append(
            f"Ret count mismatch: raw={len(raw_fn.rets)}, opt={len(opt_fn.rets)}"
        )
    
    # Compare ret operand ordering
    for i, (raw_ret, opt_ret) in enumerate(zip(raw_fn.rets, opt_fn.rets)):
        if raw_ret.display_operands != opt_ret.display_operands:
            comparison["issues"].append(
                f"Ret #{i} operand order changed: raw={raw_ret.display_operands}, opt={opt_ret.display_operands}"
            )
    
    # Check invoke output counts
    for i, (raw_inv, opt_inv) in enumerate(zip(raw_fn.invokes, opt_fn.invokes)):
        if raw_inv.outputs != opt_inv.outputs:
            comparison["issues"].append(
                f"Invoke #{i} outputs changed: raw={raw_inv.outputs}, opt={opt_inv.outputs}"
            )
    
    return comparison


def simulate_stack_after_ret(ret_info: RetInfo) -> Tuple[str, str]:
    """
    Simulate stack state after a ret instruction.
    
    Returns (TOS_value, below_TOS_value) based on internal operand order.
    Internal order: [val2, val1, PC] means stack is [..., val2, val1, PC]
    After JUMP: [..., val2, val1] with val1 at TOS
    """
    internal = ret_info.internal_operands
    if len(internal) < 3:
        return ("?", "?")
    
    # Internal: [val2, val1, PC]
    # After JUMP consumes PC: [val2, val1] with val1 at TOS
    tos = internal[-2]  # val1
    below = internal[-3] if len(internal) >= 3 else "?"  # val2
    
    return (tos, below)


def run_forge_test(test_name: str = "fibDirect") -> List[TestResult]:
    """Run forge test and extract results."""
    
    # Expected Fibonacci values from Solidity definition
    # fib(0) = (0, 1), fib(1) = (1, 1), fib(2) = (1, 2), etc.
    expected = {
        0: (0, 1),
        1: (1, 1),
        2: (1, 2),
        3: (2, 3),
        4: (3, 5),
        5: (5, 8),
    }
    
    os.chdir(os.path.join(PROJECT_ROOT, "foundry"))
    
    try:
        result = subprocess.run(
            ["forge", "test", "--match-test", test_name, "-vvv"],
            capture_output=True,
            text=True,
            timeout=60
        )
        output = result.stdout + result.stderr
    except Exception as e:
        print(f"Error running forge test: {e}")
        return []
    
    os.chdir(PROJECT_ROOT)
    
    results = []
    
    # Parse output: fib(0) = (0, 1)
    for match in re.finditer(r'fib\((\d+)\)\s*=\s*\((\d+),\s*(\d+)\)', output):
        n = int(match.group(1))
        actual_a = int(match.group(2))
        actual_b = int(match.group(3))
        
        exp_a, exp_b = expected.get(n, (None, None))
        
        results.append(TestResult(
            input_n=n,
            expected_a=exp_a,
            expected_b=exp_b,
            actual_a=actual_a,
            actual_b=actual_b,
            matches=(exp_a == actual_a and exp_b == actual_b)
        ))
    
    return results


def analyze_value_flow(opt_analysis: FunctionAnalysis) -> Dict:
    """Analyze value flow through invokes and rets."""
    
    flow = {
        "invoke_output_assignments": [],
        "ret_value_sources": [],
        "recommendations": []
    }
    
    for invoke in opt_analysis.invokes:
        flow["invoke_output_assignments"].append({
            "target": invoke.target,
            "outputs": invoke.outputs,
            "is_internal": invoke.is_internal,
            "note": "Internal invoke - outputs should be REVERSED for correct mapping" if invoke.is_internal else "Top-level - no reversal needed"
        })
    
    for ret in opt_analysis.rets:
        stack_tos, stack_below = simulate_stack_after_ret(ret)
        flow["ret_value_sources"].append({
            "block": ret.block,
            "display": ret.display_operands,
            "internal": ret.internal_operands,
            "stack_after": f"[..., {stack_below}, {stack_tos}] with {stack_tos} at TOS",
            "is_base_case": ret.is_base_case
        })
    
    return flow


def trace_ret_stack_behavior(raw_path: str, opt_path: str, function: str) -> Dict:
    """
    Deep trace of ret stack behavior comparing raw vs optimized.
    This helps identify where stack ordering gets corrupted.
    """
    trace = {
        "base_case": None,
        "recursive_case": None,
        "stack_order_issue": None
    }
    
    opt = parse_vnm_file(opt_path)
    opt_fn = opt.get(function)
    
    if not opt_fn:
        return trace
    
    for ret in opt_fn.rets:
        internal = ret.internal_operands
        
        case_info = {
            "block": ret.block,
            "display": ret.display_operands,
            "internal": internal,
        }
        
        if len(internal) >= 3:
            # Internal order: [val_last, val_first, PC]
            # After JUMP: [val_last, val_first] with val_first at TOS
            val_first = internal[-2]  # This ends up at TOS
            val_last = internal[-3]   # This is below TOS
            
            case_info["stack_tos"] = val_first
            case_info["stack_below"] = val_last
            case_info["explanation"] = f"Stack after ret: [{val_last}, {val_first}] → TOS={val_first}"
            
            # For caller:
            # outputs[0] = below (stack[-2]) = val_last
            # outputs[1] = TOS (stack[-1]) = val_first
            case_info["caller_outputs_0"] = f"{val_last} (first declared var without reversal)"
            case_info["caller_outputs_1"] = f"{val_first} (second declared var without reversal)"
        
        if ret.is_base_case:
            trace["base_case"] = case_info
        else:
            trace["recursive_case"] = case_info
    
    # Detect potential ordering issues
    if trace["base_case"] and trace["recursive_case"]:
        base_internal = trace["base_case"]["internal"]
        rec_internal = trace["recursive_case"]["internal"]
        
        # Check if the non-PC operands are in different relative positions
        if len(base_internal) >= 3 and len(rec_internal) >= 3:
            # If the ordering patterns differ, that's an issue
            trace["stack_order_issue"] = "Checking for asymmetric stack ordering..."
    
    return trace


def full_debug(config_path: str = None, function: str = "fun_fibonacci", verbose: bool = True):
    """Run full debug analysis."""
    
    raw_ir = os.path.join(PROJECT_ROOT, "debug", "raw_ir.vnm")
    opt_ir = os.path.join(PROJECT_ROOT, "debug", "opt_ir.vnm")
    
    print("=" * 70)
    print("MULTI-RETURN DEBUG ANALYSIS")
    print("=" * 70)
    
    # 1. Parse and compare IR
    print(f"\n[1/4] Parsing IR files for function: {function}")
    
    raw_analysis = parse_vnm_file(raw_ir)
    opt_analysis = parse_vnm_file(opt_ir)
    
    raw_fn = raw_analysis.get(function)
    opt_fn = opt_analysis.get(function)
    
    if not raw_fn:
        print(f"  ⚠ Function {function} not found in raw IR")
    else:
        print(f"  ✓ Raw IR: {len(raw_fn.rets)} ret(s), {len(raw_fn.invokes)} invoke(s)")
    
    if not opt_fn:
        print(f"  ⚠ Function {function} not found in optimized IR")
    else:
        print(f"  ✓ Opt IR: {len(opt_fn.rets)} ret(s), {len(opt_fn.invokes)} invoke(s)")
    
    # 2. Compare raw vs optimized
    print(f"\n[2/4] Comparing raw vs optimized IR")
    comparison = compare_raw_vs_opt(raw_ir, opt_ir, function)
    
    if comparison["issues"]:
        print("  ⚠ Issues found:")
        for issue in comparison["issues"]:
            print(f"    - {issue}")
    else:
        print("  ✓ No structural differences detected")
    
    # 3. Analyze value flow
    print(f"\n[3/4] Analyzing value flow")
    
    if opt_fn:
        flow = analyze_value_flow(opt_fn)
        
        print("\n  RET Instructions:")
        for ret in flow["ret_value_sources"]:
            marker = "📦 BASE" if ret["is_base_case"] else "🔄 RECURSIVE"
            print(f"    {marker} {ret['block']}:")
            print(f"      Display: ret {', '.join(ret['display'])}")
            print(f"      Internal: [{', '.join(ret['internal'])}]")
            print(f"      Stack: {ret['stack_after']}")
        
        print("\n  INVOKE Instructions:")
        for inv in flow["invoke_output_assignments"]:
            marker = "🔗 INTERNAL" if inv["is_internal"] else "📤 TOP-LEVEL"
            print(f"    {marker} @{inv['target']}:")
            print(f"      Outputs: {inv['outputs']}")
            print(f"      Note: {inv['note']}")
        
        # Deep stack trace
        print("\n  Stack Trace (Caller's View):")
        stack_trace = trace_ret_stack_behavior(raw_ir, opt_ir, function)
        
        if stack_trace.get("base_case"):
            bc = stack_trace["base_case"]
            print(f"    📦 BASE CASE ({bc['block']}):")
            print(f"      {bc.get('explanation', 'N/A')}")
            print(f"      → Caller outputs[0] = {bc.get('caller_outputs_0', '?')}")
            print(f"      → Caller outputs[1] = {bc.get('caller_outputs_1', '?')}")
        
        if stack_trace.get("recursive_case"):
            rc = stack_trace["recursive_case"]
            print(f"    🔄 RECURSIVE CASE ({rc['block']}):")
            print(f"      {rc.get('explanation', 'N/A')}")
            print(f"      → Caller outputs[0] = {rc.get('caller_outputs_0', '?')}")
            print(f"      → Caller outputs[1] = {rc.get('caller_outputs_1', '?')}")
    
    # 4. Run test and compare
    print(f"\n[4/4] Running Forge tests")
    
    test_results = run_forge_test()
    
    if test_results:
        print("\n  Test Results:")
        print("  " + "-" * 60)
        print("  {:>4} | {:>12} | {:>12} | {}".format("N", "Expected", "Actual", "Status"))
        print("  " + "-" * 60)
        
        for tr in test_results:
            status = "✓ PASS" if tr.matches else "✗ FAIL"
            expected = f"({tr.expected_a}, {tr.expected_b})"
            actual = f"({tr.actual_a}, {tr.actual_b})"
            print("  {:>4} | {:>12} | {:>12} | {}".format(
                tr.input_n, expected, actual, status
            ))
        
        # Analyze failure pattern
        failures = [tr for tr in test_results if not tr.matches]
        if failures:
            print(f"\n  ⚠ {len(failures)}/{len(test_results)} tests failed")
            
            # Detect patterns
            patterns = []
            
            # Check if values are swapped
            swapped = all(
                (tr.expected_a == tr.actual_b and tr.expected_b == tr.actual_a)
                for tr in failures
            )
            if swapped:
                patterns.append("Values are SWAPPED (a↔b)")
            
            # Check if second value is consistently wrong
            second_wrong = all(
                tr.expected_a == tr.actual_a and tr.expected_b != tr.actual_b
                for tr in failures
            )
            if second_wrong:
                patterns.append("Second return value (b) is consistently wrong")
            
            # Check offset pattern
            if len(failures) >= 2:
                offsets = [tr.expected_a - tr.actual_a for tr in failures]
                if len(set(offsets)) == 1 and offsets[0] != 0:
                    patterns.append(f"First value offset by {offsets[0]}")
            
            if patterns:
                print("\n  Detected patterns:")
                for p in patterns:
                    print(f"    → {p}")
        else:
            print(f"\n  ✓ All {len(test_results)} tests passed!")
    else:
        print("  ⚠ Could not extract test results")
    
    print("\n" + "=" * 70)
    print("DEBUG ANALYSIS COMPLETE")
    print("=" * 70)
    
    return {
        "raw": raw_fn,
        "opt": opt_fn,
        "comparison": comparison,
        "test_results": test_results
    }


def main():
    parser = argparse.ArgumentParser(
        description="Multi-Return Function Debug Tool",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    python3 debug_multi_return.py
    python3 debug_multi_return.py --function fun_fibonacci
    python3 debug_multi_return.py --verbose
        """
    )
    parser.add_argument(
        "--function", "-f",
        default="fun_fibonacci",
        help="Function name to analyze (default: fun_fibonacci)"
    )
    parser.add_argument(
        "--config", "-c",
        help="Config file to transpile first (optional)"
    )
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Enable verbose output"
    )
    args = parser.parse_args()
    
    # If config provided, run transpilation first
    if args.config:
        print(f"Transpiling {args.config}...")
        os.chdir(PROJECT_ROOT)
        result = subprocess.run(
            ["python3.11", "yul2venom.py", "transpile", args.config, "--runtime-only"],
            capture_output=True,
            text=True
        )
        if "Failed" in result.stdout or "Error" in result.stdout:
            print(f"Transpilation failed:\n{result.stdout}")
            sys.exit(1)
        
        # Copy binary for forge
        subprocess.run([
            "cp", 
            "output/MultiReturnTest_opt.bin", 
            "output/MultiReturnTest_opt_runtime.bin"
        ])
        print("✓ Transpilation complete")
    
    full_debug(function=args.function, verbose=args.verbose)


if __name__ == "__main__":
    main()
