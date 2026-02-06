import argparse
import json
import os
import sys
from pathlib import Path
from typing import Dict, Optional

# Resolve local Vyper fork from project root.
BACKEND_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = BACKEND_DIR.parent
VYPER_PATH = PROJECT_ROOT / "vyper"
if str(VYPER_PATH) not in sys.path:
    sys.path.insert(0, str(VYPER_PATH))

from vyper.venom import generate_assembly_experimental, run_passes_on
from vyper.venom.parser import parse_venom

try:
    from yul2venom.utils.constants import SPILL_OFFSET
except ImportError:
    try:
        from utils.constants import SPILL_OFFSET
    except ImportError:
        SPILL_OFFSET = 0x4000


def _to_int(value) -> int:
    if isinstance(value, str):
        if value.startswith("0x"):
            return int(value, 16)
        return int(value) if value else 0
    return int(value) if value else 0


def _parse_immutable_entry(key: str, value, verbose: bool = False) -> tuple[int, int]:
    if isinstance(value, dict):
        name = value.get('name', key)
        raw_value = value.get('value', '0x0')
        if verbose:
            print(f"  {key}: {name} = {raw_value}")
        return int(key), _to_int(raw_value)
    return int(key), _to_int(value)


def load_immutables(config_path: str, verbose: bool = False) -> Dict[int, int]:
    """Load immutable values from JSON config."""
    if not config_path or not os.path.exists(config_path):
        return {}

    with open(config_path, 'r') as f:
        data = json.load(f)

    result: Dict[int, int] = {}
    for key, value in data.items():
        imm_id, imm_value = _parse_immutable_entry(key, value, verbose=verbose)
        result[imm_id] = imm_value
    return result


def _build_context(source: str, immutables: Optional[Dict[int, int]]):
    ctx = parse_venom(source)

    # Ensure function spill endpoints exist when parsing raw VNM text.
    for fn in ctx.functions.values():
        ctx.mem_allocator.fn_eom[fn] = SPILL_OFFSET

    ctx.immutables = immutables or {}
    return ctx


def compile_venom_source(source: str, immutables: Optional[Dict[int, int]] = None) -> bytes:
    """Compile Venom IR source text to EVM bytecode bytes."""
    ctx = _build_context(source, immutables)

    from vyper.compiler.settings import OptimizationLevel, VenomOptimizationFlags
    from vyper.compiler.phases import generate_bytecode

    flags = VenomOptimizationFlags(level=OptimizationLevel.default(), disable_mem2var=True)
    run_passes_on(ctx, flags)

    asm = generate_assembly_experimental(ctx)
    bytecode, _ = generate_bytecode(asm)
    return bytecode


def run_venom_backend(source: str, immutables: Optional[Dict[int, int]] = None) -> bytes:
    """Programmatic backend API used by pipeline callers."""
    return compile_venom_source(source, immutables)


def main():
    parser = argparse.ArgumentParser(description="Compile Venom IR to EVM bytecode")
    parser.add_argument("vnm_file", help="Path to .vnm file")
    parser.add_argument("--immutables", "-i", help="Path to immutables JSON config")
    parser.add_argument("--output", "-o", help="Output bytecode path (default: <input>.bin)")
    parser.add_argument("--quiet", "-q", action="store_true", help="Suppress debug output")
    args = parser.parse_args()

    vnm_path = args.vnm_file
    with open(vnm_path, "r") as f:
        source = f.read()
    
    if not args.quiet:
        import hashlib
        digest = hashlib.md5(source.encode()).hexdigest()
        print(f"Input: {vnm_path} ({len(source)} bytes, MD5: {digest})")
        
    try:
        # Load immutables from config file
        immutables = load_immutables(args.immutables)
        
        if not args.quiet and immutables:
            print(f"Loaded {len(immutables)} immutable value(s)")

        bytecode = compile_venom_source(source, immutables)
        hex_code = bytecode.hex()
        
        # Determine output path
        bin_path = args.output if args.output else vnm_path.replace(".vnm", ".bin")
        with open(bin_path, "w") as f:
            f.write(hex_code)
        
        print(f"Success! Wrote {len(hex_code)//2} bytes to {bin_path}")
        
    except Exception as e:
        import traceback
        print(f"ERROR: {type(e).__name__}: {str(e)[:200]}")
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
