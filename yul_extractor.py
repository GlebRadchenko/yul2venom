"""
DEPRECATED: This module has been moved to parser/yul_extractor.py

This file exists for backward compatibility only.
Import from parser.yul_extractor instead:

    from parser import extract_yul_from_forge
"""

import warnings
warnings.warn(
    "yul_extractor has moved to parser/yul_extractor.py. "
    "Import from 'parser' instead.",
    DeprecationWarning,
    stacklevel=2
)

# Re-export from new location
from parser.yul_extractor import *
