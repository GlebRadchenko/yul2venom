"""
Yul2Venom Constants

Centralized memory layout and configuration constants.
"""

# =============================================================================
# Memory Layout Constants
# =============================================================================

# Venom backend reserves 0x80-0x1000 for stack spills (Frame).
# We MUST start Yul heap at 0x1000 to avoid corruption.
VENOM_MEMORY_START = 0x1000

# Safe offset for stack spill operations - beyond Yul heap start
SPILL_OFFSET = 0x4000

# Solidity/Yul free memory pointer slot
YUL_FMP_SLOT = 0x40

# Solidity/Yul heap start (after scratch space and FMP)
YUL_HEAP_START = 0x80

# =============================================================================
# Panic Error Codes
# =============================================================================

PANIC_MEMORY_OVERFLOW = 0x41
PANIC_ARRAY_BOUNDS = 0x32
PANIC_ARITHMETIC_OVERFLOW = 0x11
PANIC_DIVISION_BY_ZERO = 0x12
PANIC_ENUM_ERROR = 0x21

PANIC_CODES = {
    PANIC_MEMORY_OVERFLOW: "Memory overflow",
    PANIC_ARRAY_BOUNDS: "Array out of bounds",
    PANIC_ARITHMETIC_OVERFLOW: "Arithmetic overflow/underflow",
    PANIC_DIVISION_BY_ZERO: "Division or modulo by zero",
    PANIC_ENUM_ERROR: "Invalid enum value",
}

# =============================================================================
# CLI Defaults
# =============================================================================

DEFAULT_CONFIG_DIR = "configs"
DEFAULT_OUTPUT_DIR = "output"
DEFAULT_SOL_DIR = "foundry/src"
