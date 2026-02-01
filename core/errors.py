"""
Custom exceptions for the Yul2Venom transpiler.

Provides a hierarchy of well-typed exceptions for better error handling
and debugging throughout the transpilation pipeline.
"""


class Yul2VenomError(Exception):
    """Base exception for all Yul2Venom errors."""
    pass


class ConfigurationError(Yul2VenomError):
    """Raised when configuration is invalid or incomplete."""
    pass


class ParseError(Yul2VenomError):
    """Raised when Yul source code cannot be parsed."""
    
    def __init__(self, message: str, line: int = None, column: int = None):
        super().__init__(message)
        self.line = line
        self.column = column
    
    def __str__(self):
        if self.line and self.column:
            return f"Parse error at line {self.line}, column {self.column}: {self.args[0]}"
        elif self.line:
            return f"Parse error at line {self.line}: {self.args[0]}"
        return f"Parse error: {self.args[0]}"


class OptimizationError(Yul2VenomError):
    """Raised when Yul source optimization fails."""
    
    def __init__(self, message: str, rule_name: str = None):
        super().__init__(message)
        self.rule_name = rule_name


class TranspilationError(Yul2VenomError):
    """Raised when AST to Venom IR conversion fails."""
    
    def __init__(self, message: str, node_type: str = None, function_name: str = None):
        super().__init__(message)
        self.node_type = node_type
        self.function_name = function_name
    
    def __str__(self):
        details = []
        if self.node_type:
            details.append(f"node_type={self.node_type}")
        if self.function_name:
            details.append(f"function={self.function_name}")
        
        if details:
            return f"Transpilation error ({', '.join(details)}): {self.args[0]}"
        return f"Transpilation error: {self.args[0]}"


class BackendError(Yul2VenomError):
    """Raised when Venom backend compilation fails."""
    
    def __init__(self, message: str, stage: str = None):
        super().__init__(message)
        self.stage = stage  # e.g., "optimization", "codegen", "assembly"


class UnsupportedFeatureError(Yul2VenomError):
    """Raised when an unsupported Yul feature is encountered."""
    
    def __init__(self, feature: str, suggestion: str = None):
        super().__init__(f"Unsupported feature: {feature}")
        self.feature = feature
        self.suggestion = suggestion
    
    def __str__(self):
        msg = f"Unsupported feature: {self.feature}"
        if self.suggestion:
            msg += f". {self.suggestion}"
        return msg


class ImmutableError(Yul2VenomError):
    """Raised when immutable handling fails."""
    
    def __init__(self, key: str, available_keys: list = None):
        super().__init__(f"Immutable not found: {key}")
        self.key = key
        self.available_keys = available_keys or []


class StackError(Yul2VenomError):
    """Raised when stack manipulation issues are detected."""
    
    def __init__(self, message: str, expected: int = None, actual: int = None):
        super().__init__(message)
        self.expected = expected
        self.actual = actual
