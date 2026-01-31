"""
Yul2Venom IR Package

Standalone Venom-compatible IR types for transpiler output.

These classes mirror vyper.venom types but can be used independently
for generating and serializing Venom IR without the full Vyper dependency.

Classes:
    IRContext: Top-level container for functions and data
    IRFunction: A function with basic blocks
    IRBasicBlock: A basic block with instructions
    IRInstruction: A single IR instruction
    IROperand, IRVariable, IRLiteral, IRLabel: Operand types
"""

from .basicblock import (
    IROperand,
    IRLiteral,
    IRVariable,
    IRLabel,
    IRInstruction,
    IRBasicBlock,
    BB_TERMINATORS,
    NO_OUTPUT_INSTRUCTIONS,
)
from .function import IRFunction
from .context import IRContext, DataItem, DataSection

__all__ = [
    # Core types
    "IRContext",
    "IRFunction",
    "IRBasicBlock",
    "IRInstruction",
    # Operand types
    "IROperand",
    "IRLiteral",
    "IRVariable",
    "IRLabel",
    # Data types
    "DataItem",
    "DataSection",
    # Constants
    "BB_TERMINATORS",
    "NO_OUTPUT_INSTRUCTIONS",
]
