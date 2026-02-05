#!/usr/bin/env python3
"""
Yul2Venom - Production-grade Yul to Venom IR transpiler with EVM bytecode generation.

Workflow:
  1. yul2venom prepare <contract.sol>     → Generate config template
  2. [Edit config to fill deployer, nonce, and constructor args]
  3. yul2venom transpile <file.yul>       → Predict addresses & compile

Example:
  $ python3 yul2venom.py prepare src/MyContract.sol
  $ vim yul2venom.config.json  # Fill deployer, nonce, constructor args
  $ python3 yul2venom.py transpile output/MyContract.yul
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
    from yul2venom.optimizer.yul_source_optimizer import YulSourceOptimizer, OptimizationLevel
    from yul2venom.utils.constants import (
        SPILL_OFFSET, RLP_SHORT_STRING, RLP_SHORT_LIST,
        OP_PUSH0, OP_PUSH1, OP_PUSH2, OP_DUP1, OP_CODECOPY, OP_RETURN
    )
except ImportError:
    try:
        from optimizer.yul_source_optimizer import YulSourceOptimizer, OptimizationLevel
        from utils.constants import (
            SPILL_OFFSET, RLP_SHORT_STRING, RLP_SHORT_LIST,
            OP_PUSH0, OP_PUSH1, OP_PUSH2, OP_DUP1, OP_CODECOPY, OP_RETURN
        )
    except ImportError:
        # Fallback if running from root without package context
        sys.path.append(os.path.dirname(os.path.abspath(__file__)))
        from optimizer.yul_source_optimizer import YulSourceOptimizer, OptimizationLevel
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


def discover_sidecar_immutables(yul_code: str, name_to_value: dict) -> dict:
    """Discover sidecar's immutable IDs and build ID→value mapping.
    
    Sidecars have DIFFERENT IDs than parent for SAME semantic names (weth, owner).
    This function:
    1. Extracts immutable names from @src comments in setimmutable patterns
    2. Maps each sidecar ID to corresponding value via semantic name lookup
    
    Args:
        yul_code: The sidecar's Yul source code
        name_to_value: Dict mapping semantic names (weth, owner, etc.) to values
        
    Returns:
        Dict mapping sidecar's immutable IDs to their values
    """
    # Pattern: setimmutable(_X, "ID", mload(/** @src ... "varname = ..." */ OFFSET))
    setimm_with_src_pattern = re.compile(
        r'setimmutable\s*\(\s*\w+\s*,\s*"(\d+)"\s*,\s*mload\s*\(\s*/\*\*\s*@src[^"]*"(\w+)\s*=\s*[^"]*"\s*\*/\s*\d+\s*\)\s*\)'
    )
    
    sidecar_immutables = {}
    
    for match in setimm_with_src_pattern.finditer(yul_code):
        imm_id = int(match.group(1))
        var_name = match.group(2)  # Extract variable name from "varname = ..."
        
        if var_name in name_to_value:
            sidecar_immutables[imm_id] = name_to_value[var_name]
    
    return sidecar_immutables


def extract_sidecar_order_from_yul(yul_code: str) -> list:
    """Extract sidecar object order from Yul init code.
    
    The order of datasize() calls in the Yul init code matches the Solidity
    constructor's CREATE order. This function parses the Yul to extract that order.
    
    We look for patterns like:
        let _3 := datasize("SidecarA_5774")
        let _6 := datasize("SidecarB_4952")
        ...
    
    These appear in the order that `new SidecarContract()` calls appear in Solidity.
    
    The main contract's object name is extracted from the top-level object declaration
    (e.g., `object "MainContract_182"`) and excluded from the sidecar list.
    
    Args:
        yul_code: The Yul source code (typically the main contract's init code)
        
    Returns:
        Ordered list of sidecar init object names (e.g., ['SidecarA_5774', 'SidecarB_4952', ...])
    """
    # First, extract the main contract's object name from the top-level object declaration
    # Pattern: object "ContractName_NNNN" at the beginning of the file
    main_contract_pattern = re.compile(r'^\s*object\s+"([^"]+)"', re.MULTILINE)
    main_contract_match = main_contract_pattern.search(yul_code)
    main_contract_name = main_contract_match.group(1) if main_contract_match else None
    
    # Pattern: datasize("ObjectName") where ObjectName does NOT end in _deployed
    # The _deployed suffix indicates runtime code, not init code
    datasize_pattern = re.compile(r'datasize\s*\(\s*"([^"]+)"\s*\)')
    
    seen = set()
    ordered = []
    
    for match in datasize_pattern.finditer(yul_code):
        obj_name = match.group(1)
        # Skip _deployed objects (we want init object names, not runtime)
        if "_deployed" in obj_name:
            continue
        # Skip the main contract's own object - it's NOT a sidecar
        if main_contract_name and obj_name == main_contract_name:
            continue
        if obj_name not in seen:
            seen.add(obj_name)
            ordered.append(obj_name)
    
    return ordered


def compute_sidecar_addresses(yul_code: str, config: dict) -> dict:
    """Compute correct sidecar addresses based on Yul order and config.
    
    This function:
    1. Extracts ALL sidecar names from Yul in CREATE order
    2. Determines which are immutables (in auto_predicted) vs storage slots
    3. Calculates correct nonces for each based on actual position
    4. Computes CREATE addresses for immutable sidecars
    
    Args:
        yul_code: The Yul source code
        config: The transpiler config dict with deployment, auto_predicted, etc.
        
    Returns:
        Dict mapping sidecar names to their computed addresses, plus updated nonces
    """
    # Extract full sidecar order from Yul
    full_order = extract_sidecar_order_from_yul(yul_code)
    if not full_order:
        return {}
    
    # Get deployment info from config
    deployment = config.get('deployment', {})
    deployer = deployment.get('deployer', '')
    main_nonce = deployment.get('nonce', 0)
    
    if not deployer or main_nonce is None:
        print(f"  [WARN] compute_sidecar_addresses: missing deployment info", file=sys.stderr)
        return {}
    
    # Compute main contract address
    main_addr = compute_create_address(deployer, main_nonce)
    
    # Get auto_predicted from config to know which sidecars are immutables
    auto_predicted = config.get('auto_predicted', {})
    
    # Build lowercase name mapping for matching (Yul names like "SidecarPath_5012" -> "sidecarPath")
    # Config uses camelCase like "sidecarPath", "helperPath"
    def normalize_name(yul_name: str) -> str:
        """Convert Yul name like 'SidecarPath_5012' to config name like 'sidecarPath'.
        
        Handles uppercase prefixes/acronyms by lowercasing leading uppercase chars.
        """
        # Remove numeric suffix
        base = yul_name.rsplit('_', 1)[0]
        if not base:
            return base
        
        # Lowercase all leading uppercase chars until we hit lowercase or digit
        result = []
        found_lower = False
        for i, c in enumerate(base):
            if not found_lower and c.isupper():
                # Check if next char exists and is lowercase (end of acronym)
                if i + 1 < len(base) and base[i + 1].islower():
                    # This is the last uppercase before lowercase, keep as uppercase
                    # for CamelCase like "CurvePath" -> "curvePath"
                    result.append(c.lower())
                    found_lower = True
                else:
                    result.append(c.lower())
            else:
                result.append(c)
                if c.islower():
                    found_lower = True
        
        return ''.join(result)
    
    # Calculate addresses for each sidecar based on position in full order
    computed = {}
    nonce_updates = {}
    
    # Build case-insensitive lookup for auto_predicted keys
    auto_predicted_lower = {k.lower(): k for k in auto_predicted.keys()}
    
    for idx, yul_name in enumerate(full_order):
        sidecar_nonce = idx + 1  # Nonce starts at 1 for first CREATE from main contract
        config_name = normalize_name(yul_name).lower()  # Normalize and lowercase
        
        # Case-insensitive lookup for config key
        actual_key = auto_predicted_lower.get(config_name)
        
        # Only compute for sidecars that are in auto_predicted (immutables)
        if actual_key:
            computed_addr = compute_create_address(main_addr, sidecar_nonce)
            old_predicted = auto_predicted[actual_key].get('predicted_value', '')
            old_order = auto_predicted[actual_key].get('order', -1)
            
            # Check if address OR order changed
            addr_changed = old_predicted.lower() != computed_addr.lower()
            order_changed = old_order != sidecar_nonce
            
            # Always add to computed dict for refresh, report changes
            if addr_changed or order_changed:
                changes = []
                if addr_changed:
                    changes.append(f"addr {old_predicted} -> {computed_addr}")
                if order_changed:
                    changes.append(f"order {old_order} -> {sidecar_nonce}")
                print(f"  [INFO] Sidecar {actual_key}: {', '.join(changes)}", file=sys.stderr)
            
            # Always include in computed dict for refresh (use actual_key for config update)
            computed[actual_key] = {
                'address': computed_addr,
                'old_address': old_predicted,
                'nonce': sidecar_nonce,
                'old_nonce': old_order,
                'yul_name': yul_name,
                'changed': addr_changed or order_changed
            }
            nonce_updates[actual_key] = sidecar_nonce
    
    return {'computed': computed, 'nonce_updates': nonce_updates, 'main_addr': main_addr, 'full_order': full_order}


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
        """Find assignments like: sidecar = address(new SidecarContract(...))"""
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
    # Output Yul to output/ directory (SCRIPT_DIR-relative for consistency)
    contract_name = Path(contract_path).stem
    
    # Use existing yul path from config if available
    if existing_config.get("yul"):
        existing_yul = existing_config["yul"]
        # Resolve relative to SCRIPT_DIR (backward compatibility with existing configs)
        if not os.path.isabs(existing_yul):
            yul_output_path = os.path.normpath(os.path.join(str(SCRIPT_DIR), existing_yul))
        else:
            yul_output_path = existing_yul
    else:
        # Default: output/ directory relative to SCRIPT_DIR
        yul_output_path = os.path.join(str(SCRIPT_DIR), "output", f"{contract_name}.yul")
        yul_output_path = os.path.normpath(yul_output_path)
    
    os.makedirs(os.path.dirname(yul_output_path), exist_ok=True)
    
    # Check if Yul already exists - solc generates different IDs each time!
    # If Yul exists, we should use it rather than regenerating
    using_existing_yul = os.path.exists(yul_output_path) and not getattr(args, 'force', False)
    if using_existing_yul:
        print(f"Using existing Yul: {yul_output_path}")
        print("  (Use --force to regenerate. Note: regeneration changes immutable IDs!)")
        with open(yul_output_path, 'r') as f:
            raw_yul = f.read()
    else:
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
        
        raw_yul = result.stdout
    
    # Extract _deployed object from solc output
    contract_name = Path(contract_path).stem
    
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

    # Only extract Yul objects if we regenerated (not when using existing)
    if not using_existing_yul:
        # Match: object "ContractName_NNN" (with any numeric suffix)
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

    # CRITICAL FIX: Extract actual immutable IDs from FULL Yul output (before extraction)
    # The Solidity AST IDs don't match the IDs generated by solc in Yul output
    # We scan for setimmutable patterns and map by memory offset
    # IMPORTANT: Use raw_yul (full output), not extracted main contract, to capture sidecar IDs
    print()
    print("  Analyzing immutables from Yul output...")
    
    yul_content = raw_yul  # Use full solc output, includes all sub-objects
    
    # Extract immutable names from @src comments in setimmutable patterns
    # Pattern: setimmutable(_X, "ID", mload(/** @src ... "varname = ..." */ OFFSET))
    setimm_with_src_pattern = re.compile(
        r'setimmutable\s*\(\s*\w+\s*,\s*"(\d+)"\s*,\s*mload\s*\(\s*/\*\*\s*@src[^"]*"(\w+)\s*=\s*[^"]*"\s*\*/\s*(\d+)\s*\)\s*\)'
    )
    
    # Also handle case without @src comment (optimized Yul)
    setimm_no_src_pattern = re.compile(
        r'setimmutable\s*\(\s*\w+\s*,\s*"(\d+)"\s*,\s*mload\s*\(\s*(\d+)\s*\)\s*\)'
    )
    
    # Build offset_to_id and offset_to_name from Yul with @src comments
    offset_to_id = {}
    offset_to_name = {}
    
    for match in setimm_with_src_pattern.finditer(yul_content):
        imm_id = match.group(1)
        var_name = match.group(2)  # Extract variable name from "varname = ..."
        offset = int(match.group(3))
        if offset not in offset_to_id:
            offset_to_id[offset] = imm_id
            offset_to_name[offset] = var_name
    
    # Fallback: if no @src comments (optimized Yul), use simple pattern
    if not offset_to_id:
        for match in setimm_no_src_pattern.finditer(yul_content):
            imm_id = match.group(1)
            offset = int(match.group(2))
            if offset not in offset_to_id:
                offset_to_id[offset] = imm_id
    
    # Build name_to_order based on sorted offsets
    # This maps each immutable name to its position in declaration order
    sorted_offsets = sorted(offset_to_name.keys())
    name_to_order = {}
    for order, offset in enumerate(sorted_offsets):
        name = offset_to_name[offset]
        name_to_order[name] = order
    
    # Update constructor_args and created_immutables with IDs and ORDER from Yul
    if offset_to_id:
        print(f"    Found {len(offset_to_id)} immutables in Yul")
        
        # Map by discovered names from @src comments
        for offset, name in offset_to_name.items():
            imm_id = offset_to_id[offset]
            order = name_to_order.get(name, 999)
            
            if name in constructor_args:
                constructor_args[name]['id'] = imm_id
                constructor_args[name]['order'] = order
                print(f"    • {name}: ID {imm_id} (offset {offset}, order {order})")
            elif name in created_immutables:
                created_immutables[name]['id'] = imm_id
                created_immutables[name]['order'] = order
                print(f"    • {name}: ID {imm_id} (offset {offset}, order {order})")
    
    # LIBRARY DETECTION: Scan for linkersymbol calls in Yul
    # Pattern: linkersymbol("path/to/Contract.sol:LibraryName")
    print()
    print("  Analyzing external libraries from Yul output...")
    
    linker_pattern = re.compile(r'linkersymbol\s*\(\s*"([^"]+)"\s*\)')
    library_refs = set()
    
    for match in linker_pattern.finditer(yul_content):
        lib_path = match.group(1)
        library_refs.add(lib_path)
    
    if library_refs:
        print(f"    Found {len(library_refs)} external library reference(s):")
        for lib in sorted(library_refs):
            # Extract library name from path (e.g., "contracts/Lib.sol:MyLib" -> "MyLib")
            lib_name = lib.split(':')[-1] if ':' in lib else lib.split('/')[-1]
            print(f"    • {lib_name} ({lib})")
    else:
        print("    No external libraries detected")
    
    # Build config - merge with existing
    # Use relative paths (relative to SCRIPT_DIR for portability)
    def make_relative(p, base_dir=SCRIPT_DIR):
        try:
            return str(Path(p).relative_to(base_dir))
        except ValueError:
            return p  # Return as-is if not under base_dir
    
    config = {
        "version": "1.0",
        "contract": make_relative(os.path.abspath(contract_path)),
        "yul": make_relative(yul_output_path),
        "deployment": {
            "deployer": existing_config.get("deployment", {}).get("deployer", "0x1234567890123456789012345678901234567890"),
            "nonce": existing_config.get("deployment", {}).get("nonce", 0)
        },
        # sidecar_nonce_start is ALWAYS 1 for contracts deployed from constructor
        # (a newly created contract starts at nonce 1 for its first CREATE)
        "sidecar_nonce_start": 1,
        "constructor_args": {},
        "auto_predicted": {},
        "library_addresses": {}
    }
    
    # Add constructor args - preserve existing values
    # NOTE: IDs are optional - transpiler discovers actual IDs from Yul
    existing_args = existing_config.get("constructor_args", {})
    for name, info in constructor_args.items():
        config["constructor_args"][name] = {
            "type": info['type'],
            "value": existing_args.get(name, {}).get("value", "")
        }
        # Include order field - REQUIRED for correct immutable mapping
        if 'order' in info:
            config["constructor_args"][name]["order"] = info['order']
        # Optionally include ID for documentation (not used by transpiler)
        if info.get('id'):
            config["constructor_args"][name]["id"] = info['id']
    
    # Add auto-predicted immutables - preserve existing values
    # NOTE: IDs are optional - transpiler discovers actual IDs from Yul
    existing_auto = existing_config.get("auto_predicted", {})
    for name, info in created_immutables.items():
        existing_val = existing_auto.get(name, {})
        config["auto_predicted"][name] = {
            "type": info['type']
        }
        # Include order field - REQUIRED for correct immutable mapping
        if 'order' in info:
            config["auto_predicted"][name]["order"] = info['order']
        # Optionally include ID for documentation
        if info.get('id'):
            config["auto_predicted"][name]["id"] = info['id']
        # Preserve manual value override if present
        if "value" in existing_val:
            config["auto_predicted"][name]["value"] = existing_val["value"]
    
    # Add library addresses - preserve existing values
    # Libraries must be provided by user (cannot be auto-predicted)
    existing_libs = existing_config.get("library_addresses", {})
    for lib_path in library_refs:
        # Extract short name for display
        lib_name = lib_path.split(':')[-1] if ':' in lib_path else lib_path.split('/')[-1]
        existing_val = existing_libs.get(lib_path, {})
        config["library_addresses"][lib_path] = {
            "name": lib_name,
            "type": "address",
            "value": existing_val.get("value", "")
        }
    
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
        print("│ ⚠ REQUIRED - Fill these constructor args:")
        for name, info in constructor_args.items():
            existing_val = existing_args.get(name, {}).get("value", "")
            status = "✓" if existing_val else "•"
            print(f"│   {status} {name}: {info['type']}" + (f" = {existing_val}" if existing_val else ""))
        print("│")
    
    if library_refs:
        print("│ ⚠ REQUIRED - Fill these library addresses:")
        for lib_path in sorted(library_refs):
            lib_name = lib_path.split(':')[-1] if ':' in lib_path else lib_path.split('/')[-1]
            existing_val = existing_libs.get(lib_path, {}).get("value", "")
            status = "✓" if existing_val else "•"
            print(f"│   {status} {lib_name}" + (f" = {existing_val}" if existing_val else ""))
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
    
    # Resolve relative paths to absolute
    # CLI paths: relative to CWD
    # Config paths: try SCRIPT_DIR first (canonical), then config-relative (for external projects)
    if yul_path and not os.path.isabs(yul_path):
        if args.yul:
            # CLI argument - relative to CWD
            yul_path = os.path.abspath(yul_path)
        else:
            # From config - try SCRIPT_DIR first (canonical for internal configs)
            script_relative_path = os.path.normpath(os.path.join(str(SCRIPT_DIR), yul_path))
            
            if os.path.exists(script_relative_path):
                yul_path = script_relative_path
            else:
                # Fallback: config-relative (for external projects)
                config_dir = os.path.dirname(os.path.abspath(config_path))
                config_relative_path = os.path.normpath(os.path.join(config_dir, yul_path))
                if os.path.exists(config_relative_path):
                    yul_path = config_relative_path
                else:
                    # Neither exists - use SCRIPT_DIR path for error message
                    yul_path = script_relative_path
    
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
    
    # Validate library addresses (skip if empty - not all contracts use libraries)
    library_addresses_config = config.get("library_addresses", {})
    missing_libs = []
    for lib_path, info in library_addresses_config.items():
        if not info.get("value"):
            lib_name = info.get("name", lib_path.split(':')[-1] if ':' in lib_path else lib_path)
            missing_libs.append(lib_name)
    
    if missing_libs:
        print("✗ Error: Missing library address values:", file=sys.stderr)
        for name in missing_libs:
            print(f"  • {name}", file=sys.stderr)
        print(f"  Edit {config_path} and fill in library addresses", file=sys.stderr)
        return 1
    
    # Build library_addresses map for context
    library_addresses = {}
    for lib_path, info in library_addresses_config.items():
        if info.get("value"):
            library_addresses[lib_path] = info["value"]
    
    # Predict addresses
    print("┌─────────────────────────────────────────────────────────")
    print("│ Address Prediction")
    print("├─────────────────────────────────────────────────────────")
    print(f"│ Deployer: {deployer}")
    print(f"│ Nonce: {nonce}")
    
    main_contract = compute_create_address(deployer, nonce)
    print(f"│ Main Contract: {main_contract}")
    print("│")
    
    # NOTE: We don't build immutables_map here anymore.
    # Config IDs are unreliable (solc generates different IDs each run).
    # Instead, we scan Yul during transpilation to discover actual IDs.
    # Here we just collect name -> value for use later.
    
    # Print constructor args (values will be mapped to IDs later from Yul)
    print("│ Constructor Args:")
    for name, info in constructor_args.items():
        value = info['value']
        print(f"│   • {name} = {value}")
    
    # Predict CREATE addresses and update config
    auto_predicted = config.get("auto_predicted", {})
    config_updated = False
    if auto_predicted:
        print("│")
        print("│ Auto-Predicted (CREATE addresses):")
        # Allow config to specify starting nonce (e.g., when storage sidecars are created first)
        sidecar_nonce = config.get("sidecar_nonce_start", 1)
        # Sort by explicit 'order' field if present, otherwise by name
        # Skip comment fields
        sidecar_names = [n for n in auto_predicted.keys() if not n.startswith('_')]
        def get_order(n):
            return auto_predicted[n].get('order', 999)  # 999 = no order, sorts last
        sidecar_names_sorted = sorted(sidecar_names, key=lambda n: (get_order(n), n))
        
        for name in sidecar_names_sorted:
            info = auto_predicted[name]
            predicted = compute_create_address(main_contract, sidecar_nonce)
            print(f"│   • {name} (nonce {sidecar_nonce}) = {predicted}")
            # Update config with predicted value
            if info.get('predicted_value') != predicted:
                config["auto_predicted"][name]["predicted_value"] = predicted
                config_updated = True
            sidecar_nonce += 1
    
    # Write updated config with predicted addresses
    if config_updated:
        with open(config_path, 'w') as f:
            json.dump(config, f, indent=2)
        print("│")
        print("│ ✓ Config updated with predicted addresses")
    
    print("└─────────────────────────────────────────────────────────")

    print()
    
    # Step 0: Read Yul and discover immutable IDs
    print(f"Optimizing Yul: {yul_path}")
    try:
        with open(yul_path, 'r') as f:
            raw_yul = f.read()
        
        # CRITICAL FIX: Auto-detect sidecar order from Yul and recalculate addresses
        # This handles cases where storage-slot sidecars (e.g., ApprovePath) are created
        # before immutable sidecars, shifting all nonces.
        sidecar_addr_info = compute_sidecar_addresses(raw_yul, config)
        if sidecar_addr_info and sidecar_addr_info.get('computed'):
            print(f"  [INFO] Auto-detected sidecar order from Yul:")
            print(f"         Full order: {sidecar_addr_info.get('full_order', [])}")
            
            # Always refresh auto_predicted with computed addresses and orders
            config_changed = False
            for sidecar_name, info in sidecar_addr_info['computed'].items():
                if sidecar_name in auto_predicted:
                    old_addr = auto_predicted[sidecar_name].get('predicted_value', '')
                    old_order = auto_predicted[sidecar_name].get('order', -1)
                    new_addr = info['address']
                    new_order = info['nonce']
                    
                    # Update both address and order
                    auto_predicted[sidecar_name]['predicted_value'] = new_addr
                    auto_predicted[sidecar_name]['order'] = new_order
                    
                    if info.get('changed'):
                        print(f"         Fixed {sidecar_name}: addr={new_addr}, order={new_order}")
                        config_changed = True
            
            # Update config in memory and write to file
            config['auto_predicted'] = auto_predicted
            with open(config_path, 'w') as f:
                json.dump(config, f, indent=2)
            if config_changed:
                print(f"         ✓ Config updated with corrected sidecar addresses")
            else:
                print(f"         ✓ Config refreshed (no changes)")
            config_updated = True
        
        # CRITICAL: Scan Yul to discover actual immutable IDs
        # solc generates different IDs each compile - we can't rely on config IDs
        # We map by memory offset (stable based on declaration order in StorageLayout)
        
        # Strip Yul comments first (/** @src ... */ breaks regex matching)
        # Reuse pattern from optimizer/yul_source_optimizer.py
        yul_no_comments = re.sub(r'/\*[\s\S]*?\*/', '', raw_yul)
        
        # IMPORTANT: First scan RAW Yul (with @src comments) for name→ID mapping
        # Pattern: setimmutable(_X, "ID", mload(/** @src ... "varname = ..." */ OFFSET))
        setimm_with_src_pattern = re.compile(
            r'setimmutable\s*\(\s*\w+\s*,\s*"(\d+)"\s*,\s*mload\s*\(\s*/\*\*\s*@src[^"]*"(\w+)\s*=\s*[^"]*"\s*\*/\s*(\d+)\s*\)\s*\)'
        )
        
        # Build name_to_yul_id from @src comments (most reliable, from raw Yul)
        name_to_yul_id = {}  # name -> ID discovered from Yul @src
        offset_to_name_yul = {}  # offset -> name for positional fallback
        for match in setimm_with_src_pattern.finditer(raw_yul):
            imm_id = match.group(1)
            var_name = match.group(2)
            offset = int(match.group(3))
            if var_name not in name_to_yul_id:
                name_to_yul_id[var_name] = imm_id
                offset_to_name_yul[offset] = var_name
        
        if name_to_yul_id:
            print(f"│ Discovered {len(name_to_yul_id)} named immutables from Yul @src comments")
        
        # Fallback: scan simplified Yul (no comments) for offset→ID mapping
        setimm_pattern = re.compile(r'setimmutable\s*\(\s*\w+\s*,\s*"(\d+)"\s*,\s*mload\s*\(\s*(\d+)\s*\)\s*\)')
        offset_to_ids = {}  # offset -> list of IDs
        for match in setimm_pattern.finditer(yul_no_comments):
            imm_id = int(match.group(1))
            offset = int(match.group(2))
            if offset not in offset_to_ids:
                offset_to_ids[offset] = []
            if imm_id not in offset_to_ids[offset]:
                offset_to_ids[offset].append(imm_id)
        
        # DIRECT ID MAPPING: Use 'id' field from config if present
        # This is more reliable than positional matching since solc IDs are stable per compile
        # Fallback to positional matching only if 'id' fields are missing
        
        # Build immutables_map: ID -> value
        immutables_map = {}
        print("│")
        print("│ Immutable ID Discovery:")
        
        # First pass: Direct ID mapping from config 'id' field
        direct_mapped = set()
        for name, info in constructor_args.items():
            value = info.get('value', '')
            config_id = info.get('id')
            if config_id and value:
                if isinstance(value, str) and value.startswith("0x"):
                    val = int(value, 16)
                else:
                    val = int(value)
                # Config ID is string, convert to int for immutables_map
                imm_id = int(config_id)
                immutables_map[imm_id] = val
                direct_mapped.add(name)
                print(f"│   • {name} (id {config_id}): = {hex(val)}")
        
        for name, info in auto_predicted.items():
            if name.startswith('_'):  # Skip comment fields
                continue
            value = info.get('predicted_value', info.get('value', ''))
            config_id = info.get('id')
            if config_id and value:
                if isinstance(value, str) and value.startswith("0x"):
                    val = int(value, 16)
                else:
                    val = int(value)
                imm_id = int(config_id)
                immutables_map[imm_id] = val
                direct_mapped.add(name)
                print(f"│   • {name} (id {config_id}): = {hex(val)}")
        
        # Second pass: Positional fallback for entries without 'id' field
        # Collect unmapped config entries and unmapped Yul IDs
        if offset_to_ids:
            yul_ids_used = set(immutables_map.keys())
            unmapped_offsets = []
            for offset in sorted(offset_to_ids.keys()):
                for imm_id in offset_to_ids[offset]:
                    if imm_id not in yul_ids_used:
                        unmapped_offsets.append((offset, imm_id))
            
            # Collect config entries without 'id' field
            unmapped_configs = []
            for name, info in constructor_args.items():
                if name not in direct_mapped and info.get('value'):
                    value = info.get('value', '')
                    order = info.get('order', 999)
                    if isinstance(value, str) and value.startswith("0x"):
                        unmapped_configs.append((name, int(value, 16), order))
                    else:
                        unmapped_configs.append((name, int(value), order))
            
            for name, info in auto_predicted.items():
                if name.startswith('_') or name in direct_mapped:
                    continue
                value = info.get('predicted_value', info.get('value', ''))
                order = info.get('order', 999)
                if value:
                    if isinstance(value, str) and value.startswith("0x"):
                        unmapped_configs.append((name, int(value, 16), order))
                    else:
                        unmapped_configs.append((name, int(value), order))
            
            # Sort unmapped configs by order for positional matching
            unmapped_configs.sort(key=lambda x: x[2])
            
            # Match positionally AND track discovered IDs by name
            discovered_ids = {}  # name -> id for config update
            for i, (offset, imm_id) in enumerate(unmapped_offsets):
                if i < len(unmapped_configs):
                    name, value, order = unmapped_configs[i]
                    immutables_map[imm_id] = value
                    discovered_ids[name] = str(imm_id)  # Store as string for JSON
                    print(f"│   • {name} (offset {offset}, order {order}): ID {imm_id} = {hex(value)} [positional]")
        
        print(f"│ Total: {len(immutables_map)} immutable IDs mapped")
        
        # =========================================================================
        # CRITICAL FIX: Update config with discovered IDs
        # solc generates different IDs each compile, so we need to sync config
        # Merge IDs from @src comments (name_to_yul_id) + positional matching (discovered_ids)
        # =========================================================================
        
        # Merge: prefer @src-based IDs (direct name mapping) over positional
        all_discovered_ids = dict(name_to_yul_id)  # Start with @src-based
        all_discovered_ids.update(discovered_ids)  # Add positional (won't override @src)
        
        config_ids_updated = False
        
        # Update constructor_args with discovered IDs
        for name, info in constructor_args.items():
            if name in all_discovered_ids:
                new_id = all_discovered_ids[name]
                if info.get('id') != new_id:
                    config['constructor_args'][name]['id'] = new_id
                    config_ids_updated = True
                    print(f"│   ↳ Updated constructor_args.{name}.id = {new_id}")
        
        # Update auto_predicted with discovered IDs (AND compute new addresses)
        for name, info in auto_predicted.items():
            if name.startswith('_'):
                continue
            if name in all_discovered_ids:
                new_id = all_discovered_ids[name]
                if info.get('id') != new_id:
                    config['auto_predicted'][name]['id'] = new_id
                    config_ids_updated = True
                    print(f"│   ↳ Updated auto_predicted.{name}.id = {new_id}")
        
        # Write updated config if any IDs changed
        if config_ids_updated:
            with open(config_path, 'w') as f:
                json.dump(config, f, indent=2)
            print(f"│ ✓ Config IDs synced with Yul")
        
        # Build name_to_value for sidecar immutable resolution
        # Sidecars have DIFFERENT IDs but SAME semantic names (weth, owner, etc.)
        name_to_value = {}
        for name, info in constructor_args.items():
            value = info.get('value', '')
            if isinstance(value, str) and value.startswith("0x"):
                name_to_value[name] = int(value, 16)
            elif value:
                name_to_value[name] = int(value)
        for name, info in auto_predicted.items():
            if name.startswith('_'):
                continue
            value = info.get('predicted_value', info.get('value', ''))
            if isinstance(value, str) and value.startswith("0x"):
                name_to_value[name] = int(value, 16)
            elif value:
                name_to_value[name] = int(value)
            
        opt_config = config.copy()
        
        # Configure YulSourceOptimizer based on CLI flags or config file
        # Levels: safe, standard, aggressive, maximum
        # Priority: CLI args > config file > disabled
        yul_opt_level = getattr(args, 'yul_opt_level', None)
        
        # Get the global transpiler config (from yul2venom.config.yaml)
        from config import get_config
        transpiler_cfg = get_config()
        
        # Determine optimization level from CLI or config
        if yul_opt_level:
            # CLI flag takes priority
            level = OptimizationLevel(yul_opt_level)
        elif getattr(args, 'strip_checks', False):
            level = OptimizationLevel.AGGRESSIVE
        elif getattr(args, 'yul_opt', False):
            level = OptimizationLevel.STANDARD
        elif transpiler_cfg.yul_optimizer.level and transpiler_cfg.yul_optimizer.level != 'none':
            # Use config file setting
            level = OptimizationLevel(transpiler_cfg.yul_optimizer.level)
        else:
            level = None  # Disabled
        
        if level:
            print(f"Running Yul source optimizer (level: {level.value})...", file=sys.stderr)
            opt = YulSourceOptimizer(level=level, config=config)
            optimized_yul = opt.optimize(raw_yul)
            opt.print_report()
        else:
            # Skip Yul optimizer
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
        from yul2venom.parser.yul_parser import YulParser
    except ImportError:
        # Fallback for local run
        from parser.yul_parser import YulParser

    yul_source = open(yul_path).read()
    parser = YulParser(yul_source)
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
    def transpile_object(obj, data_map=None, vnm_output_path=None, immutables=None, offset_map=None):
        # 1. Build IR
        try:
            from yul2venom.generator.venom_generator import VenomIRBuilder
        except ImportError:
            from generator.venom_generator import VenomIRBuilder
            
        builder = VenomIRBuilder()
        ir_vnm = builder.build(obj, data_map=data_map, immutables=immutables, offset_map=offset_map, library_addresses=library_addresses)
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
            
            # Inject library addresses if present
            if library_addresses:
                ctx.library_addresses = library_addresses
                print(f"DEBUG: Injected {len(library_addresses)} library addresses into context")


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
        
        # CLEANUP: Remove redundant phis created by MakeSSA
        # These include: (1) self-referential phis where all operand values are the output itself
        #                (2) duplicate phi definitions for the same variable in the same block
        for fn in ctx.functions.values():
            for bb in list(fn.get_basic_blocks()):
                seen_outputs = {}  # Track which outputs have been defined
                instructions_to_remove = []
                
                for inst in list(bb.instructions):
                    if inst.opcode == "phi":
                        output = inst.output
                        # Check if phi is self-referential (all values are the output itself)
                        operands = inst.operands
                        values = [op for i, op in enumerate(operands) if i % 2 == 1]  # Every second operand is a value
                        is_self_ref = all(v == output for v in values)
                        
                        if is_self_ref:
                            # Self-referential phi - mark for removal
                            instructions_to_remove.append(inst)
                        elif output in seen_outputs:
                            # Duplicate phi for same output - mark for removal
                            instructions_to_remove.append(inst)
                        else:
                            seen_outputs[output] = inst
                
                # Remove marked instructions
                for inst in instructions_to_remove:
                    if inst in bb.instructions:
                        bb.instructions.remove(inst)
        
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

    # Step 2: Compile Sub-Objects (Runtime Code + Nested Sidecars)
    data_map = {}
    
    # NESTED SUB-OBJECTS SUPPORT: Recursively collect ALL sub-objects including sidecars
    def collect_all_subobjects(obj, depth=0):
        """Recursively collect all sub-objects with their depth level."""
        result = []
        for sub in obj.sub_objects:
            clean_name = sub.name.strip('"')
            result.append((sub, clean_name, depth))
            # Recursively collect nested sub-objects (e.g., sidecars inside _deployed)
            result.extend(collect_all_subobjects(sub, depth + 1))
        return result
    
    # Determine output path immediately so it can be used for .vnm generation
    if not output_path:
        # Default: replace .yul with .bin in the same directory
        output_path = yul_path.replace(".yul", ".bin")
        # If yul_path is same as output_path (e.g. if input was .bin?), ensure we don't overwrite source if we can avoid it, 
        # but here we expect .yul input.
    
    # Collect ALL sub-objects recursively (runtime + sidecars)
    all_subobjects = collect_all_subobjects(top_obj)
    runtime_bytecode = None
    sidecar_bytecodes = []  # List of (name, bytecode) for sidecars
    
    if all_subobjects:
        print(f"Found {len(all_subobjects)} sub-objects (including nested sidecars). Compiling...")
        
        # CRITICAL: Process deepest objects FIRST so their bytecode is available for parents
        # Sort by depth descending (deepest first), then by _deployed suffix (deployed FIRST), then by name
        # CRITICAL: _deployed must come BEFORE init at same depth so runtime bytecode is available for datasize/dataoffset
        sorted_subobjects = sorted(all_subobjects, key=lambda x: (-x[2], 0 if "_deployed" in x[1] else 1, x[1]))
        
        for sub, clean_name, depth in sorted_subobjects:
            indent = "  " * (depth + 1)
            print(f"{indent}• Compiling sub-object: {clean_name} (depth {depth})")
            
            try:
                # Determine IR Dump Path
                ir_path = None
                if args.vnm_out:
                    ir_path = args.vnm_out
                elif args.dump_ir:
                    ir_path = output_path
                
                # SIDECAR IMMUTABLE RESOLUTION: Discover sidecar's own IDs
                # Sidecars have DIFFERENT IDs but SAME semantic names (weth, owner)
                # Use original (non-optimized) Yul to find @src comments with variable names
                sidecar_immutables = discover_sidecar_immutables(raw_yul, name_to_value)
                
                # Merge: sidecar-specific IDs take precedence, fallback to parent's
                merged_immutables = immutables_map.copy()
                merged_immutables.update(sidecar_immutables)
                
                if sidecar_immutables:
                    print(f"{indent}    [Sidecar] Discovered {len(sidecar_immutables)} immutable IDs")
                
                # For sidecar INIT objects, we need TWO-PASS approach
                # because the init code calls datasize("SidecarName") which is init + runtime
                # AND needs literal offset for dataoffset("SidecarName_deployed")
                if "_deployed" not in clean_name:
                    sidecar_runtime_name = f"{clean_name}_deployed"
                    if sidecar_runtime_name in data_map:
                        sidecar_runtime = data_map[sidecar_runtime_name]
                        runtime_size = len(sidecar_runtime)
                        
                        # PASS 1: Estimate with placeholder (runtime_size + typical init overhead)
                        # Sidecar init is typically small (~100-200 bytes)
                        estimated_init_size = 200  # Conservative estimate
                        estimated_total = estimated_init_size + runtime_size
                        data_map[clean_name] = bytes(estimated_total)
                        
                        # Create offset_map for sidecar transpilation
                        # Layout: [sidecar_init][sidecar_runtime]
                        # dataoffset("X_deployed") = init_size (where runtime starts)
                        sidecar_offset_map = {
                            sidecar_runtime_name: estimated_init_size
                        }
                        
                        sub_bytecode_p1 = transpile_object(sub, data_map=data_map, vnm_output_path=None, 
                                                           immutables=merged_immutables,
                                                           offset_map=sidecar_offset_map)
                        init_size = len(sub_bytecode_p1)
                        
                        # PASS 2: Re-transpile with actual init + runtime size
                        actual_size = init_size + runtime_size
                        data_map[clean_name] = bytes(actual_size)
                        sidecar_offset_map[sidecar_runtime_name] = init_size
                        
                        sub_bytecode = transpile_object(sub, data_map=data_map, vnm_output_path=ir_path, 
                                                        immutables=merged_immutables,
                                                        offset_map=sidecar_offset_map)
                        
                        # Convergence check
                        if len(sub_bytecode) != init_size:
                            # One more pass for convergence
                            init_size = len(sub_bytecode)
                            actual_size = init_size + runtime_size
                            data_map[clean_name] = bytes(actual_size)
                            sidecar_offset_map[sidecar_runtime_name] = init_size
                            sub_bytecode = transpile_object(sub, data_map=data_map, vnm_output_path=ir_path, 
                                                            immutables=merged_immutables,
                                                            offset_map=sidecar_offset_map)
                        
                        # Full sidecar = init + runtime
                        full_sidecar = sub_bytecode + sidecar_runtime
                        sidecar_bytecodes.append((clean_name, full_sidecar))
                        data_map[clean_name] = full_sidecar
                        print(f"{indent}    ✓ Success ({len(sub_bytecode)} init + {runtime_size} runtime = {len(full_sidecar)} bytes)")
                        continue
                    else:
                        # No runtime found, transpile as-is
                        sub_bytecode = transpile_object(sub, data_map=data_map, vnm_output_path=ir_path, immutables=merged_immutables)
                        data_map[clean_name] = sub_bytecode
                        sidecar_bytecodes.append((clean_name, sub_bytecode))
                        print(f"{indent}    ✓ Success ({len(sub_bytecode)} bytes)")
                        continue
                
                # For _deployed objects, just transpile normally
                sub_bytecode = transpile_object(sub, data_map=data_map, vnm_output_path=ir_path, immutables=merged_immutables)
                data_map[clean_name] = sub_bytecode
                print(f"{indent}    ✓ Success ({len(sub_bytecode)} bytes)")
                
                # Handle main contract runtime (depth 0)
                if "_deployed" in clean_name and depth == 0:
                    runtime_bytecode = sub_bytecode
                    
            except Exception as e:
                import traceback
                traceback.print_exc()
                print(f"{indent}    ✗ Failed: {e}", file=sys.stderr)


    # Step 3: Generate Init Code
    with_init = getattr(args, 'with_init', False)
    
    if runtime_bytecode:
        if with_init:
            # FULL INIT SUPPORT: Transpile the outer object (constructor code)
            # Uses TWO-PASS APPROACH to resolve datasize("OuterObject") correctly:
            #   Pass 1: Estimate init size with placeholder outer object entry
            #   Pass 2: Re-transpile with correct init+runtime size
            print(f"Transpiling Init Code (--with-init mode)")
            try:
                # Determine IR Dump Path for init
                init_ir_path = None
                if args.vnm_out:
                    init_ir_path = args.vnm_out.replace('.vnm', '_init.vnm')
                elif args.dump_ir:
                    init_ir_path = output_path.replace('.bin', '_init.vnm')
                
                # Get outer object name for datasize resolution
                outer_obj_name = top_obj.name.strip('"')
                runtime_size = len(runtime_bytecode)
                
                # PASS 1: Estimate init size with zero outer entry
                # This makes datasize("OuterObj") return 0, which is wrong for arg parsing
                # but gives us a size estimate for the init code
                print(f"    Pass 1: Estimating init code size...")
                data_map_pass1 = data_map.copy()
                # Add outer object with just runtime size as placeholder
                data_map_pass1[outer_obj_name] = runtime_bytecode
                
                init_bytecode_pass1 = transpile_object(top_obj, data_map=data_map_pass1, 
                                                        vnm_output_path=None, 
                                                        immutables=immutables_map)
                init_size_estimate = len(init_bytecode_pass1)
                print(f"        Init size estimate: {init_size_estimate} bytes")
                
                # PASS 2: Re-transpile with correct outer object size (init + runtime)
                # datasize("OuterObj") should return init_size + runtime_size  
                # so that: codesize() - datasize("Outer") = constructor_args_size
                print(f"    Pass 2: Finalizing with correct datasize...")
                
                # CRITICAL FIX: Reorder sidecars to match Yul init code's CREATE order
                # The order of datasize() calls in Yul matches the Solidity constructor's CREATE order
                # We must embed sidecars in this order for dataoffset() to resolve correctly
                if sidecar_bytecodes:
                    yul_order = extract_sidecar_order_from_yul(yul_source)
                    if yul_order:
                        # Build a lookup for bytecode by sidecar name
                        sidecar_map = {name: bc for name, bc in sidecar_bytecodes}
                        # Reorder according to Yul order, keeping any not found at end
                        reordered = []
                        for name in yul_order:
                            if name in sidecar_map:
                                reordered.append((name, sidecar_map.pop(name)))
                        # Append any remaining sidecars (shouldn't happen, but be safe)
                        for name, bc in sidecar_map.items():
                            reordered.append((name, bc))
                        sidecar_bytecodes = reordered
                        print(f"        Sidecar order from Yul: {[n for n, _ in sidecar_bytecodes]}")
                
                # Calculate sidecar total size FIRST since we need it for datasize("OuterObj")
                sidecar_total_size = sum(len(bc) for _, bc in sidecar_bytecodes)
                
                # Total program size includes: init + runtime + all sidecars
                # This is what datasize("OuterObj") should return for constructor args calculation
                total_program_size = init_size_estimate + runtime_size + sidecar_total_size
                data_map_pass2 = data_map.copy()
                data_map_pass2[outer_obj_name] = bytes(total_program_size)  # Fake entry with correct size
                
                # CRITICAL FIX: Build offset_map for dataoffset() resolution
                # Bytecode layout: [init][runtime][sidecar_1][sidecar_2]...[constructor_args]
                # Runtime is at offset = init_size
                # Sidecars are at offset = init_size + runtime_size + cumulative_sidecar_sizes
                offset_map = {}
                
                # Runtime object starts at init code offset
                for obj_name in data_map.keys():
                    if "_deployed" in obj_name:
                        offset_map[obj_name] = init_size_estimate
                        print(f"        dataoffset({obj_name}) = {init_size_estimate} (runtime)")
                
                # Sidecar offsets: init_size + runtime_size + cumulative offsets
                sidecar_offset = init_size_estimate + runtime_size
                for sidecar_name, sidecar_bc in sidecar_bytecodes:
                    offset_map[sidecar_name] = sidecar_offset
                    print(f"        dataoffset({sidecar_name}) = {sidecar_offset} (sidecar, {len(sidecar_bc)} bytes)")
                    sidecar_offset += len(sidecar_bc)
                
                print(f"        DEBUG: offset_map before first pass = {list(offset_map.keys())}")
                
                final_bytecode = transpile_object(top_obj, data_map=data_map_pass2, 
                                                   vnm_output_path=init_ir_path, 
                                                   immutables=immutables_map,
                                                   offset_map=offset_map)
                
                # Convergence loop: iterate until init size stabilizes
                # Using literal offsets changes bytecode size, so we need to iterate
                max_iterations = 5
                for iteration in range(max_iterations):
                    if len(final_bytecode) == init_size_estimate:
                        break  # Converged
                    print(f"        Size changed ({init_size_estimate} -> {len(final_bytecode)}), re-converging...")
                    init_size_estimate = len(final_bytecode)
                    total_program_size = init_size_estimate + runtime_size + sidecar_total_size
                    data_map_pass2[outer_obj_name] = bytes(total_program_size)
                    # Update offset_map with new init size
                    # Runtime offset
                    for obj_name in list(offset_map.keys()):
                        if "_deployed" in obj_name:
                            offset_map[obj_name] = init_size_estimate
                    # Sidecar offsets: recalculate based on new init size
                    sidecar_offset = init_size_estimate + runtime_size
                    for sidecar_name, sidecar_bc in sidecar_bytecodes:
                        offset_map[sidecar_name] = sidecar_offset
                        sidecar_offset += len(sidecar_bc)
                    final_bytecode = transpile_object(top_obj, data_map=data_map_pass2,
                                                       vnm_output_path=init_ir_path,
                                                       immutables=immutables_map,
                                                       offset_map=offset_map)
                
                print(f"    ✓ Init code transpiled: {len(final_bytecode)} bytes")
            except Exception as e:
                import traceback
                traceback.print_exc()
                print(f"    ✗ Init transpilation failed: {e}", file=sys.stderr)
                print(f"    → Falling back to minimal init stub...", file=sys.stderr)
                final_bytecode = generate_init_stub(len(runtime_bytecode))
                print(f"    ✓ Init stub: {len(final_bytecode)} bytes")
        else:
            # LEGACY: Use minimal init stub (just codecopy + return)
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
        # Runtime-only mode: write runtime bytecode + sidecars
        # Must match full bytecode layout for dataoffset()/datasize() references
        if runtime_bytecode:
            output_bytecode = runtime_bytecode
            
            # Append sidecars to match deployed code layout
            # This is critical for CREATE/CREATE2 contracts using dataoffset()/datasize()
            # 
            # WARNING: With multiple sidecars, dataoffset() intrinsics computed as
            # (codesize - datasize) will only point to the LAST sidecar, not named ones.
            # This is a known limitation - runtime-only mode works correctly only when:
            # 1. There's a single sidecar, OR
            # 2. Runtime code doesn't use dataoffset() for sidecar deployment
            #
            # For contracts deploying multiple sidecars from runtime, use full init mode.
            if sidecar_bytecodes:
                if len(sidecar_bytecodes) > 1:
                    print(f"  [WARN] Runtime-only with {len(sidecar_bytecodes)} sidecars: dataoffset() may be incorrect", file=sys.stderr)
                for sidecar_name, sidecar_bc in sidecar_bytecodes:
                    output_bytecode += sidecar_bc
            
            with open(output_path, "wb") as f:
                f.write(output_bytecode)
            print()
            print("┌─────────────────────────────────────────────────────────")
            print("│ ✓ SUCCESS (Runtime Only)")
            print("├─────────────────────────────────────────────────────────")
            print(f"│ Target: {output_path}")
            print(f"│ Runtime: {len(runtime_bytecode)} bytes")
            if sidecar_bytecodes:
                print(f"│ Sidecars: {len(sidecar_bytecodes)} embedded ({sum(len(bc) for _, bc in sidecar_bytecodes)} bytes)")
            print(f"│ Total: {len(output_bytecode)} bytes")
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
            
            # NESTED SUB-OBJECTS: Append sidecar bytecodes after runtime
            # Layout: [init][runtime][sidecar_1][sidecar_2]...
            if sidecar_bytecodes:
                print(f"│ Sidecars: {len(sidecar_bytecodes)} embedded")
                for sidecar_name, sidecar_bc in sidecar_bytecodes:
                    final_bytecode += sidecar_bc
                    print(f"│   • {sidecar_name}: {len(sidecar_bc)} bytes")
        
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
    trans.add_argument("-O", "--optimize", choices=["none", "O0", "O2", "O3", "Os", "debug", "yul-o2", "native"], default=None,
                       help="Optimization level (overrides config). 'native' uses Vyper's O2 pipeline. 'O2' is the safe Yul pipeline. 'O0' minimal.")
    trans.add_argument("--yul-opt", action="store_true",
                       help="Enable Yul-level source optimization (standard level - strips validators, callvalue)")
    trans.add_argument("--yul-opt-level", choices=["safe", "standard", "aggressive", "maximum"],
                       help="Yul optimizer aggressiveness (overrides config.yul_optimizer.level)")
    trans.add_argument("--strip-checks", action="store_true",
                       help="Alias for --yul-opt-level=aggressive (strips runtime checks for gas savings)")
    trans.add_argument("--runtime-only", action="store_true", 
                       help="Output only runtime bytecode (no init code). Use for testing with CREATE.")
    trans.add_argument("--with-init", action="store_true",
                       help="Transpile actual Yul init code (constructor) instead of using minimal stub. Required for contracts with constructor logic.")
    trans.add_argument("--dump-ir", action="store_true", help="Dump Intermediate Representation (.vnm files)")
    trans.add_argument("--vnm-out", help="Explicit path for VNM output (overrides default naming)")
    trans.add_argument("--transpiler-config", help="Path to transpiler config file (default: yul2venom.config.yaml)")
    
    args = parser.parse_args()
    
    # Load transpiler config (file → defaults → CLI overrides)
    try:
        from config import load_config, set_config, apply_cli_overrides
        transpiler_config_path = getattr(args, 'transpiler_config', None)
        transpiler_config = load_config(transpiler_config_path)
        transpiler_config = apply_cli_overrides(transpiler_config, args)
        set_config(transpiler_config)  # Set as global config
    except ImportError:
        pass  # Config module not available, use defaults
    
    if args.command == "prepare":
        return cmd_prepare(args)
    elif args.command == "transpile":
        return cmd_transpile(args)
    else:
        parser.print_help()
        return 0


if __name__ == "__main__":
    sys.exit(main())
