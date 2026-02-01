#!/usr/bin/env python3
"""
Yul2Venom - Production-grade Yul to Venom IR transpiler with EVM bytecode generation.

Workflow:
  1. yul2venom prepare <contract.sol>     → Generate config template
  2. [Edit config to fill deployer, nonce, and constructor args]
  3. yul2venom transpile <file.yul>       → Predict addresses & compile

Example:
  $ python3 yul2venom.py prepare src/traders/QuotedTrader.sol
  $ vim yul2venom.config.json  # Fill deployer, nonce, weth, owner
  $ python3 yul2venom.py transpile output/QuotedTrader.yul
"""

import sys
import os
import json
import argparse
import subprocess
import re
from pathlib import Path
from typing import Dict, List, Optional, Tuple

try:
    from yul2venom.yul_source_optimizer import YulSourceOptimizer, OptimizationLevel
    from yul2venom.utils.constants import (
        SPILL_OFFSET, RLP_SHORT_STRING, RLP_SHORT_LIST,
        OP_PUSH0, OP_PUSH1, OP_PUSH2, OP_DUP1, OP_CODECOPY, OP_RETURN
    )
except ImportError:
    try:
        from yul_source_optimizer import YulSourceOptimizer, OptimizationLevel
        from utils.constants import (
            SPILL_OFFSET, RLP_SHORT_STRING, RLP_SHORT_LIST,
            OP_PUSH0, OP_PUSH1, OP_PUSH2, OP_DUP1, OP_CODECOPY, OP_RETURN
        )
    except ImportError:
        # Fallback if running from root without package context
        sys.path.append(os.path.dirname(os.path.abspath(__file__)))
        from yul_source_optimizer import YulSourceOptimizer, OptimizationLevel
        try:
            from utils.constants import (
                SPILL_OFFSET, RLP_SHORT_STRING, RLP_SHORT_LIST,
                OP_PUSH0, OP_PUSH1, OP_PUSH2, OP_DUP1, OP_CODECOPY, OP_RETURN
            )
        except ImportError:
            # Minimal fallback constants
            SPILL_OFFSET = 0x4000
            RLP_SHORT_STRING = 0x80
            RLP_SHORT_LIST = 0xC0
            OP_PUSH0, OP_PUSH1, OP_PUSH2 = 0x5F, 0x60, 0x61
            OP_DUP1, OP_CODECOPY, OP_RETURN = 0x80, 0x39, 0xF3

# Add local vyper to path
SCRIPT_DIR = Path(__file__).parent.absolute()
VYPER_PATH = SCRIPT_DIR / "vyper"
sys.path.insert(0, str(VYPER_PATH))


# ============================================================================
# Address Prediction (CREATE formula)
# ============================================================================

def keccak256(data: bytes) -> bytes:
    """Compute keccak256 hash."""
    try:
        from eth_utils import keccak
        return keccak(data)
    except ImportError:
        try:
            from Crypto.Hash import keccak as pycrypto_keccak
            k = pycrypto_keccak.new(digest_bits=256)
            k.update(data)
            return k.digest()
        except ImportError:
            import hashlib
            return hashlib.sha3_256(data).digest()


