#!/usr/bin/env python3
"""Inspect block-level liveness information for a Venom IR function."""

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


def _label_to_str(label) -> str:
    return label.value if hasattr(label, "value") else str(label)


def _find_target_function(module, function_name: str | None):
    available = []
    selected = None

    for fn in module.functions.values():
        fn_name = _label_to_str(fn.name)
        available.append(fn_name)
        if function_name and fn_name == function_name:
            selected = fn
            break
        if selected is None and function_name is None:
            selected = fn

    return selected, available


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
    
    fn, available_functions = _find_target_function(module, function_name)
    if fn is None:
        print(f"Error: Function '{function_name}' not found.")
        print(f"Available functions: {available_functions}")
        return None
    
    if verbose:
        func_name = _label_to_str(fn.name)
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
        block_label = _label_to_str(bb.label)
        
        live_in = liveness.liveness_in_vars(bb)
        live_out = liveness.out_vars(bb)
        
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
            for pred in cfg.cfg_in(bb):
                pred_label = _label_to_str(pred.label)
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
