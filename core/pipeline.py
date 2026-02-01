"""
Unified transpilation pipeline for Yul to Venom IR and EVM bytecode.

This module provides a clean, configurable API for the transpilation process:
- TranspilationConfig: Configuration dataclass for all pipeline options
- TranspilationResult: Output dataclass with bytecode and metadata
- TranspilationPipeline: Main orchestrator for the transpilation process

Example usage:
    from pipeline import TranspilationPipeline, TranspilationConfig
    
    config = TranspilationConfig(
        yul_source="object \"Contract\" { ... }",
        runtime_only=True,
        yul_opt_level="aggressive"
    )
    
    pipeline = TranspilationPipeline(config)
    result = pipeline.run()
    print(f"Bytecode: {result.bytecode}")
"""

from dataclasses import dataclass, field
from typing import Optional, Dict, Any, List
from pathlib import Path
from enum import Enum
import json


class YulOptLevel(Enum):
    """Yul source optimization levels."""
    NONE = "none"
    SAFE = "safe"
    STANDARD = "standard"
    AGGRESSIVE = "aggressive"
    MAXIMUM = "maximum"


@dataclass
class TranspilationConfig:
    """Configuration for the transpilation pipeline.
    
    Attributes:
        yul_source: Raw Yul source code (mutually exclusive with yul_path)
        yul_path: Path to Yul file (mutually exclusive with yul_source)
        runtime_only: If True, only transpile runtime code (skip init code)
        yul_opt_level: Yul source optimization level
        immutables: Dictionary of immutable values to inject
        deployer_address: Address of the deployer (for CREATE address prediction)
        deployer_nonce: Nonce of the deployer (for CREATE address prediction)
        output_dir: Directory for output files
        debug: Enable debug output
    """
    yul_source: Optional[str] = None
    yul_path: Optional[Path] = None
    runtime_only: bool = False
    yul_opt_level: YulOptLevel = YulOptLevel.AGGRESSIVE
    immutables: Dict[str, Any] = field(default_factory=dict)
    deployer_address: Optional[str] = None
    deployer_nonce: int = 0
    output_dir: Path = Path("output")
    debug: bool = False
    
    def __post_init__(self):
        if self.yul_source is None and self.yul_path is None:
            raise ValueError("Either yul_source or yul_path must be provided")
        if self.yul_source is not None and self.yul_path is not None:
            raise ValueError("Cannot specify both yul_source and yul_path")
        
        # Convert string paths to Path objects
        if isinstance(self.yul_path, str):
            self.yul_path = Path(self.yul_path)
        if isinstance(self.output_dir, str):
            self.output_dir = Path(self.output_dir)
        
        # Convert string opt level to enum
        if isinstance(self.yul_opt_level, str):
            self.yul_opt_level = YulOptLevel(self.yul_opt_level)
    
    @classmethod
    def from_json(cls, json_path: Path) -> "TranspilationConfig":
        """Load configuration from a JSON file."""
        with open(json_path) as f:
            data = json.load(f)
        
        return cls(
            yul_path=Path(data.get("yul_path")) if data.get("yul_path") else None,
            runtime_only=data.get("runtime_only", False),
            yul_opt_level=YulOptLevel(data.get("yul_opt_level", "aggressive")),
            immutables=data.get("immutables", {}),
            deployer_address=data.get("deployer_address"),
            deployer_nonce=data.get("deployer_nonce", 0),
            output_dir=Path(data.get("output_dir", "output")),
            debug=data.get("debug", False)
        )
    
    def get_yul_source(self) -> str:
        """Get the Yul source code, loading from file if necessary."""
        if self.yul_source:
            return self.yul_source
        if self.yul_path:
            return self.yul_path.read_text()
        raise ValueError("No Yul source available")


@dataclass
class TranspilationResult:
    """Result of the transpilation process.
    
    Attributes:
        bytecode: The final EVM bytecode (hex string with 0x prefix)
        runtime_bytecode: The runtime bytecode (if init code was generated)
        venom_ir: The Venom IR text representation
        optimized_yul: The optimized Yul source
        contract_address: Predicted contract address (if deployer info provided)
        bytecode_size: Size of bytecode in bytes
        stats: Dictionary of transpilation statistics
    """
    bytecode: str
    runtime_bytecode: Optional[str] = None
    venom_ir: Optional[str] = None
    optimized_yul: Optional[str] = None
    contract_address: Optional[str] = None
    bytecode_size: int = 0
    stats: Dict[str, Any] = field(default_factory=dict)
    
    def __post_init__(self):
        if self.bytecode.startswith("0x"):
            self.bytecode_size = (len(self.bytecode) - 2) // 2
        else:
            self.bytecode_size = len(self.bytecode) // 2