def rlp_encode_address_nonce(address: bytes, nonce: int) -> bytes:
    """Minimal RLP encoding for [address, nonce] list.
    
    Uses RLP_SHORT_STRING (0x80) and RLP_SHORT_LIST (0xC0) constants.
    Per Ethereum specification: https://ethereum.org/en/developers/docs/data-structures-and-encoding/rlp/
    """
    def encode_item(item):
        if isinstance(item, int):
            if item == 0:
                return bytes([RLP_SHORT_STRING])  # Empty string encoding
            hex_str = hex(item)[2:]
            if len(hex_str) % 2:
                hex_str = '0' + hex_str
            data = bytes.fromhex(hex_str)
            if len(data) == 1 and data[0] < RLP_SHORT_STRING:
                return data  # Single byte < 0x80 encodes as itself
            return bytes([RLP_SHORT_STRING + len(data)]) + data
        else:
            if len(item) == 1 and item[0] < RLP_SHORT_STRING:
                return item
            return bytes([RLP_SHORT_STRING + len(item)]) + item
    
    encoded_items = encode_item(address) + encode_item(nonce)
    total_len = len(encoded_items)
    if total_len < 56:
        return bytes([RLP_SHORT_LIST + total_len]) + encoded_items
    else:
        # Long list encoding (RLP_LONG_LIST = 0xF7)
        len_bytes = total_len.to_bytes((total_len.bit_length() + 7) // 8, 'big')
        return bytes([0xf7 + len(len_bytes)]) + len_bytes + encoded_items


def compute_create_address(deployer: str, nonce: int) -> str:
    """Compute CREATE address for a contract deployment."""
    deployer = deployer.lower().replace('0x', '')
    deployer_bytes = bytes.fromhex(deployer)
    encoded = rlp_encode_address_nonce(deployer_bytes, nonce)
    addr_bytes = keccak256(encoded)[-20:]
    return '0x' + addr_bytes.hex()


def generate_init_stub(runtime_size: int) -> bytes:
    """
    Generate minimal init bytecode that deploys the runtime code.
    
    Init code pattern (no constructor logic):
        PUSH2 <runtime_size>    ; 61 XX XX  (3 bytes)
        DUP1                    ; 80        (1 byte)
        PUSH1 0x0c              ; 60 0C     (2 bytes) - init size
        PUSH0                   ; 5F        (1 byte)
        CODECOPY                ; 39        (1 byte)
        PUSH0                   ; 5F        (1 byte)
        RETURN                  ; F3        (1 byte)
    
    Total init size: 10 bytes (fixed)
    """
    INIT_SIZE = 10  # This stub is always 10 bytes
    
    # Build init bytecode using EVM opcode constants
    init_bytes = bytearray()
    
    # PUSH2 <runtime_size>
    init_bytes.append(OP_PUSH2)
    init_bytes.append((runtime_size >> 8) & 0xFF)
    init_bytes.append(runtime_size & 0xFF)
    
    # DUP1
    init_bytes.append(OP_DUP1)
    
    # PUSH1 <init_size> (offset where runtime starts)
    init_bytes.append(OP_PUSH1)
    init_bytes.append(INIT_SIZE)
    
    # PUSH0
    init_bytes.append(OP_PUSH0)
    
    # CODECOPY
    init_bytes.append(OP_CODECOPY)
    
    # PUSH0
    init_bytes.append(OP_PUSH0)
    
    # RETURN
    init_bytes.append(OP_RETURN)
    
    assert len(init_bytes) == INIT_SIZE, f"Init stub size mismatch: {len(init_bytes)} != {INIT_SIZE}"
    return bytes(init_bytes)


# ============================================================================
# AST Analysis: Extract Immutables with Smart Classification
# ============================================================================

def analyze_solidity_contract(contract_path: str, remappings_file: str = "remappings.txt") -> Dict:
    """
    Analyze Solidity contract to extract immutables with smart classification.
    
    Returns dict with:
    - constructor_args: Immutables that come from constructor parameters
    - created_immutables: Immutables assigned from CREATE (new Contract(...))
    """
    cmd = ["solc", "--combined-json", "ast", contract_path, "--optimize"]
    
    if os.path.exists(remappings_file):
        with open(remappings_file, 'r') as f:
            remappings = [r.strip() for r in f.read().strip().split('\n') if r.strip()]
            cmd.extend(remappings)
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        ast_data = json.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"✗ Error: solc failed", file=sys.stderr)
        print(e.stderr[:500] if e.stderr else "No error output", file=sys.stderr)
        return {"constructor_args": {}, "created_immutables": {}}
    except json.JSONDecodeError as e:
        print(f"✗ Error: Failed to parse solc output", file=sys.stderr)
        return {"constructor_args": {}, "created_immutables": {}}
    
    # Find all immutable declarations
    immutables = {}
    constructor_params = set()
    create_assignments = set()  # Immutables assigned from CREATE
    
    def find_constructor_params(node, parent_is_constructor=False):
        """Find parameter names in constructor."""
        if isinstance(node, dict):
            if node.get('nodeType') == 'FunctionDefinition' and node.get('kind') == 'constructor':
                params = node.get('parameters', {}).get('parameters', [])
                for p in params:
                    constructor_params.add(p.get('name', ''))
            for v in node.values():
                find_constructor_params(v)
        elif isinstance(node, list):
            for item in node:
                find_constructor_params(item)
    
    def find_create_assignments(node, in_constructor=False):
        """Find assignments like: curvePath = address(new CurvePath(...))"""
        if isinstance(node, dict):
            is_constructor = node.get('nodeType') == 'FunctionDefinition' and node.get('kind') == 'constructor'
            if is_constructor:
                in_constructor = True
            
            # Look for Assignment or VariableDeclarationStatement with FunctionCall to 'new'
            if in_constructor and node.get('nodeType') == 'Assignment':
                left = node.get('leftHandSide', {})
                right = node.get('rightHandSide', {})
                
                # Check if right side contains 'new' expression
                if contains_new_expression(right):
                    # Get the variable name being assigned
                    if left.get('nodeType') == 'Identifier':
                        var_name = left.get('name', '')
                        ref_id = left.get('referencedDeclaration')
                        if ref_id:
                            create_assignments.add(ref_id)
            
            for v in node.values():
                find_create_assignments(v, in_constructor)
        elif isinstance(node, list):
            for item in node:
                find_create_assignments(item, in_constructor)
    
    def contains_new_expression(node) -> bool:
        """Check if node contains a 'new' expression."""
        if isinstance(node, dict):
            if node.get('nodeType') == 'FunctionCall':
                expr = node.get('expression', {})
                if expr.get('nodeType') == 'NewExpression':
                    return True
                # Also check for address(new X())
                if expr.get('nodeType') == 'ElementaryTypeNameExpression':
                    args = node.get('arguments', [])
                    for arg in args:
                        if contains_new_expression(arg):
                            return True
            for v in node.values():
                if contains_new_expression(v):
                    return True
        elif isinstance(node, list):
            for item in node:
                if contains_new_expression(item):
                    return True
        return False
    
    def find_immutables(node):
        """Find all immutable variable declarations."""
        if isinstance(node, dict):
            if node.get('nodeType') == 'VariableDeclaration' and node.get('mutability') == 'immutable':
                id_num = node['id']
                immutables[id_num] = {
                    'name': node['name'],
                    'type': node.get('typeDescriptions', {}).get('typeString', 'unknown'),
                    'id': id_num
                }
            for v in node.values():
                find_immutables(v)
        elif isinstance(node, list):
            for item in node:
                find_immutables(item)
    
    # Run analysis
    find_constructor_params(ast_data)
    find_create_assignments(ast_data)
    find_immutables(ast_data)
    
    # Classify immutables
    constructor_args = {}
    created_immutables = {}
    
    for id_num, info in immutables.items():
        name = info['name']
        # Check if this immutable is assigned from CREATE
        if id_num in create_assignments:
            created_immutables[name] = {
                'id': str(id_num),
                'type': info['type'],
                'value': None  # Will be predicted
            }
        else:
            # Constructor arg or directly assigned
            constructor_args[name] = {
                'id': str(id_num),
                'type': info['type'],
                'value': None  # User must provide
            }
    
    return {
        'constructor_args': constructor_args,
        'created_immutables': created_immutables
    }


# ============================================================================
# Commands
# ============================================================================

