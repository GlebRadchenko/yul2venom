"""
DEPRECATED: This module has been moved to backend/run_venom.py

This file exists for backward compatibility only.
Import from backend instead:

    from backend import run_venom_backend
"""

import warnings
warnings.warn(
    "run_venom has moved to backend/run_venom.py. "
    "Import from 'backend' instead.",
    DeprecationWarning,
    stacklevel=2
)

# Re-export from new location
from backend.run_venom import *
