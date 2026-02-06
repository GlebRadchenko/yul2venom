#!/usr/bin/env python3
"""Debug multi-return call/ret ordering by correlating IR with forge output."""

import sys
import os
import argparse
import subprocess
import re
import shutil
from dataclasses import dataclass, field
from typing import Any, Dict, List, Tuple

# Setup path for imports
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
VYPER_PATH = os.path.join(PROJECT_ROOT, "vyper")
sys.path.insert(0, PROJECT_ROOT)
sys.path.insert(0, VYPER_PATH)

RAW_IR_PATH = os.path.join(PROJECT_ROOT, "debug", "raw_ir.vnm")
OPT_IR_PATH = os.path.join(PROJECT_ROOT, "debug", "opt_ir.vnm")
FOUNDRY_DIR = os.path.join(PROJECT_ROOT, "foundry")
MULTI_RET_BIN = os.path.join(PROJECT_ROOT, "output", "MultiReturnTest_opt.bin")
MULTI_RET_RUNTIME_BIN = os.path.join(PROJECT_ROOT, "output", "MultiReturnTest_opt_runtime.bin")

FUNCTION_PATTERN = re.compile(r"function\s+(\S+)")
BLOCK_PATTERN = re.compile(r"(\S+):")
RET_PATTERN = re.compile(r"ret\s+(.+)")
INVOKE_PATTERN = re.compile(
    r"((?:%\d+(?:,\s*%\d+)*)\s*=\s*)?invoke\s+@(\S+)(?:,\s*(.+))?"
)
FORGE_PASS_PATTERN = re.compile(r"\[PASS\]\s+([^\s(]+)\(\)\s+\(gas:\s*(\d+)\)")
FORGE_FAIL_PATTERN = re.compile(r"\[FAIL[^\]]*\]\s+([^\s(]+)\(\)")


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
class ForgeTestResult:
    """Parsed forge test result."""
    name: str
    passed: bool
    gas: int | None = None
    details: str = ""


def _extract_function_name(line: str) -> str | None:
    match = FUNCTION_PATTERN.match(line)
    return match.group(1) if match else None


def _extract_block_label(line: str) -> str | None:
    if ":" not in line or line.startswith("%") or line.startswith("#"):
        return None
    match = BLOCK_PATTERN.match(line)
    return match.group(1) if match else None


def _parse_ret_info(line: str, current_block: str) -> RetInfo | None:
    match = RET_PATTERN.search(line)
    if not match:
        return None
    display_ops = [op.strip() for op in match.group(1).split(",")]
    return RetInfo(
        block=current_block,
        display_operands=display_ops,
        internal_operands=list(reversed(display_ops)),
        is_base_case=("then" in current_block.lower() or "1_then" in current_block),
    )


def _parse_invoke_info(
    line: str, current_function: str, current_block: str | None
) -> InvokeInfo | None:
    match = INVOKE_PATTERN.search(line)
    if not match:
        return None

    outputs_str = (match.group(1) or "").replace("=", "").strip()
    outputs = [item.strip() for item in outputs_str.split(",")] if outputs_str else []
    args_str = match.group(3) or ""
    args = [item.strip() for item in args_str.split(",")] if args_str else []

    return InvokeInfo(
        block=current_block or "<unknown>",
        target=match.group(2),
        args=args,
        outputs=outputs,
        is_internal=not current_function.startswith("__"),
    )


def parse_vnm_file(vnm_path: str) -> Dict[str, FunctionAnalysis]:
    """Parse a .vnm file and extract ret/invoke information."""
    
    if not os.path.exists(vnm_path):
        print(f"ERROR: File not found: {vnm_path}")
        return {}
    
    with open(vnm_path, "r") as f:
        content = f.read()
    
    results = {}
    current_function = None
    current_block = None
    
    for line in content.split("\n"):
        line = line.strip()

        fn_name = _extract_function_name(line)
        if fn_name:
            current_function = fn_name
            results[current_function] = FunctionAnalysis(name=current_function)
            continue

        block_name = _extract_block_label(line)
        if block_name:
            current_block = block_name

        if current_function and current_block and "ret " in line:
            ret_info = _parse_ret_info(line, current_block)
            if ret_info:
                results[current_function].rets.append(ret_info)

        if current_function and "invoke @" in line:
            invoke_info = _parse_invoke_info(line, current_function, current_block)
            if invoke_info:
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


def run_forge_test(test_filter: str | None = None) -> List[ForgeTestResult]:
    """Run forge tests for MultiReturnTest suite and parse test case results."""
    try:
        cmd = ["forge", "test", "--match-path", "test/MultiReturnTest.t.sol", "-vv"]
        if test_filter:
            cmd.extend(["--match-test", test_filter])
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=60,
            cwd=FOUNDRY_DIR,
        )
        output = result.stdout + result.stderr
    except Exception as e:
        print(f"Error running forge test: {e}")
        return []

    pass_results = {
        match.group(1): ForgeTestResult(
            name=match.group(1), passed=True, gas=int(match.group(2))
        )
        for match in FORGE_PASS_PATTERN.finditer(output)
    }

    fail_results = {
        match.group(1): ForgeTestResult(name=match.group(1), passed=False)
        for match in FORGE_FAIL_PATTERN.finditer(output)
    }

    merged = {**pass_results, **fail_results}
    results = sorted(merged.values(), key=lambda item: item.name)

    if result.returncode != 0 and not results:
        error_tail = (result.stderr or result.stdout).strip().splitlines()
        details = error_tail[-1] if error_tail else "forge test failed"
        return [ForgeTestResult(name="forge", passed=False, details=details)]

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
    
    raw_ir = RAW_IR_PATH
    opt_ir = OPT_IR_PATH
    
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
        print("  " + "-" * 72)
        print("  {:<32} | {:<7} | {:>8} | {}".format("Test", "Status", "Gas", "Details"))
        print("  " + "-" * 72)

        for tr in test_results:
            status = "PASS" if tr.passed else "FAIL"
            gas = str(tr.gas) if tr.gas is not None else "-"
            print(
                "  {:<32} | {:<7} | {:>8} | {}".format(
                    tr.name, status, gas, tr.details
                )
            )

        failures = [tr for tr in test_results if not tr.passed]
        if failures:
            print(f"\n  ⚠ {len(failures)}/{len(test_results)} tests failed")
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
        result = subprocess.run(
            ["python3.11", "yul2venom.py", "transpile", args.config, "--runtime-only"],
            capture_output=True,
            text=True,
            cwd=PROJECT_ROOT,
        )
        if result.returncode != 0 or "Failed" in result.stdout or "Error" in result.stdout:
            print(f"Transpilation failed:\n{result.stdout}")
            if result.stderr:
                print(result.stderr)
            sys.exit(1)
        
        shutil.copy2(MULTI_RET_BIN, MULTI_RET_RUNTIME_BIN)
        print("✓ Transpilation complete")
    
    full_debug(function=args.function, verbose=args.verbose)


if __name__ == "__main__":
    main()
