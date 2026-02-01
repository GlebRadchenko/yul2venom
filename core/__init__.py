"""
Core module for Yul2Venom transpiler.

Provides the main transpilation pipeline, configuration, and error handling.
"""

from .pipeline import (
    TranspilationConfig,
    TranspilationResult,
    TranspilationPipeline,
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
    # Pipeline
    "TranspilationConfig",
    "TranspilationResult",
    "TranspilationPipeline",
    "YulOptLevel",
    "transpile",
    
    # Errors
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
