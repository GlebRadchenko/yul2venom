import sys
import os
import json
import argparse

# Add local vyper to path
current_dir = os.path.dirname(os.path.abspath(__file__))
vyper_path = os.path.join(current_dir, "vyper")
sys.path.insert(0, vyper_path)

from vyper.venom import generate_assembly_experimental, run_passes_on
from vyper.venom.parser import parse_venom

# Import centralized constants
try:
    from utils.constants import SPILL_OFFSET
except ImportError:
    SPILL_OFFSET = 0x4000  # Fallback if utils not available


def load_immutables(config_path: str, verbose: bool = False) -> dict:
    """
    Load immutable values from JSON config file.
    
    Supports two formats:
    1. Simple: {"3077": "0x..."}
    2. Enhanced: {"3077": {"name": "weth", "value": "0x..."}}
    """
    if not config_path or not os.path.exists(config_path):
        return {}
    
    with open(config_path, 'r') as f:
        data = json.load(f)
    
    result = {}
    for key, value in data.items():
        # Enhanced format: {name, value}
        if isinstance(value, dict):
            name = value.get('name', key)
            addr = value.get('value', '0x0')
            if verbose:
                print(f"  {key}: {name} = {addr}")
            if isinstance(addr, str) and addr.startswith("0x"):
                result[key] = int(addr, 16)
            else:
                result[key] = int(addr) if addr else 0
        # Simple format: direct value
        elif isinstance(value, str) and value.startswith("0x"):
            result[key] = int(value, 16)
        else:
            result[key] = int(value) if value else 0
    return result


def main():
    parser = argparse.ArgumentParser(description="Compile Venom IR to EVM bytecode")
    parser.add_argument("vnm_file", help="Path to .vnm file")
    parser.add_argument("--immutables", "-i", help="Path to immutables JSON config")
    parser.add_argument("--output", "-o", help="Output bytecode path (default: <input>.bin)")
    parser.add_argument("--quiet", "-q", action="store_true", help="Suppress debug output")
    args = parser.parse_args()

    vnm_path = args.vnm_file
    with open(vnm_path, 'r') as f:
        source = f.read()
    
    if not args.quiet:
        import hashlib
        print(f"Input: {vnm_path} ({len(source)} bytes, MD5: {hashlib.md5(source.encode()).hexdigest()})")
        
    try:
        ctx = parse_venom(source)
        
        # CRITICAL: Initialize fn_eom for all functions.
        # When parsing VNM from file, memory allocator doesn't run, leaving fn_eom empty.
        # This causes StackSpiller to use offset 0 for spills, corrupting scratch space.
        for fn in ctx.functions.values():
            ctx.mem_allocator.fn_eom[fn] = SPILL_OFFSET
        
        # Load immutables from config file
        immutables = load_immutables(args.immutables)
        ctx.immutables = immutables
        
        if not args.quiet and immutables:
            print(f"Loaded {len(immutables)} immutable value(s)")
        
        from vyper.compiler.settings import OptimizationLevel, VenomOptimizationFlags
        from vyper.compiler.phases import generate_bytecode
        
        flags = VenomOptimizationFlags(level=OptimizationLevel.default(), disable_mem2var=True)
        run_passes_on(ctx, flags)
        
        asm = generate_assembly_experimental(ctx)
        bytecode, _ = generate_bytecode(asm)
        hex_code = bytecode.hex()
        
        # Determine output path
        bin_path = args.output if args.output else vnm_path.replace(".vnm", ".bin")
        with open(bin_path, 'w') as f:
            f.write(hex_code)
        
        print(f"Success! Wrote {len(hex_code)//2} bytes to {bin_path}")
        
    except Exception as e:
        import traceback
        print(f"ERROR: {type(e).__name__}: {str(e)[:200]}")
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