def cmd_prepare(args):
    """Prepare configuration and Yul output from Solidity contract."""
    contract_path = args.contract
    
    # Config location: current working directory with contract name
    if args.config:
        config_path = args.config
    else:
        contract_name = Path(contract_path).stem
        config_path = f"configs/{contract_name}.yul2venom.json"
    
    print(f"Analyzing: {contract_path}")
    print()
    
    # Load existing config if present (to preserve user values)
    existing_config = {}
    if os.path.exists(config_path):
        try:
            with open(config_path, 'r') as f:
                existing_config = json.load(f)
        except:
            pass
    
    analysis = analyze_solidity_contract(contract_path, args.remappings)
    constructor_args = analysis['constructor_args']
    created_immutables = analysis['created_immutables']
    
    # Step 1: Generate Yul from Solidity
    yul_output_path = str(SCRIPT_DIR / "output" / f"{Path(contract_path).stem}.yul")
    os.makedirs(SCRIPT_DIR / "output", exist_ok=True)
    
    print(f"Generating Yul: {yul_output_path}")
    remappings = []
    if os.path.exists(args.remappings):
        with open(args.remappings, 'r') as f:
            remappings = [r.strip() for r in f.read().strip().split('\n') if r.strip()]
    
    cmd = ["solc", "--ir-optimized", "--optimize", contract_path] + remappings
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode != 0:
        print(f"✗ Failed to generate Yul", file=sys.stderr)
        print(result.stderr[:500] if result.stderr else "No error", file=sys.stderr)
        return 1
    
    # Extract _deployed object from solc output
    contract_name = Path(contract_path).stem
    raw_yul = result.stdout
    
    # Find the main contract object: object "ContractName_XXX" {
    # Robust extraction of the main object using a state machine
    import re
    
    def find_balancing_brace(text, start_index):
        """Find the index of the closing brace matching the opening brace at start_index."""
        # Simple state machine to ignore braces in strings and comments
        i = start_index + 1
        brace_count = 1
        in_string = False
        in_comment = False  # // type
        in_block_comment = False # /* type */
        
        length = len(text)
        while i < length:
            char = text[i]
            prev = text[i-1] if i > 0 else ''
            
            # Handle String
            if in_string:
                if char == '"' and prev != '\\':
                    in_string = False
                i += 1
                continue
                
            # Handle Comments
            if in_comment:
                if char == '\n':
                    in_comment = False
                i += 1
                continue
                
            if in_block_comment:
                if char == '/' and prev == '*':
                    in_block_comment = False
                i += 1
                continue
            
            # Check for start of string/comment
            if char == '"':
                in_string = True
                i += 1
                continue
                
            if char == '/' and i + 1 < length:
                next_char = text[i+1]
                if next_char == '/':
                    in_comment = True
                    i += 2
                    continue
                elif next_char == '*':
                    in_block_comment = True
                    i += 2
                    continue
            
            # Handle Braces
            if char == '{':
                brace_count += 1
            elif char == '}':
                brace_count -= 1
                if brace_count == 0:
                    return i + 1
            
            i += 1
        return -1

    # Match: object "QuotedTrader_182" (with any numeric suffix)
    # Refactored to iteratate through ALL objects in the stream
    cursor = 0
    created_files = {} # name -> path
    output_dir = os.path.dirname(yul_output_path)
    
    print("  Extracting Yul objects:")
    
    while cursor < len(raw_yul):
        # Find next object start: object "Name_ID" {
        match = re.search(r'object\s+"(\w+)_(\d+)"\s*\{', raw_yul[cursor:])
        if not match:
            break
            
        obj_name = match.group(1)
        obj_id = match.group(2)
        
        abs_start = cursor + match.start()
        brace_pos = cursor + match.end() - 1
        
        end_pos = find_balancing_brace(raw_yul, brace_pos)
        if end_pos == -1:
            print(f"  Warning: Could not find closing brace for {obj_name}")
            break
            
        # Extract full object
        full_object = raw_yul[abs_start:end_pos]
        
        # Look for _deployed inside this object - BUT DO NOT STRIP IT
        # We need the full object for deployment (Init Code)
        deployed_pattern = rf'object\s+"{re.escape(obj_name)}(?:_\d+)?_deployed"\s*\{{'
        deployed_match = re.search(deployed_pattern, full_object)
        
        final_code = full_object
        
        if deployed_match:
             # Just verify it exists, don't extract it.
             pass
            
        # Determine output filename
        out_filename = f"{obj_name}.yul"
        out_path = os.path.join(output_dir, out_filename)
        
        with open(out_path, 'w') as f:
            f.write(final_code)
            
        created_files[obj_name] = out_path
        print(f"    • {obj_name} -> {out_filename}")
        
        # Advance cursor
        cursor = end_pos
    
    # Identify main Yul path
    if contract_name in created_files:
        yul_output_path = created_files[contract_name]
    else:
        # Fallback if name mismatch or not found (unlikely if compilation succeeded)
        print(f"  Warning: Main contract {contract_name} not found in outputs. Using direct output.")
        with open(yul_output_path, 'w') as f:
            f.write(raw_yul)

    
    # Build config - merge with existing
    # Use relative paths (relative to yul2venom project root)
    def make_relative(p):
        try:
            return str(Path(p).relative_to(SCRIPT_DIR))
        except ValueError:
            return p  # Return as-is if not under SCRIPT_DIR
    
    config = {
        "version": "1.0",
        "contract": make_relative(contract_path),
        "yul": make_relative(yul_output_path),
        "deployment": {
            "deployer": existing_config.get("deployment", {}).get("deployer", "0x1234567890123456789012345678901234567890"),
            "nonce": existing_config.get("deployment", {}).get("nonce", 0)
        },
        "constructor_args": {},
        "auto_predicted": {}
    }
    
    # Add constructor args - preserve existing values
    existing_args = existing_config.get("constructor_args", {})
    for name, info in constructor_args.items():
        config["constructor_args"][name] = {
            "id": info['id'],
            "type": info['type'],
            "value": existing_args.get(name, {}).get("value", "")
        }
    
    # Add auto-predicted immutables - preserve existing values
    existing_auto = existing_config.get("auto_predicted", {})
    for name, info in created_immutables.items():
        existing_val = existing_auto.get(name, {})
        # If existing value has "value" (manual override) or we just want to preserve structure
        config["auto_predicted"][name] = {
            "id": info['id'],
            "type": info['type']
        }
        # Preserve manual value override if present
        if "value" in existing_val:
            config["auto_predicted"][name]["value"] = existing_val["value"]
    
    # Write config
    with open(config_path, 'w') as f:
        json.dump(config, f, indent=2)
    
    # Print summary
    print()
    print("┌─────────────────────────────────────────────────────────")
    print("│ Prepare Complete")
    print("├─────────────────────────────────────────────────────────")
    print(f"│ Config: {config_path}")
    print(f"│ Yul:    {yul_output_path}")
    print("│")
    
    if constructor_args:
        print("│ ⚠ REQUIRED - Fill these values in config:")
        for name, info in constructor_args.items():
            existing_val = existing_args.get(name, {}).get("value", "")
            status = "✓" if existing_val else "•"
            print(f"│   {status} {name}: {info['type']}" + (f" = {existing_val}" if existing_val else ""))
    
    print("│")
    
    if created_immutables:
        print("│ ✓ AUTO-PREDICTED (computed from deployer+nonce):")
        for name in list(created_immutables.keys())[:3]:
            print(f"│   • {name}")
        if len(created_immutables) > 3:
            print(f"│   • ... and {len(created_immutables) - 3} more")
    
    print("│")
    print("├─────────────────────────────────────────────────────────")
    print("│ Next Steps:")
    print(f"│   1. Edit {config_path}")
    print("│   2. Set deployer and nonce")
    if constructor_args:
        incomplete = [n for n, i in constructor_args.items() if not existing_args.get(n, {}).get("value")]
        if incomplete:
            print(f"│   3. Fill: {', '.join(incomplete)}")
            print("│   4. Run: yul2venom transpile")
        else:
            print("│   3. Run: yul2venom transpile")
    else:
        print("│   3. Run: yul2venom transpile")
    print("└─────────────────────────────────────────────────────────")
    
    return 0


