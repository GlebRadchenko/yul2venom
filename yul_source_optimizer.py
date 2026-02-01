"""
DEPRECATED: This module has been moved to optimizer/yul_source_optimizer.py

This file exists for backward compatibility only.
Import from optimizer instead:

    from optimizer import YulSourceOptimizer, OptimizationLevel
"""

import warnings
warnings.warn(
    "yul_source_optimizer has moved to optimizer/yul_source_optimizer.py. "
    "Import from 'optimizer' instead.",
    DeprecationWarning,
    stacklevel=2
)

# Re-export from new location
from optimizer.yul_source_optimizer import *
