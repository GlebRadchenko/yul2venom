#!/usr/bin/env python3
"""
Config Benchmark - Test various inlining configurations for bytecode size optimization.
"""

import subprocess
import yaml
import json
import re
from pathlib import Path
from typing import Any, Dict, Tuple

# Key configs to test (representative samples)
TEST_CONFIGS = [
    "configs/ComplexFeaturesTest.yul2venom.json",
    "configs/MegaTest.yul2venom.json",
    "configs/bench/Functions.yul2venom.json",
    "configs/bench/Libraries.yul2venom.json",
    "configs/bench/StateManagement.yul2venom.json",
]

# Inlining parameter combinations to test
# Format: (stmt_threshold, call_threshold, description)
INLINING_CONFIGS = [
    (0, 0, "emit-all"),           # Emit all functions
    (1, 1, "aggressive"),         # Very aggressive emission
    (1, 2, "default"),            # Current default
    (2, 2, "balanced"),           # Balanced
    (3, 3, "moderate"),           # Moderate inlining
    (5, 3, "inline-small"),       # Inline small functions
    (10, 5, "inline-more"),       # Inline more
    (9999, 9999, "inline-all"),   # Inline everything
]

CONFIG_PATH = Path(__file__).parent.parent / "yul2venom.config.yaml"
YUL2VENOM_DIR = Path(__file__).parent.parent


def load_config() -> Dict[str, Any]:
    with open(CONFIG_PATH, "r") as f:
        return yaml.safe_load(f)


def save_config(config: Dict[str, Any]) -> None:
    with open(CONFIG_PATH, "w") as f:
        yaml.dump(config, f, default_flow_style=False, sort_keys=False)


def update_config(stmt_threshold: int, call_threshold: int):
    """Update inlining thresholds in the shared transpiler config."""
    config = load_config()
    config.setdefault("inlining", {})
    config["inlining"]["stmt_threshold"] = stmt_threshold
    config["inlining"]["call_threshold"] = call_threshold
    save_config(config)


def transpile_and_get_size(config_path: str) -> Tuple[bool, int]:
    """Transpile a contract and return (success, bytecode_size)."""
    cmd = ["python3.11", "yul2venom.py", "transpile", config_path, "-O", "O2"]
    result = subprocess.run(cmd, capture_output=True, text=True, cwd=str(YUL2VENOM_DIR), timeout=120)
    
    if result.returncode != 0:
        return False, 0
    
    # Extract size from output
    for line in result.stdout.split('\n'):
        if 'Size:' in line and 'bytes' in line:
            match = re.search(r'(\d+)\s*bytes', line)
            if match:
                return True, int(match.group(1))
    
    return False, 0


def run_benchmark():
    """Run the full benchmark suite."""
    results = {}
    
    print("=" * 80)
    print("CONFIG OPTIMIZATION BENCHMARK")
    print("=" * 80)
    print()
    
    # Test each inlining config
    for stmt_thresh, call_thresh, name in INLINING_CONFIGS:
        print(f"\n### Testing: {name} (stmt={stmt_thresh}, call={call_thresh})")
        update_config(stmt_thresh, call_thresh)
        
        config_results = {}
        total_size = 0
        
        for config in TEST_CONFIGS:
            config_name = Path(config).stem.replace('.yul2venom', '')
            success, size = transpile_and_get_size(config)
            
            if success:
                config_results[config_name] = size
                total_size += size
                print(f"  {config_name:30s} = {size:5d} bytes")
            else:
                config_results[config_name] = None
                print(f"  {config_name:30s} = FAILED")
        
        results[name] = {
            'stmt_threshold': stmt_thresh,
            'call_threshold': call_thresh,
            'sizes': config_results,
            'total': total_size
        }
        print(f"  {'TOTAL':30s} = {total_size:5d} bytes")
    
    return results


def print_report(results: Dict[str, Dict[str, Any]]):
    """Print a nice comparison report."""
    print("\n")
    print("=" * 80)
    print("BYTECODE SIZE COMPARISON REPORT")
    print("=" * 80)
    print()
    
    # Sort by total size
    sorted_configs = sorted(results.items(), key=lambda x: x[1]['total'])
    
    # Get baseline (default config)
    baseline = results.get('default', {}).get('total', 0)
    
    print("RANKING (by total bytecode size)")
    print("-" * 60)
    print(f"{'Rank':<5} {'Config':<20} {'Total':<10} {'vs Default':<15}")
    print("-" * 60)
    
    for rank, (name, data) in enumerate(sorted_configs, 1):
        total = data['total']
        if baseline > 0:
            diff = total - baseline
            diff_pct = (diff / baseline) * 100
            diff_str = f"{diff:+d} ({diff_pct:+.1f}%)"
        else:
            diff_str = "N/A"
        
        marker = "← BEST" if rank == 1 else ("← DEFAULT" if name == "default" else "")
        print(f"{rank:<5} {name:<20} {total:<10} {diff_str:<15} {marker}")
    
    print()
    print("DETAILED BREAKDOWN")
    print("-" * 100)
    
    # Header
    header = f"{'Contract':<30}"
    for name, _ in sorted_configs[:5]:  # Top 5 only
        header += f" {name[:12]:>12}"
    print(header)
    print("-" * 100)
    
    # Get all contract names
    contracts = list(sorted_configs[0][1]['sizes'].keys())
    
    for contract in contracts:
        row = f"{contract:<30}"
        for name, data in sorted_configs[:5]:
            size = data['sizes'].get(contract, 0) or 0
            row += f" {size:>12}"
        print(row)
    
    print("-" * 100)
    
    # Best config recommendation
    best_name, best_data = sorted_configs[0]
    print()
    print("RECOMMENDATION")
    print("-" * 60)
    print(f"Best config: {best_name}")
    print(f"  stmt_threshold: {best_data['stmt_threshold']}")
    print(f"  call_threshold: {best_data['call_threshold']}")
    print(f"  Total size: {best_data['total']} bytes")
    if baseline > 0:
        savings = baseline - best_data['total']
        savings_pct = (savings / baseline) * 100
        print(f"  Savings vs default: {savings} bytes ({savings_pct:.1f}%)")


def main():
    original_config = load_config()
    try:
        results = run_benchmark()
        print_report(results)
        
        # Save results to JSON
        output_path = YUL2VENOM_DIR / "debug" / "config_benchmark.json"
        with open(output_path, 'w') as f:
            json.dump(results, f, indent=2)
        print(f"\nResults saved to: {output_path}")
        
    finally:
        print("\nRestoring original config...")
        save_config(original_config)
        print("Done!")


if __name__ == "__main__":
    main()
