"""
Yul2Venom - Production-grade Yul to Venom IR transpiler.

This package provides tools for transpiling Solidity/Yul code to Vyper's
Venom IR and generating optimized EVM bytecode.

Package Structure:
    yul2venom/
    ├── core/           # Pipeline, config, errors
    ├── parser/         # Yul parsing and extraction
    ├── optimizer/      # Yul source optimizations
    ├── generator/      # AST to Venom IR conversion
    ├── backend/        # Venom backend invocation
    └── utils/          # Constants and utilities

Quick Start:
    from yul2venom import transpile
    
    bytecode = transpile('''
        object "Contract" { code { } }
    ''')

For more control:
    from yul2venom import TranspilationConfig, TranspilationPipeline
    
    config = TranspilationConfig(yul_path="contract.yul", runtime_only=True)
    result = TranspilationPipeline(config).run()
"""

__version__ = "0.2.0"
__author__ = "Yul2Venom Contributors"

# Core API
from .core import (
    TranspilationConfig,
    TranspilationResult,
    TranspilationPipeline,
    YulOptLevel,
    transpile,
)

# Error types
from .core import (
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

# Key constants
from .utils import (
    VENOM_MEMORY_START,
    YUL_FMP_SLOT,
    VOID_OPS,
    COPY_OPS,
    CALL_OPS,
)

__all__ = [
    # Version
    "__version__",
    
    # Core API
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
    
    # Constants
    "VENOM_MEMORY_START",
    "YUL_FMP_SLOT",
    "VOID_OPS",
    "COPY_OPS",
    "CALL_OPS",
]
