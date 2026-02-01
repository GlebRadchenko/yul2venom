"""
Backend module for Yul2Venom transpiler.

Provides Venom backend invocation and bytecode utilities.
"""

from .run_venom import load_immutables, main

__all__ = [
    "load_immutables",
    "main",
]
