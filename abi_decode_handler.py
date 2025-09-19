"""
General ABI decode handler for Yul-to-Venom compiler.
This module provides a general solution for optimizing ABI decode patterns.
"""

import re
from typing import Optional, List, Tuple


def parse_abi_decode_pattern(function_name: str) -> Optional[Tuple[List[str], bool]]:
    """
    Parse ABI decode function name to extract parameter types.

    Returns:
        - Tuple of (type_list, is_memory) if it's an ABI decode function
        - None if not an ABI decode pattern

    Examples:
        abi_decode_tuple_t_uint256t_uint256 -> (['uint256', 'uint256'], False)
        abi_decode_tuple_t_addresst_uint256 -> (['address', 'uint256'], False)
        abi_decode_tuple_t_uint256_fromMemory -> (['uint256'], True)
    """
    # Check if it's an ABI decode pattern
    if not function_name.startswith("abi_decode_tuple_t_"):
        return None

    # Check if it's a memory variant
    is_memory = function_name.endswith("_fromMemory")

    # Extract the types part
    if is_memory:
        # Remove prefix and suffix
        types_part = function_name[len("abi_decode_tuple_t_"):-len("_fromMemory")]
    else:
        # Remove prefix
        types_part = function_name[len("abi_decode_tuple_t_"):]

    if not types_part:
        return None

    # Parse the types - they're concatenated with 't_' between them
    # Examples:
    # uint256t_uint256 -> ['uint256', 'uint256']
    # addresst_uint256 -> ['address', 'uint256']
    # uint8t_uint16t_uint32 -> ['uint8', 'uint16', 'uint32']

    # Split by 't_' to get individual types
    # But be careful with complex types like array$_t_uint256_$dyn_memory_ptr

    # Simple approach for common types
    types = []
    current = types_part

    # Common EVM types that might appear
    known_types = [
        'uint256', 'uint128', 'uint64', 'uint32', 'uint16', 'uint8',
        'int256', 'int128', 'int64', 'int32', 'int16', 'int8',
        'address', 'bool', 'bytes32', 'bytes16', 'bytes8', 'bytes4',
        'bytes', 'string'
    ]

    while current:
        found = False
        for known_type in known_types:
            if current.startswith(known_type):
                types.append(known_type)
                current = current[len(known_type):]
                # Skip 't_' separator if present
                if current.startswith('t_'):
                    current = current[2:]
                found = True
                break

        if not found:
            # Check for complex types like array
            if current.startswith('array'):
                # Find the end of the array type
                # For now, skip complex array types
                return None
            else:
                # Unknown type pattern
                return None

    if not types:
        return None

    return (types, is_memory)


def should_optimize_abi_decode(function_name: str, num_params: int) -> bool:
    """
    Determine if an ABI decode function should be optimized.

    We optimize simple cases where the overhead of function call
    is significant compared to the actual work.
    """
    parse_result = parse_abi_decode_pattern(function_name)
    if not parse_result:
        return False

    types, is_memory = parse_result

    # Check if number of parameters matches
    if len(types) != num_params:
        return False

    # Only optimize simple scalar types
    simple_types = {
        'uint256', 'uint128', 'uint64', 'uint32', 'uint16', 'uint8',
        'int256', 'int128', 'int64', 'int32', 'int16', 'int8',
        'address', 'bool', 'bytes32', 'bytes16', 'bytes8', 'bytes4'
    }

    # Check if all types are simple
    for t in types:
        if t not in simple_types:
            return False

    # Optimize if we have 1-4 simple parameters
    # (More than 4 params, the function call overhead is less significant)
    return 1 <= len(types) <= 4


def get_load_instruction_for_type(type_name: str, is_memory: bool) -> str:
    """
    Get the appropriate load instruction for a given type.

    Returns:
        The opcode to use for loading this type
    """
    if is_memory:
        return "mload"
    else:
        return "calldataload"


def get_type_mask(type_name: str) -> Optional[int]:
    """
    Get the bit mask for a given type.

    Returns:
        The mask to apply after loading, or None if no mask needed
    """
    masks = {
        'uint8': 0xFF,
        'uint16': 0xFFFF,
        'uint32': 0xFFFFFFFF,
        'uint64': 0xFFFFFFFFFFFFFFFF,
        'uint128': 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
        'int8': None,  # Sign extension needed instead
        'int16': None,
        'int32': None,
        'int64': None,
        'int128': None,
        'address': 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
        'bool': None,  # Special case: iszero(iszero(...))
        'bytes4': 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000,
        'bytes8': 0xFFFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000,
        'bytes16': 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000,
        'bytes32': None,  # No mask needed
        'uint256': None,  # No mask needed
        'int256': None,  # No mask needed
    }

    return masks.get(type_name)


def needs_special_handling(type_name: str) -> str:
    """
    Check if a type needs special handling after loading.

    Returns:
        'bool' for bool type (needs iszero(iszero(...)))
        'signext' for signed integers needing sign extension
        'none' for no special handling
    """
    if type_name == 'bool':
        return 'bool'
    elif type_name in ['int8', 'int16', 'int32', 'int64', 'int128']:
        return 'signext'
    else:
        return 'none'