class TranspilationPipeline:
    """Main orchestrator for the Yul to EVM bytecode transpilation.
    
    The pipeline executes the following stages:
    1. Parse Yul source into AST
    2. Apply Yul source optimizations  
    3. Convert AST to Venom IR
    4. Run Venom backend (optimization + codegen)
    5. Generate init code (if not runtime_only)
    6. Return final bytecode
    """
    
    def __init__(self, config: TranspilationConfig):
        self.config = config
        self._yul_parser = None
        self._yul_optimizer = None
        self._venom_generator = None
        
    def run(self) -> TranspilationResult:
        """Execute the full transpilation pipeline.
        
        Returns:
            TranspilationResult with bytecode and metadata
        """
        # Lazy imports to avoid circular dependencies
        # Use try/except to support both new package paths and backward compatibility
        try:
            from parser.yul_parser import YulParser
            from optimizer.yul_source_optimizer import YulSourceOptimizer, OptimizationLevel
            from generator.venom_generator import VenomIRBuilder, TranspilerContext
            from backend.run_venom import run_venom_backend
        except ImportError:
            # Fallback to root-level imports for backward compatibility
            from yul_parser import YulParser
            from yul_source_optimizer import YulSourceOptimizer, OptimizationLevel
            from venom_generator import VenomIRBuilder, TranspilerContext
            from run_venom import run_venom_backend
        
        # Stage 1: Load and parse Yul
        yul_source = self.config.get_yul_source()
        
        # Stage 2: Optimize Yul source
        opt_level_map = {
            YulOptLevel.NONE: OptimizationLevel.SAFE,  # Minimal
            YulOptLevel.SAFE: OptimizationLevel.SAFE,
            YulOptLevel.STANDARD: OptimizationLevel.STANDARD,
            YulOptLevel.AGGRESSIVE: OptimizationLevel.AGGRESSIVE,
            YulOptLevel.MAXIMUM: OptimizationLevel.MAXIMUM,
        }
        
        optimizer = YulSourceOptimizer(opt_level_map.get(self.config.yul_opt_level, OptimizationLevel.AGGRESSIVE))
        optimized_yul, stats = optimizer.optimize(yul_source)
        
        # Stage 3: Parse to AST
        parser = YulParser()
        ast = parser.parse(optimized_yul)
        
        # Stage 4: Generate Venom IR
        ctx = TranspilerContext(immutables=self.config.immutables)
        builder = VenomIRBuilder(ctx)
        
        # Handle object structure
        if hasattr(ast, 'object') and ast.object:
            venom_ir = builder.transpile_object(ast.object)
        else:
            venom_ir = builder.transpile(ast)
        
        venom_ir_text = str(venom_ir) if venom_ir else ""
        
        # Stage 5: Run Venom backend
        bytecode = run_venom_backend(venom_ir)
        
        # Stage 6: Calculate address if deployer info provided
        contract_address = None
        if self.config.deployer_address:
            from yul2venom import compute_create_address
            contract_address = compute_create_address(
                self.config.deployer_address,
                self.config.deployer_nonce
            )
        
        return TranspilationResult(
            bytecode=bytecode,
            runtime_bytecode=bytecode if self.config.runtime_only else None,
            venom_ir=venom_ir_text if self.config.debug else None,
            optimized_yul=optimized_yul if self.config.debug else None,
            contract_address=contract_address,
            stats={
                "yul_optimization_stats": stats.__dict__ if hasattr(stats, '__dict__') else {},
                "runtime_only": self.config.runtime_only,
            }
        )
    
    def validate_config(self) -> List[str]:
        """Validate the configuration and return any warnings.
        
        Returns:
            List of warning messages (empty if all OK)
        """
        warnings = []
        
        if self.config.yul_path and not self.config.yul_path.exists():
            warnings.append(f"Yul file not found: {self.config.yul_path}")
        
        if self.config.yul_opt_level == YulOptLevel.MAXIMUM:
            warnings.append("MAXIMUM optimization removes safety checks - use with caution")
        
        return warnings


# Convenience function for simple use cases
def transpile(
    yul_source: str,
    *,
    runtime_only: bool = False,
    yul_opt_level: str = "aggressive",
    immutables: Optional[Dict[str, Any]] = None,
    debug: bool = False
) -> str:
    """Convenience function to transpile Yul source to EVM bytecode.
    
    Args:
        yul_source: Raw Yul source code
        runtime_only: If True, only transpile runtime code
        yul_opt_level: Optimization level (none/safe/standard/aggressive/maximum)
        immutables: Dictionary of immutable values
        debug: Enable debug output
        
    Returns:
        EVM bytecode as hex string with 0x prefix
    """
    config = TranspilationConfig(
        yul_source=yul_source,
        runtime_only=runtime_only,
        yul_opt_level=YulOptLevel(yul_opt_level),
        immutables=immutables or {},
        debug=debug
    )
    
    pipeline = TranspilationPipeline(config)
    result = pipeline.run()
    return result.bytecode
