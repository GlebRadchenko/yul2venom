"""
Yul2Venom Constants

Centralized memory layout, EVM opcodes, and configuration constants.
All magic numbers in the transpiler should be defined here.
"""

# =============================================================================
# Memory Layout Constants
# =============================================================================

# Venom backend reserves memory for stack spills. Tested 2026-02-01: 0x100 is stable.
# 0x100 uses PUSH1 (2 bytes vs 3 bytes for PUSH2), saving ~1 byte per mstore address.
# This is safely above Vyper's scratch space (0x00-0x60) and Solidity's FMP (0x40).
VENOM_MEMORY_START = 0x100

# Safe offset for stack spill operations - beyond Yul heap start
SPILL_OFFSET = 0x4000

# Solidity/Yul free memory pointer slot
YUL_FMP_SLOT = 0x40
YUL_FMP_SLOT_DEC = 64  # Decimal representation (for string matching in Yul source)

# Solidity/Yul heap start (after scratch space and FMP)
YUL_HEAP_START = 0x80
YUL_HEAP_START_DEC = 128  # Decimal representation

# =============================================================================
# Panic Error Codes (Solidity Specification)
# =============================================================================

PANIC_GENERIC = 0x00
PANIC_ASSERT = 0x01
PANIC_ARITHMETIC_OVERFLOW = 0x11
PANIC_DIVISION_BY_ZERO = 0x12
PANIC_ENUM_ERROR = 0x21
PANIC_INVALID_STORAGE_ARRAY = 0x22
PANIC_POP_EMPTY = 0x31
PANIC_ARRAY_BOUNDS = 0x32
PANIC_MEMORY_OVERFLOW = 0x41
PANIC_ZERO_INTERNAL_FUNCTION = 0x51

PANIC_CODES = {
    PANIC_GENERIC: "Generic panic",
    PANIC_ASSERT: "Assert failure",
    PANIC_ARITHMETIC_OVERFLOW: "Arithmetic overflow/underflow",
    PANIC_DIVISION_BY_ZERO: "Division or modulo by zero",
    PANIC_ENUM_ERROR: "Invalid enum value",
    PANIC_INVALID_STORAGE_ARRAY: "Invalid storage array encoding",
    PANIC_POP_EMPTY: "Pop on empty array",
    PANIC_ARRAY_BOUNDS: "Array out of bounds",
    PANIC_MEMORY_OVERFLOW: "Memory overflow",
    PANIC_ZERO_INTERNAL_FUNCTION: "Call to zero-initialized function pointer",
}

# =============================================================================
# RLP Encoding Constants (Ethereum Specification)
# =============================================================================

RLP_SHORT_STRING = 0x80   # Single byte strings 0x00-0x7f are encoded as themselves
RLP_LONG_STRING = 0xB7    # String length > 55 bytes
RLP_SHORT_LIST = 0xC0     # List with total length < 56 bytes
RLP_LONG_LIST = 0xF7      # List length > 55 bytes

# =============================================================================
# EVM Opcode Constants (for init bytecode generation)
# =============================================================================

# Stack Operations
OP_STOP = 0x00
OP_POP = 0x50
OP_PUSH0 = 0x5F
OP_PUSH1 = 0x60
OP_PUSH2 = 0x61

# Duplicates
OP_DUP1 = 0x80
OP_DUP2 = 0x81

# Memory Operations
OP_MLOAD = 0x51
OP_MSTORE = 0x52
OP_CODECOPY = 0x39

# Control Flow
OP_JUMP = 0x56
OP_JUMPI = 0x57
OP_JUMPDEST = 0x5B

# Return/Revert
OP_RETURN = 0xF3
OP_REVERT = 0xFD
OP_INVALID = 0xFE

# =============================================================================
# Opcode Categories (for intrinsic handling in venom_generator)
# =============================================================================

# Void operations (no return value)
VOID_OPS = frozenset({
    "pop", "log0", "log1", "log2", "log3", "log4", 
    "stop", "selfdestruct", "return", "revert"
})

# Copy operations (affect memory, no return value)
COPY_OPS = frozenset({
    "codecopy", "calldatacopy", "returndatacopy", 
    "mcopy", "extcodecopy"
})

# Non-commutative binary operations (order matters)
NON_COMMUTATIVE_OPS = frozenset({
    "sub", "div", "sdiv", "mod", "smod", "exp",
    "lt", "gt", "slt", "sgt", "shl", "shr", "sar"
})

# Simple unary/binary operations (commutative or single-operand)
SIMPLE_OPS = frozenset({
    "add", "mul", "not", "eq", "iszero", 
    "and", "or", "xor", "addmod", "mulmod", "signextend"
})

# Memory/Storage operations
MEMORY_OPS = frozenset({
    "mload", "sload", "tload", "calldataload"
})

# Environment operations (0-arg, return value)
ENV_OPS = frozenset({
    "callvalue", "calldatasize", "codesize", "returndatasize",
    "gas", "address", "caller", "origin", "gasprice",
    "chainid", "basefee", "timestamp", "number", 
    "difficulty", "gaslimit", "coinbase", "selfbalance"
})

# Call-like operations (volatile, return success flag)
CALL_OPS = frozenset({
    "call", "staticcall", "delegatecall", "create", "create2"
})

# =============================================================================
# CLI Defaults
# =============================================================================

DEFAULT_CONFIG_DIR = "configs"
DEFAULT_OUTPUT_DIR = "output"
DEFAULT_SOL_DIR = "foundry/src"

# =============================================================================
# Selector Constants
# =============================================================================

SELECTOR_SIZE = 4  # Function selector is 4 bytes
SELECTOR_SHIFT = 224  # shr(224, calldataload(0)) extracts selector

# =============================================================================
# Path Utilities
# =============================================================================

from pathlib import Path

# Project root directory (parent of utils/)
PROJECT_ROOT = Path(__file__).parent.parent


def sanitize_paths(text: str) -> str:
    """Convert absolute paths to relative paths for safe output.
    
    This prevents machine-specific absolute paths from being
    written to JSON/markdown files that may be committed to git.
    """
    if not text:
        return text
    # Replace PROJECT_ROOT absolute paths with relative
    project_root_str = str(PROJECT_ROOT)
    if project_root_str in text:
        text = text.replace(project_root_str + "/", "")
        text = text.replace(project_root_str, ".")
    return text
