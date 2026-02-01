"""
DEPRECATED: This module has been moved to generator/venom_generator.py

This file exists for backward compatibility only.
Import from generator instead:

    from generator import VenomIRBuilder, TranspilerContext
"""

import warnings
warnings.warn(
    "venom_generator has moved to generator/venom_generator.py. "
    "Import from 'generator' instead.",
    DeprecationWarning,
    stacklevel=2
)

# Re-export from new location
from generator.venom_generator import *
