#!/usr/bin/env python3
"""
Trace Stack Analysis - Analyze stack state through Venom IR basic blocks.

Usage:
    python3 trace_stack.py <vnm_file> [--blocks PATTERN]
    
Example:
    python3 trace_stack.py debug/opt_ir.vnm --blocks "loop,end_if"
"""

import sys
import os
import argparse

# Setup path for Vyper imports
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
VYPER_PATH = os.path.join(os.path.dirname(SCRIPT_DIR), "vyper")
sys.path.insert(0, VYPER_PATH)

from vyper.venom.parser import parse_venom
from vyper.venom.analysis import IRAnalysesCache
from vyper.venom.analysis.liveness import LivenessAnalysis
from vyper.venom.analysis.cfg import CFGAnalysis


def trace_stack(vnm_path: str, block_patterns: list = None, verbose: bool = True):
    """
    Trace stack state through Venom IR blocks.
    
    Args:
        vnm_path: Path to .vnm file
        block_patterns: List of patterns to match block names
        verbose: Print detailed output
        
    Returns:
        Dict with stack trace results
    """
    with open(vnm_path, "r") as f:
        ir_text = f.read()
    
    ctx = parse_venom(ir_text)
    
    # Default patterns for loop analysis
    if block_patterns is None:
        block_patterns = ["loop", "end_if", "then", "else"]
    
    results = {"functions": []}
    
    for fn in ctx.functions.values():
        cache = IRAnalysesCache(fn)
        cfg = cache.request_analysis(CFGAnalysis)
        la = cache.request_analysis(LivenessAnalysis)
        
        func_name = fn.name.value if hasattr(fn.name, 'value') else str(fn.name)
        func_results = {"name": func_name, "blocks": []}
        
        for bb in fn.get_basic_blocks():
            block_label = bb.label.value if hasattr(bb.label, 'value') else str(bb.label)
            
            # Check if block matches any pattern
            if not any(pattern in block_label for pattern in block_patterns):
                continue
            
            block_info = {
                "label": block_label,
                "from_edges": [],
                "to_edges": []
            }
            
            if verbose:
                print(f"\n=== {block_label} ===")
            
            # Check input vars from predecessors
            for pred in cfg._cfg_in.get(bb, []):
                pred_label = pred.label.value if hasattr(pred.label, 'value') else str(pred.label)
                vars = la.input_vars_from(pred, bb)
                var_names = [str(v) for v in vars]
                block_info["from_edges"].append({
                    "pred": pred_label,
                    "vars": var_names
                })
                if verbose:
                    print(f"  FROM {pred_label}: {var_names}")
            
            # Check output vars to successors
            for succ in cfg._cfg_out.get(bb, []):
                succ_label = succ.label.value if hasattr(succ.label, 'value') else str(succ.label)
                vars = la.input_vars_from(bb, succ)
                var_names = [str(v) for v in vars]
                block_info["to_edges"].append({
                    "succ": succ_label,
                    "vars": var_names
                })
                if verbose:
                    print(f"  TO {succ_label}: {var_names}")
            
            func_results["blocks"].append(block_info)
        
        results["functions"].append(func_results)
    
    return results


def main():
    parser = argparse.ArgumentParser(
        description="Trace stack state through Venom IR basic blocks"
    )
    parser.add_argument("vnm_file", help="Path to .vnm file")
    parser.add_argument(
        "--blocks", "-b",
        help="Comma-separated patterns to match block names (default: loop,end_if,then,else)"
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
    
    block_patterns = None
    if args.blocks:
        block_patterns = [p.strip() for p in args.blocks.split(",")]
    
    print(f"Analyzing: {args.vnm_file}")
    print("=" * 60)
    
    results = trace_stack(
        args.vnm_file,
        block_patterns=block_patterns,
        verbose=not args.quiet
    )
    
    total_blocks = sum(len(f["blocks"]) for f in results["functions"])
    print(f"\n✓ Traced {total_blocks} matching blocks")


if __name__ == "__main__":
    main()
