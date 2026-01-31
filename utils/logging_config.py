"""
Yul2Venom Logging Configuration

Unified logging setup with verbose/quiet modes.
"""

import logging
import sys
from typing import Optional

# Module-level logger cache
_loggers: dict[str, logging.Logger] = {}


def setup_logging(
    verbose: bool = False,
    quiet: bool = False,
    log_file: Optional[str] = None
) -> None:
    """
    Configure root logger for Yul2Venom.
    
    Args:
        verbose: Enable DEBUG level output
        quiet: Suppress all output except errors
        log_file: Optional file path for log output
    """
    if quiet:
        level = logging.ERROR
    elif verbose:
        level = logging.DEBUG
    else:
        level = logging.INFO
    
    # Format: [LEVEL] message (no timestamps for CLI tool)
    formatter = logging.Formatter("[%(levelname)s] %(message)s")
    
    # Console handler
    console_handler = logging.StreamHandler(sys.stderr)
    console_handler.setFormatter(formatter)
    console_handler.setLevel(level)
    
    # Configure root logger
    root = logging.getLogger("yul2venom")
    root.setLevel(level)
    root.handlers.clear()
    root.addHandler(console_handler)
    
    # Optional file handler
    if log_file:
        file_handler = logging.FileHandler(log_file)
        file_handler.setFormatter(
            logging.Formatter("%(asctime)s [%(levelname)s] %(name)s: %(message)s")
        )
        file_handler.setLevel(logging.DEBUG)
        root.addHandler(file_handler)


def get_logger(name: str) -> logging.Logger:
    """
    Get a named logger under the yul2venom namespace.
    
    Args:
        name: Logger name (e.g., "generator", "optimizer")
        
    Returns:
        Configured logger instance
    """
    full_name = f"yul2venom.{name}"
    if full_name not in _loggers:
        _loggers[full_name] = logging.getLogger(full_name)
    return _loggers[full_name]
