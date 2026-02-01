"""
Optimizer module for Yul2Venom transpiler.

Provides Yul source-level optimization passes.
"""

from .yul_source_optimizer import (
    YulSourceOptimizer,
    OptimizationLevel,
    OptimizationRule,
    OptimizationStats,
)

__all__ = [
    "YulSourceOptimizer",
    "OptimizationLevel",
    "OptimizationRule",
    "OptimizationStats",
]
