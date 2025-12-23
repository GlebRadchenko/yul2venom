"""Custom exceptions for test validation."""
from typing import Optional


class ValidationError(Exception):
    """Base exception for all validation errors."""
    pass


class CompilationError(ValidationError):
    """Error during Solidity/Yul compilation."""
    pass


class TranspilationError(ValidationError):
    """Error during Yul to Venom transpilation."""
    pass


class ExecutionError(ValidationError):
    """Error during contract execution/validation."""
    pass


class ConfigurationError(ValidationError):
    """Error in test configuration."""
    pass


class SkipTest(ValidationError):
    """Test should be skipped (not an error)."""
    def __init__(self, reason: str, yul_size: Optional[int] = None):
        super().__init__(reason)
        self.reason = reason
        self.yul_size = yul_size
