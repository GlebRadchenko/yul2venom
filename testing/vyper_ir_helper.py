#!/usr/bin/env python3
"""
Vyper IR Helper - Compile Vyper contracts and produce Venom IR for research.

Usage:
    python3 vyper_ir_helper.py <contract.vy> [--output-dir DIR]
    
This tool uses pipx-installed vyper (0.4.3+) for baseline compilation.
Local fork at vyper/ is used for transpiler modifications.
"""

import subprocess
import sys
import os
import argparse

def run_vyper(contract_path: str, output_format: str, experimental: bool = False) -> str:
    """Run pipx vyper with specified output format."""
    cmd = ["pipx", "run", "vyper", contract_path, "-f", output_format]
    if experimental:
        cmd.append("--experimental-codegen")
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        # Filter warnings
        stderr_lines = [l for l in result.stderr.split('\n') 
                       if not l.startswith('⚠️') and l.strip()]
        if stderr_lines:
            print(f"Error: {chr(10).join(stderr_lines)}", file=sys.stderr)
        return result.stdout
    return result.stdout

def get_version() -> str:
    """Get pipx vyper version."""
    result = subprocess.run(["pipx", "run", "vyper", "--version"], 
                          capture_output=True, text=True)
    return result.stdout.strip().split('\n')[-1]

def main():
    parser = argparse.ArgumentParser(description="Vyper IR Research Helper")
    parser.add_argument("contract", help="Path to Vyper contract (.vy)")
    parser.add_argument("--output-dir", "-o", default="output", 
                       help="Output directory (default: output)")
    parser.add_argument("--format", "-f", default="ir",
                       help="Output format: ir, abi, bytecode, bytecode_runtime")
    parser.add_argument("--experimental", "-e", action="store_true",
                       help="Use experimental codegen (Venom backend)")
    parser.add_argument("--venom", "-v", action="store_true",
                       help="Produce Venom IR (requires experimental)")
    parser.add_argument("--all", "-a", action="store_true",
                       help="Generate all formats")
    args = parser.parse_args()
    
    if not os.path.exists(args.contract):
        print(f"Error: Contract not found: {args.contract}", file=sys.stderr)
        sys.exit(1)
    
    version = get_version()
    print(f"Vyper Version: {version}")
    
    basename = os.path.splitext(os.path.basename(args.contract))[0]
    os.makedirs(args.output_dir, exist_ok=True)
    
    if args.all:
        formats = ["ir", "abi", "bytecode", "bytecode_runtime"]
    else:
        formats = [args.format]
    
    for fmt in formats:
        print(f"\n=== {fmt.upper()} ===")
        output = run_vyper(args.contract, fmt, args.experimental)
        
        if output:
            if fmt in ["bytecode", "bytecode_runtime"]:
                ext = ".bin"
            elif fmt == "abi":
                ext = ".json"
            else:
                ext = f".{fmt}"
            
            out_path = os.path.join(args.output_dir, f"{basename}{ext}")
            with open(out_path, "w") as f:
                f.write(output)
            print(f"Written: {out_path}")
            
            # Print preview
            if len(output) > 1000:
                print(output[:1000] + "\n... (truncated)")
            else:
                print(output)
    
    # Venom IR generation using --venom / --experimental-codegen flag
    # Per README: Use -f bb_runtime for runtime code, -f bb for deploy code
    if args.venom:
        print(f"\n=== VENOM IR (bb_runtime) ===")
        venom_output = run_vyper(args.contract, "bb_runtime", experimental=True)
        if venom_output:
            out_path = os.path.join(args.output_dir, f"{basename}_venom_runtime.vnm")
            with open(out_path, "w") as f:
                f.write(venom_output)
            print(f"Written: {out_path}")
            if len(venom_output) > 2000:
                print(venom_output[:2000] + "\n... (truncated)")
            else:
                print(venom_output)
        
        print(f"\n=== VENOM IR (bb - deploy) ===")
        venom_deploy = run_vyper(args.contract, "bb", experimental=True)
        if venom_deploy:
            out_path = os.path.join(args.output_dir, f"{basename}_venom_deploy.vnm")
            with open(out_path, "w") as f:
                f.write(venom_deploy)
            print(f"Written: {out_path}")

if __name__ == "__main__":
    main()
