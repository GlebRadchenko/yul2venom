"""
DEPRECATED: This module has been moved to parser/yul_parser.py

This file exists for backward compatibility only.
Import from parser.yul_parser instead:

    from parser import YulParser
"""

import warnings
warnings.warn(
    "yul_parser has moved to parser/yul_parser.py. "
    "Import from 'parser' instead: from parser import YulParser",
    DeprecationWarning,
    stacklevel=2
)

# Re-export from new location
from parser.yul_parser import *