def cmd_transpile(args):
    """Transpile Yul to bytecode with automatic address prediction."""
    config_path = args.config
    output_path = args.output
    
    # Load config
    if not os.path.exists(config_path):
        print(f"✗ Config not found: {config_path}", file=sys.stderr)
        print(f"  Run 'yul2venom prepare <contract.sol>' first", file=sys.stderr)
        return 1
    
    with open(config_path, 'r') as f:
        config = json.load(f)
    
    # Get yul path from config or CLI
    yul_path = args.yul if args.yul else config.get("yul", "")
    
    # Resolve relative paths to absolute (relative to project root)
    if yul_path and not os.path.isabs(yul_path):
        yul_path = str(SCRIPT_DIR / yul_path)
    
    if not yul_path or not os.path.exists(yul_path):
        print(f"✗ Yul file not found: {yul_path}", file=sys.stderr)
        print(f"  Run 'yul2venom prepare' to generate Yul", file=sys.stderr)
        return 1
    
    # Validate deployment info
    deployment = config.get("deployment", {})
    deployer = deployment.get("deployer", "")
    nonce = deployment.get("nonce", 0)
    
    if not deployer or deployer.startswith("0x__") or "YOUR" in str(deployer):
        print("✗ Error: deployment.deployer not set", file=sys.stderr)
        print(f"  Edit {config_path} and set your deployer address", file=sys.stderr)
        return 1
    
    if not isinstance(nonce, int) or "YOUR" in str(nonce):
        print("✗ Error: deployment.nonce not set", file=sys.stderr)
        print(f"  Edit {config_path} and set your current nonce", file=sys.stderr)
        return 1
    
    # Validate constructor args
    constructor_args = config.get("constructor_args", {})
    missing_args = []
    for name, info in constructor_args.items():
        if not info.get("value"):
            missing_args.append(name)
    
    if missing_args:
        print("✗ Error: Missing constructor arg values:", file=sys.stderr)
        for name in missing_args:
            print(f"  • {name}", file=sys.stderr)
        print(f"  Edit {config_path} and fill in values", file=sys.stderr)
        return 1
    
    # Predict addresses
    print("┌─────────────────────────────────────────────────────────")
    print("│ Address Prediction")
    print("├─────────────────────────────────────────────────────────")
    print(f"│ Deployer: {deployer}")
    print(f"│ Nonce: {nonce}")
    
    main_contract = compute_create_address(deployer, nonce)
    print(f"│ Main Contract: {main_contract}")
    print("│")
    
    # Build immutables map (id -> value)
    immutables_map = {}
    
    # Add constructor args
    print("│ Constructor Args:")
    for name, info in constructor_args.items():
        id_str = info['id']
        key = int(id_str) if str(id_str).isdigit() else id_str
        value = info['value']
        if isinstance(value, str) and value.startswith("0x"):
            immutables_map[key] = int(value, 16)
        else:
            immutables_map[key] = int(value) if value else 0
        print(f"│   • {name} = {value}")
    
    # Predict CREATE addresses
    auto_predicted = config.get("auto_predicted", {})
    if auto_predicted:
        print("│")
        print("│ Auto-Predicted (CREATE addresses):")
        sidecar_nonce = 1
        for name in sorted(auto_predicted.keys(), key=lambda n: int(auto_predicted[n]['id'])):
            info = auto_predicted[name]
            id_str = info['id']
            key = int(id_str) if str(id_str).isdigit() else id_str
            predicted = compute_create_address(main_contract, sidecar_nonce)
            immutables_map[key] = int(predicted, 16)
            print(f"│   • {name} = {predicted}")
            sidecar_nonce += 1
    
    print("└─────────────────────────────────────────────────────────")
    print()
    
    # Step 0: Optimize Yul
    print(f"Optimizing Yul: {yul_path}")
    try:
        with open(yul_path, 'r') as f:
            raw_yul = f.read()
            
        opt_config = config.copy()
        
        # Configure YulSourceOptimizer based on CLI flags
        # Levels: safe, standard, aggressive, maximum
        yul_opt_level = getattr(args, 'yul_opt_level', None)
        
        if yul_opt_level or getattr(args, 'yul_opt', False) or getattr(args, 'strip_checks', False):
            # Determine optimization level
            if yul_opt_level:
                level = OptimizationLevel(yul_opt_level)
            elif getattr(args, 'strip_checks', False):
                level = OptimizationLevel.AGGRESSIVE
            elif getattr(args, 'yul_opt', False):
                level = OptimizationLevel.STANDARD
            else:
                level = OptimizationLevel.SAFE
            
            print(f"Running Yul source optimizer (level: {level.value})...", file=sys.stderr)
            opt = YulSourceOptimizer(level=level, config=config)
            optimized_yul = opt.optimize(raw_yul)
            opt.print_report()
        else:
            # Skip Yul optimizer (default for compatibility)
            optimized_yul = raw_yul
        
        # PATCH: Move Free Memory Pointer Storage... REMOVED
        # optimized_yul = re.sub(r"mload\(\s*64\s*\)", "mload(4096)", optimized_yul)
        # optimized_yul = re.sub(r"mstore\(\s*64\s*,", "mstore(4096,", optimized_yul)
        
        # Save optimized Yul
        yul_opt_path = yul_path.replace(".yul", "_opt.yul")
        with open(yul_opt_path, 'w') as f:
            f.write(optimized_yul)
            
        # Use optimized file for transpilation
        yul_path = yul_opt_path
        
    except Exception as e:
        print(f"⚠ Optimization failed: {e}", file=sys.stderr)
        print("Falling back to unoptimized Yul...", file=sys.stderr)

    # Step 1: Parse Yul (Top-Level)
    print(f"Parsing Yul: {yul_path}")
    try:
        from yul2venom.yul_parser import YulParser
    except ImportError:
        # Fallback for local run
        from yul_parser import YulParser

    parser = YulParser(open(yul_path).read())
    all_objects = parser.parse_toplevel_objects()
    
    if not all_objects:
        print("Error: No Yul objects found", file=sys.stderr)
        return 1
        
    # Select target object based on contract name
    contract_path = config.get("contract", "")
    contract_name = os.path.splitext(os.path.basename(contract_path))[0]
    
    target_obj = None
    # Priority 1: Exact match or Prefix match (Name_...)
    for obj in all_objects:
        obj_name = obj.name.strip('"')
        if obj_name == contract_name or obj_name.startswith(f"{contract_name}_"):
            target_obj = obj
            break
    
    # Priority 2: Fallback to last object (often the main contract if not multi-file)
    if not target_obj:
        print(f"⚠ Warning: No object matched contract name '{contract_name}'. Available: {[o.name for o in all_objects]}", file=sys.stderr)
        target_obj = all_objects[-1]
        
    print(f"Selected Main Contract Object: {target_obj.name}")
    top_obj = target_obj

    # Helper function to transpile a single YulObject to bytecode
    def transpile_object(obj, data_map=None, vnm_output_path=None, immutables=None):
        # 1. Build IR
        try:
            from yul2venom.venom_generator import VenomIRBuilder
        except ImportError:
            from venom_generator import VenomIRBuilder
            
        builder = VenomIRBuilder()
        ir_vnm = builder.build(obj, data_map=data_map, immutables=immutables)
        # Serialize to text and parse back into Vyper Venom Context
        # This bridges yul2venom.ir -> vyper.venom types
        
        # NOTE: No monkey patches - using native Venom behavior

        from vyper.venom.parser import parse_venom
        try:
            raw_ir = str(ir_vnm)
            os.makedirs("debug", exist_ok=True)
            with open("debug/raw_ir.vnm", "w") as f:
                f.write(raw_ir)
            print(f"DEBUG: Saved raw IR to debug/raw_ir.vnm ({len(raw_ir)} bytes)")
            
            # Debug inspection passed - ir_vnm is clean.
            # Continue to transpilation w/ monkey-patched pipeline
            raw_ir = str(ir_vnm) 
            with open("debug/raw_ir.vnm", "w") as f:
                f.write(raw_ir)
            print(f"DEBUG: Saved raw IR to debug/raw_ir.vnm ({len(raw_ir)} bytes)")

            ctx = parse_venom(raw_ir)
            # VENOM PATCH: Inject immutables from config
            ctx.immutables = immutables_map
            print(f"DEBUG: Injected {len(immutables_map)} immutables into context")


        except Exception as e:
            print(f"CRITICAL ERROR parsing IR: {e}")
            raise e

        # Save Venom IR to .vnm file for debugging
        # Save Venom IR to .vnm file for debugging
        raw_vnm_lines = 0  # Track for optimization stats
        if vnm_output_path:
            obj_name = obj.name.strip('"')
            
            # Logic: If path ends in .vnm, use it (append obj name if multi-obj?)
            # Usually we use dirname
            if vnm_output_path.endswith(".vnm"):
                vnm_file = vnm_output_path
            else:
                vnm_dir = os.path.dirname(vnm_output_path) or "."
                vnm_name = f"{obj_name}.vnm"
                vnm_file = os.path.join(vnm_dir, vnm_name)
            
            # Write file
            raw_vnm_content = str(ctx)
            with open(vnm_file, 'w') as f:
                f.write(raw_vnm_content)
            raw_vnm_lines = raw_vnm_content.count('\n')
            raw_vnm_bytes = len(raw_vnm_content)
                
            print(f"    ✓ Saved Venom IR: {os.path.abspath(vnm_file)}")
        
        # 2. Apply Fixes (Memory Layout, etc)
        # CRITICAL: Initialize fn_eom for all functions.
        for fn in ctx.functions.values():
            ctx.mem_allocator.fn_eom[fn] = SPILL_OFFSET
            
        # 3. Optimize (Proper SSA Reconstruction Pipeline)
        from vyper.venom.passes import (
            SimplifyCFGPass, Mem2Var, MakeSSA, PhiEliminationPass,
            RemoveUnusedVariablesPass, CFGNormalization,
            FloatAllocas, AssignElimination, RevertToAssert,
            MemMergePass, LowerDloadPass, ConcretizeMemLocPass,
            BranchOptimizationPass, CSE, LoadElimination,
            SCCP, AlgebraicOptimizationPass, DeadStoreElimination,
            SingleUseExpansion, DFTPass, AssertEliminationPass,
            AssertCombinerPass, ReduceLiteralsCodesize, MemoryCopyElisionPass
        )
        from vyper.venom.analysis import IRAnalysesCache
        from vyper.venom.check_venom import check_calling_convention, check_venom_ctx
        from vyper.evm.address_space import MEMORY, STORAGE, TRANSIENT
        import traceback
        
        # VALIDATION: Check IR before optimization
        print("DEBUG: Validating Venom IR before optimization...", file=sys.stderr)
        try:
            check_venom_ctx(ctx)
            print("DEBUG: check_venom_ctx PASSED", file=sys.stderr)
        except Exception as e:
            print(f"ERROR: check_venom_ctx FAILED: {e}", file=sys.stderr)
            # Print sub-exceptions if any
            if hasattr(e, 'exceptions'):
                for i, sub_e in enumerate(e.exceptions):
                    print(f"  Sub-exception {i+1}: {sub_e}", file=sys.stderr)
            # Continue anyway to see what assembler produces
        
        try:
            check_calling_convention(ctx)
            print("DEBUG: check_calling_convention PASSED", file=sys.stderr)
        except Exception as e:
            print(f"ERROR: check_calling_convention FAILED: {e}", file=sys.stderr)
        
        # Define Safe O2 Pipeline for Yul (Validated 2026-02-01)
        # NOTE: SCCP disabled - increases bytecode due to single-use expansion conflicts
        PASSES_YUL_O2 = [
            FloatAllocas,
            SimplifyCFGPass,
            Mem2Var,
            MakeSSA,
            PhiEliminationPass,
            SCCP,  # Early constant propagation
            SimplifyCFGPass,
            AssignElimination,
            AlgebraicOptimizationPass,  # Enable early algebraic optimizations
            LoadElimination,
            PhiEliminationPass,
            AssignElimination,
            SCCP,  # Third SCCP after LoadElimination/AssignElimination
            AssignElimination,
            RevertToAssert,
            AssertEliminationPass,  # Remove provably-true assertions
            AssertCombinerPass,     # Combine consecutive assert statements
            MemMergePass,
            LowerDloadPass,
            RemoveUnusedVariablesPass,
            (DeadStoreElimination, {'addr_space': MEMORY}),  # Eliminate dead memory stores
            AssignElimination,
            RemoveUnusedVariablesPass,
            ConcretizeMemLocPass,
            SCCP,  # Re-enabled: constant propagation after other passes
            SimplifyCFGPass,
            MemMergePass,
            MemoryCopyElisionPass,  # Eliminate redundant memory copies
            RemoveUnusedVariablesPass,
            BranchOptimizationPass,
            AlgebraicOptimizationPass,  # div→shr, mul→shl, iszero chains, range-based elimination
            (DeadStoreElimination, {'addr_space': STORAGE}),  # Eliminate dead storage writes
            (DeadStoreElimination, {'addr_space': TRANSIENT}),  # Eliminate dead transient writes
            RemoveUnusedVariablesPass,
            PhiEliminationPass,
            AssignElimination,
            CSE, 
            AssignElimination,
            AssignElimination,
            RemoveUnusedVariablesPass,
            SingleUseExpansion,
            ReduceLiteralsCodesize,  # Transform large literals to smaller forms (not, shl)
            DFTPass,
            CFGNormalization,
        ]


        opt_level = getattr(args, 'optimize', 'O2')
        print(f"DEBUG: Optimization Level: {opt_level}", file=sys.stderr)
        
        if opt_level == 'native':
            # Use native vyper O2 pipeline via run_passes_on
            print("DEBUG: Running Native Venom O2 Pipeline (run_passes_on)...", file=sys.stderr)
            from vyper.venom import run_passes_on
            from vyper.compiler.settings import OptimizationLevel, VenomOptimizationFlags
            # Enable mem2var (disable_mem2var=False) for better optimization
            flags = VenomOptimizationFlags(level=OptimizationLevel.default(), disable_mem2var=False)
            run_passes_on(ctx, flags)
        elif opt_level == 'none':
            # NO passes at all - raw IR straight to assembly (for debugging)
            print("DEBUG: Running NO PASSES (raw IR to assembly)...", file=sys.stderr)
            # Skip all passes
        elif opt_level == 'O0':
            # Minimal passes - only what's required for assembly
            print("DEBUG: Running minimal O0 pipeline...", file=sys.stderr)
            for fn in ctx.functions.values():
                ac = IRAnalysesCache(fn)
                try:
                    # SimplifyCFG merges single-predecessor blocks - required before CFGNormalization
                    SimplifyCFGPass(ac, fn).run_pass()
                    CFGNormalization(ac, fn).run_pass()
                except Exception as e:
                    print(f"WARNING: O0 pass failed for {fn.name}: {e}", file=sys.stderr)
                    traceback.print_exc()
        elif opt_level == 'debug':
            print("DEBUG: Running Custom Native Pipeline (Legacy/Debug)...", file=sys.stderr)
            # ... (Legacy debug pipeline code) ...
            for fn in ctx.functions.values():
                ac = IRAnalysesCache(fn)
                try:
                    SimplifyCFGPass(ac, fn).run_pass()
                    Mem2Var(ac, fn).run_pass()
                    RemoveUnusedVariablesPass(ac, fn).run_pass()
                    MakeSSA(ac, fn).run_pass()
                    PhiEliminationPass(ac, fn).run_pass()
                    RemoveUnusedVariablesPass(ac, fn).run_pass()
                    CFGNormalization(ac, fn).run_pass()
                except Exception as e:
                    print(f"WARNING: Optimization pipeline failed for {fn.name}: {e}", file=sys.stderr)
                    traceback.print_exc()
        else:
             # For O2, O3, Os -> Use Safe Yul O2 Pipeline
             print(f"DEBUG: Running Safe Yul Pipeline (Equivalent to {opt_level})...", file=sys.stderr)
             from vyper.venom.optimization_levels.types import PassConfig
             
             for fn in ctx.functions.values():
                 ac = IRAnalysesCache(fn)
                 for i, p_config in enumerate(PASSES_YUL_O2):
                     try:
                         if isinstance(p_config, tuple):
                             cls, kwargs = p_config
                         else:
                             cls = p_config
                             kwargs = {}
                         cls(ac, fn).run_pass(**kwargs)
                     except Exception as e:
                         print(f"WARNING: Pass {i} ({p_config}) failed: {e}", file=sys.stderr)
        
        print(f"DEBUG: Functions after optimization: {list(ctx.functions.keys())}", file=sys.stderr)

        # DEBUG: Unconditionally save optimized VNM for debugging
        os.makedirs("debug", exist_ok=True)
        with open("debug/opt_ir.vnm", "w") as f:
            f.write(str(ctx))
        print(f"DEBUG: Saved optimized IR to debug/opt_ir.vnm", file=sys.stderr)

        # Debug: Save Optimized IR
        # Debug: Save Optimized IR
        if vnm_output_path:
            obj_name = obj.name.strip('"')
            if vnm_output_path.endswith(".vnm"):
                 vnm_opt_file = vnm_output_path.replace(".vnm", "_opt.vnm")
            else:
                 vnm_dir = os.path.dirname(vnm_output_path) or "."
                 vnm_opt_file = os.path.join(vnm_dir, f"{obj_name}_opt.vnm")
                 
            opt_vnm_content = str(ctx)
            with open(vnm_opt_file, 'w') as f:
                f.write(opt_vnm_content)
            
            # Show optimization stats if we have raw VNM metrics
            if raw_vnm_lines > 0:
                opt_vnm_lines = opt_vnm_content.count('\n')
                opt_vnm_bytes = len(opt_vnm_content)
                reduction_pct = 100 * (1 - opt_vnm_lines / raw_vnm_lines) if raw_vnm_lines > 0 else 0
                print(f"    ✓ Saved Optimized Venom IR: {os.path.abspath(vnm_opt_file)}")
                print(f"    📊 VNM Stats: {raw_vnm_lines} → {opt_vnm_lines} lines ({reduction_pct:.1f}% reduction)")
            else:
                print(f"    ✓ Saved Optimized Venom IR: {os.path.abspath(vnm_opt_file)}")
        
        # 4. Generate Assembly & Bytecode
        from vyper.venom import generate_assembly_experimental
        from vyper.compiler.phases import generate_bytecode
        import vyper.venom.venom_to_assembly as v2a
        # v2a.DEBUG_SHOW_COST = False # disabled for debug
        
        asm = generate_assembly_experimental(ctx)
        
        # DEBUG: Dump assembly
        if vnm_output_path:
            asm_path = vnm_output_path.replace(".vnm", ".asm")
        else:
            os.makedirs("debug", exist_ok=True)
            asm_path = "debug/assembly.asm"
        with open(asm_path, "w") as f:
            for op in asm:
                f.write(f"{op}\n")
        print(f"    ✓ Saved Assembly: {os.path.abspath(asm_path)}")
        
        bytecode, _ = generate_bytecode(asm)
        return bytecode

    # Step 2: Compile Sub-Objects (Runtime Code)
    data_map = {}
    
    # Determine output path immediately so it can be used for .vnm generation
    if not output_path:
        # Default: replace .yul with .bin in the same directory
        output_path = yul_path.replace(".yul", ".bin")
        # If yul_path is same as output_path (e.g. if input was .bin?), ensure we don't overwrite source if we can avoid it, 
        # but here we expect .yul input.
    
    # helper to transpile sub-objects (runtime code)
    runtime_bytecode = None
    if top_obj.sub_objects:
        print(f"Found {len(top_obj.sub_objects)} nested objects. Compiling runtime code first...")
        for sub in top_obj.sub_objects:
            # Handle quoted names e.g. "Contract_deployed"
            clean_name = sub.name.strip('"')
            print(f"  • Compiling sub-object: {clean_name}")
            
            try:
                # Determine IR Dump Path
                ir_path = None
                if args.vnm_out:
                    ir_path = args.vnm_out
                elif args.dump_ir:
                    ir_path = output_path
                
                sub_bytecode = transpile_object(sub, vnm_output_path=ir_path, immutables=immutables_map)
                data_map[clean_name] = sub_bytecode
                print(f"    ✓ Success ({len(sub_bytecode)} bytes)")
                
                # Save runtime bytecode for testing even if Init Code fails
                if "_deployed" in clean_name:
                    runtime_bytecode = sub_bytecode
            except Exception as e:
                import traceback
                traceback.print_exc()
                print(f"    ✗ Failed: {e}", file=sys.stderr)
                # import traceback; traceback.print_exc()
                return 1

    # Step 3: Generate Init Code Stub (RUNTIME-ONLY APPROACH)
    # Instead of transpiling init code through Venom (which has complex label issues),
    # we use a minimal init stub that just copies runtime and returns.
    if runtime_bytecode:
        print(f"Generating Init Code Stub for runtime ({len(runtime_bytecode)} bytes)")
        final_bytecode = generate_init_stub(len(runtime_bytecode))
        print(f"    ✓ Init stub: {len(final_bytecode)} bytes")
    else:
        # No sub-objects means no init        # No runtime bytecode - using top-level object as runtime
        print("No runtime bytecode - using top-level object as runtime")
        try:
            final_bytecode = transpile_object(top_obj, data_map=data_map, vnm_output_path=output_path, immutables=immutables_map)
        except Exception as e:
            print(f"✗ Compilation Failed: {e}", file=sys.stderr)
            import traceback; traceback.print_exc()
            return 1
        
    runtime_only = getattr(args, 'runtime_only', False)
    
    # Step 4: Write Output
    if runtime_only:
        # Runtime-only mode: just write runtime bytecode
        if runtime_bytecode:
            with open(output_path, "wb") as f:
                f.write(runtime_bytecode)
            print()
            print("┌─────────────────────────────────────────────────────────")
            print("│ ✓ SUCCESS (Runtime Only)")
            print("├─────────────────────────────────────────────────────────")
            print(f"│ Target: {output_path}")
            print(f"│ Size: {len(runtime_bytecode)} bytes")
            print("└─────────────────────────────────────────────────────────")
        else:
            # No sub-objects - the top-level IS the runtime
            with open(output_path, "wb") as f:
                f.write(final_bytecode)
            print()
            print("┌─────────────────────────────────────────────────────────")
            print("│ ✓ SUCCESS (Runtime Only)")
            print("├─────────────────────────────────────────────────────────")
            print(f"│ Target: {output_path}")
            print(f"│ Size: {len(final_bytecode)} bytes")
            print("└─────────────────────────────────────────────────────────")
    else:
        # Full bytecode mode: init stub + runtime
        if runtime_bytecode:
            # Write runtime for reference
            runtime_bin_path = f"{output_path.replace('.bin', '')}_runtime.bin"
            with open(runtime_bin_path, "wb") as f:
                f.write(runtime_bytecode)
            print(f"│ Runtime: {runtime_bin_path}")
            print(f"│ Runtime Size: {len(runtime_bytecode)} bytes")
            
            # Append runtime to final bytecode (Init Code + Runtime)
            final_bytecode += runtime_bytecode
        
        # Write final bytecode (binary)
        with open(output_path, "wb") as f:
            f.write(final_bytecode)
        
        print()
        print("┌─────────────────────────────────────────────────────────")
        print("│ ✓ SUCCESS")
        print("├─────────────────────────────────────────────────────────")
        print(f"│ Target: {output_path}")
        print(f"│ Size: {len(final_bytecode)} bytes")
        print("└─────────────────────────────────────────────────────────")
    
    return 0


