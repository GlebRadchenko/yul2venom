"""
Core module for Yul2Venom transpiler.
Re-exports pipeline and error types for programmatic use.
"""

from .pipeline import (
    TranspilationConfig,
    TranspilationPipeline,
    TranspilationResult,
    YulOptLevel,
    transpile,
)
from .errors import (
    Yul2VenomError,
    ConfigurationError,
    ParseError,
    OptimizationError,
    TranspilationError,
    BackendError,
    UnsupportedFeatureError,
    ImmutableError,
    StackError,
)

__all__ = [
    "TranspilationConfig",
    "TranspilationPipeline",
    "TranspilationResult",
    "YulOptLevel",
    "transpile",
    "Yul2VenomError",
    "ConfigurationError",
    "ParseError",
    "OptimizationError",
    "TranspilationError",
    "BackendError",
    "UnsupportedFeatureError",
    "ImmutableError",
    "StackError",
]
