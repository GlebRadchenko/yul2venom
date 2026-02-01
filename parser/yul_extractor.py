"""
Yul Extractor - Extract deployed contract code from solc --ir-optimized output.

The solc --ir-optimized output contains multiple contracts and headers like:
    Optimized IR:
    object "Contract_123" { ... }
    
This module extracts the target contract's `_deployed` object.
"""

import re
from pathlib import Path
from typing import Optional, Tuple


def extract_deployed_object(solc_output: str, contract_name: str) -> Tuple[Optional[str], Optional[str]]:
    """
    Extract the _deployed object for a specific contract from solc output.
    
    Args:
        solc_output: Raw output from solc --ir-optimized
        contract_name: Contract name (e.g., "QuotedTrader")
        
    Returns:
        Tuple of (deployed_yul, full_yul) or (None, None) if not found
    """
    # Pattern to match the target contract's object
    # Looking for: object "ContractName_XXX" { ... object "ContractName_XXX_deployed" { ... } }
    
    # First, find all object blocks
    object_pattern = rf'object\s+"[^"]*{re.escape(contract_name)}[^"]*_deployed"\s*\{{'
    
    deployed_match = re.search(object_pattern, solc_output)
    if not deployed_match:
        # Try without _deployed suffix (in case it's the main object)
        object_pattern = rf'object\s+"[^"]*{re.escape(contract_name)}[^"]*"\s*\{{'
        deployed_match = re.search(object_pattern, solc_output)
    
    if not deployed_match:
        return None, None
    
    # Find the start of the deployed object
    start = deployed_match.start()
    
    # Find matching closing brace
    brace_count = 0
    in_object = False
    end = start
    
    for i, char in enumerate(solc_output[start:], start):
        if char == '{':
            brace_count += 1
            in_object = True
        elif char == '}':
            brace_count -= 1
            if in_object and brace_count == 0:
                end = i + 1
                break
    
    deployed_yul = solc_output[start:end]
    
    # Also extract the full contract (including constructor)
    full_pattern = rf'object\s+"[^"]*{re.escape(contract_name)}[^"_]*"\s*\{{'
    full_match = re.search(full_pattern, solc_output)
    
    full_yul = None
    if full_match:
        start = full_match.start()
        brace_count = 0
        in_object = False
        
        for i, char in enumerate(solc_output[start:], start):
            if char == '{':
                brace_count += 1
                in_object = True
            elif char == '}':
                brace_count -= 1
                if in_object and brace_count == 0:
                    full_yul = solc_output[start:i+1]
                    break
    
    return deployed_yul, full_yul


def extract_from_file(yul_file: str, contract_name: str) -> Tuple[Optional[str], Optional[str]]:
    """Extract deployed object from a Yul file."""
    with open(yul_file, 'r') as f:
        content = f.read()
    return extract_deployed_object(content, contract_name)


def clean_yul_output(raw_output: str) -> str:
    """Remove solc headers and keep only Yul code."""
    # Remove "Optimized IR:" headers
    cleaned = re.sub(r'^Optimized IR:\s*\n?', '', raw_output, flags=re.MULTILINE)
    # Remove empty lines at start
    cleaned = cleaned.lstrip('\n')
    return cleaned


if __name__ == "__main__":
    import sys
    if len(sys.argv) < 3:
        print("Usage: python yul_extractor.py <yul_file> <contract_name>")
        sys.exit(1)
    
    deployed, full = extract_from_file(sys.argv[1], sys.argv[2])
    if deployed:
        print(deployed)
    else:
        print("No deployed object found", file=sys.stderr)
        sys.exit(1)