# ============================================================================
# Main
# ============================================================================

def main():
    if sys.version_info < (3, 11):
        print("✗ Error: Yul2Venom requires Python 3.11 or later.", file=sys.stderr)
        print("  Please run with: python3.11 yul2venom.py ...", file=sys.stderr)
        sys.exit(1)

    parser = argparse.ArgumentParser(
        prog="yul2venom",
        description="Yul → Venom IR → EVM bytecode transpiler",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Step 1: Generate config template
  python3 yul2venom.py prepare src/Contract.sol

  # Step 2: Edit yul2venom.config.json (set deployer, nonce, constructor args)
  
  # Step 3: Transpile with address prediction
  python3 yul2venom.py transpile output/Contract.yul
"""
    )
    
    subparsers = parser.add_subparsers(dest="command", help="Commands")
    
    # prepare
    prep = subparsers.add_parser("prepare", help="Analyze contract and generate config template")
    prep.add_argument("contract", help="Solidity contract (.sol)")
    prep.add_argument("-c", "--config", help="Output config path (default: yul2venom.config.json)")
    prep.add_argument("-r", "--remappings", default="remappings.txt", help="Remappings file")
    
    # transpile
    trans = subparsers.add_parser("transpile", help="Transpile to bytecode with address prediction")
    trans.add_argument("config", help="Config file (.yul2venom.json)")
    trans.add_argument("-y", "--yul", help="Yul file (optional, defaults to config.yul)")
    trans.add_argument("-o", "--output", help="Output bytecode path")
    trans.add_argument("-O", "--optimize", choices=["none", "O0", "O2", "O3", "Os", "debug", "yul-o2", "native"], default="O2",
                       help="Optimization level. 'native' uses Vyper's O2 pipeline. 'O2' is the safe Yul pipeline. 'O0' minimal.")
    trans.add_argument("--yul-opt", action="store_true",
                       help="Enable Yul-level source optimization (standard level - strips validators, callvalue)")
    trans.add_argument("--yul-opt-level", choices=["safe", "standard", "aggressive", "maximum"],
                       help="Yul optimizer aggressiveness. safe=minimal, standard=strip callvalue, aggressive=strip all checks, maximum=DANGEROUS strips overflow checks")
    trans.add_argument("--strip-checks", action="store_true",
                       help="Alias for --yul-opt-level=aggressive (strips runtime checks for gas savings)")
    trans.add_argument("--runtime-only", action="store_true", 
                       help="Output only runtime bytecode (no init code). Use for testing with CREATE.")
    trans.add_argument("--dump-ir", action="store_true", help="Dump Intermediate Representation (.vnm files)")
    trans.add_argument("--vnm-out", help="Explicit path for VNM output (overrides default naming)")
    
    args = parser.parse_args()
    
    if args.command == "prepare":
        return cmd_prepare(args)
    elif args.command == "transpile":
        return cmd_transpile(args)
    else:
        parser.print_help()
        return 0


if __name__ == "__main__":
    sys.exit(main())
