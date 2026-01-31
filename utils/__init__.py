"""
Yul2Venom Utilities Package

Shared constants, logging configuration, and helper functions.
"""

from .constants import (
    SPILL_OFFSET,
    YUL_HEAP_START,
    YUL_FMP_SLOT,
    VENOM_MEMORY_START,
)
from .logging_config import setup_logging, get_logger

__all__ = [
    "SPILL_OFFSET",
    "YUL_HEAP_START", 
    "YUL_FMP_SLOT",
    "VENOM_MEMORY_START",
    "setup_logging",
    "get_logger",
]
