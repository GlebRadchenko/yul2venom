"""
Utils package for Yul2Venom.

Provides shared utilities, constants, and helper functions
used throughout the transpiler.
"""

from .constants import (
    # Memory layout
    VENOM_MEMORY_START,
    SPILL_OFFSET,
    YUL_FMP_SLOT,
    YUL_HEAP_START,
    
    # Panic codes
    PANIC_CODES,
    PANIC_ARITHMETIC_OVERFLOW,
    PANIC_DIVISION_BY_ZERO,
    PANIC_ARRAY_BOUNDS,
    PANIC_MEMORY_OVERFLOW,
    
    # RLP
    RLP_SHORT_STRING,
    RLP_SHORT_LIST,
    
    # Opcodes
    OP_PUSH0,
    OP_PUSH1,
    OP_PUSH2,
    OP_CODECOPY,
    OP_RETURN,
    
    # Opcode categories
    VOID_OPS,
    COPY_OPS,
    NON_COMMUTATIVE_OPS,
    SIMPLE_OPS,
    MEMORY_OPS,
    ENV_OPS,
    CALL_OPS,
    
    # Paths
    PROJECT_ROOT,
    sanitize_paths,
)
from .env import env_bool, env_bool_opt, env_int_opt, env_str

__all__ = [
    # Memory
    "VENOM_MEMORY_START",
    "SPILL_OFFSET", 
    "YUL_FMP_SLOT",
    "YUL_HEAP_START",
    
    # Panic
    "PANIC_CODES",
    
    # Opcode categories
    "VOID_OPS",
    "COPY_OPS",
    "NON_COMMUTATIVE_OPS",
    "SIMPLE_OPS",
    "MEMORY_OPS",
    "ENV_OPS",
    "CALL_OPS",
    
    # Paths
    "PROJECT_ROOT",
    "sanitize_paths",
    "env_str",
    "env_bool",
    "env_bool_opt",
    "env_int_opt",
]
