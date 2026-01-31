#!/usr/bin/env python3
"""
Debug Liveness Analysis - Analyze variable liveness for Venom IR debugging.

Usage:
    python3 debug_liveness.py <vnm_file> [--function FUNC_NAME]
    
Example:
    python3 debug_liveness.py debug/raw_ir.vnm --function fun_checkConfig
"""

import sys
import os
import argparse

# Setup path for Vyper imports
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
VYPER_PATH = os.path.join(os.path.dirname(SCRIPT_DIR), "vyper")
sys.path.insert(0, VYPER_PATH)

from vyper.venom.analysis.analysis import IRAnalysesCache
from vyper.venom.analysis.liveness import LivenessAnalysis
from vyper.venom.analysis.cfg import CFGAnalysis
from vyper.venom.parser import parse_venom


def analyze_liveness(vnm_path: str, function_name: str = None, verbose: bool = True):
    """
    Analyze liveness for a Venom IR file.
    
    Args:
        vnm_path: Path to .vnm file
        function_name: Optional function name to analyze (defaults to first function)
        verbose: Print detailed output
        
    Returns:
        Dict with liveness analysis results
    """
    with open(vnm_path, "r") as f:
        code = f.read()
    
    module = parse_venom(code)
    
    # Find target function
    fn = None
    available_functions = []
    
    for f in module.functions.values():
        func_name = f.name.value if hasattr(f.name, 'value') else str(f.name)
        available_functions.append(func_name)
        
        if function_name:
            if func_name == function_name:
                fn = f
                break
        elif fn is None:
            fn = f  # Default to first function
    
    if fn is None:
        print(f"Error: Function '{function_name}' not found.")
        print(f"Available functions: {available_functions}")
        return None
    
    if verbose:
        func_name = fn.name.value if hasattr(fn.name, 'value') else str(fn.name)
        print(f"Analyzing function: {func_name}")
        print("=" * 60)
    
    # Run analysis
    cache = IRAnalysesCache(fn)
    cfg = cache.request_analysis(CFGAnalysis)
    liveness = cache.request_analysis(LivenessAnalysis)
    
    results = {
        "function": str(fn.name),
        "blocks": [],
        "liveness": {}
    }
    
    for bb in fn.get_basic_blocks():
        block_label = bb.label.value if hasattr(bb.label, 'value') else str(bb.label)
        
        live_in = liveness.live_in.get(bb, set())
        live_out = liveness.live_out.get(bb, set())
        
        block_info = {
            "label": block_label,
            "live_in": [str(v) for v in live_in],
            "live_out": [str(v) for v in live_out],
            "instructions": len(bb.instructions)
        }
        results["blocks"].append(block_info)
        
        if verbose:
            print(f"\nBlock: {block_label}")
            print(f"  Live In:  {[str(v) for v in live_in]}")
            print(f"  Live Out: {[str(v) for v in live_out]}")
            
            # Show edge-specific liveness
            for pred in cfg._cfg_in.get(bb, []):
                pred_label = pred.label.value if hasattr(pred.label, 'value') else str(pred.label)
                input_vars = liveness.input_vars_from(pred, bb)
                print(f"  From {pred_label}: {[str(v) for v in input_vars]}")
    
    return results


def main():
    parser = argparse.ArgumentParser(
        description="Analyze variable liveness for Venom IR debugging"
    )
    parser.add_argument("vnm_file", help="Path to .vnm file")
    parser.add_argument(
        "--function", "-f",
        help="Function name to analyze (default: first function)"
    )
    parser.add_argument(
        "--quiet", "-q",
        action="store_true",
        help="Suppress detailed output"
    )
    args = parser.parse_args()
    
    if not os.path.exists(args.vnm_file):
        print(f"Error: File not found: {args.vnm_file}")
        sys.exit(1)
    
    results = analyze_liveness(
        args.vnm_file,
        function_name=args.function,
        verbose=not args.quiet
    )
    
    if results is None:
        sys.exit(1)
    
    print(f"\n✓ Analyzed {len(results['blocks'])} blocks")


if __name__ == "__main__":
    main()
