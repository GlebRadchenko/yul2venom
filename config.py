"""
Yul2Venom Configuration Loader
==============================
Configuration hierarchy (later overrides earlier):
1. Default values (always available in memory)
2. YAML config file (if present)
3. CLI arguments (highest priority)

Usage:
    from config import get_config, apply_cli_overrides
    
    config = get_config()  # Load from file or use defaults
    config = apply_cli_overrides(config, args)  # Apply CLI overrides
"""

import sys
from dataclasses import dataclass, field, replace
from pathlib import Path
from typing import Optional, Any

try:
    import yaml
except ImportError:
    yaml = None

# Import constants as default values
try:
    from utils.constants import (
        VENOM_MEMORY_START, SPILL_OFFSET, YUL_FMP_SLOT, YUL_HEAP_START,
        DEFAULT_CONFIG_DIR, DEFAULT_OUTPUT_DIR, DEFAULT_SOL_DIR
    )
except ImportError:
    # Fallback defaults if constants not available
    VENOM_MEMORY_START = 0x100
    SPILL_OFFSET = 0x4000
    YUL_FMP_SLOT = 0x40
    YUL_HEAP_START = 0x80
    DEFAULT_CONFIG_DIR = "configs"
    DEFAULT_OUTPUT_DIR = "output"
    DEFAULT_SOL_DIR = "foundry/src"


# =============================================================================
# Config Dataclasses with Defaults
# =============================================================================

@dataclass
class InliningConfig:
    """Configuration for function inlining heuristics."""
    stmt_threshold: int = 1   # Functions with >N statements may be emitted
    call_threshold: int = 2   # Functions called >N times may be emitted
    enabled: bool = True      # Enable inlining heuristic


@dataclass
class YulOptimizerConfig:
    """Configuration for Yul source optimizer."""
    level: str = "safe"       # safe, standard, aggressive, maximum
    max_passes: int = 5       # Maximum convergence passes


@dataclass
class OptimizationConfig:
    """Configuration for Venom IR optimization passes."""
    level: str = "yul-o2"  # none, O0, O2, O3, Os, native, debug, yul-o2
    # DJMP threshold: minimum case count to use O(1) jump table dispatch.
    # Trade-off analysis:
    #   - DJMP overhead: codecopy + mload + djmp ≈ 20 gas setup + 8 gas/jump
    #   - JNZ chain: ~9 gas per comparison (eq + jnz)
    # Break-even point is ~3-4 cases. Default 4 is conservative.
    # Lower = more aggressive O(1) dispatch, Higher = more linear search.
    djmp_threshold: int = 4


@dataclass
class MemoryConfig:
    """Memory layout configuration (defaults from utils/constants.py)."""
    venom_start: int = VENOM_MEMORY_START  # Where Venom allocates stack spills
    spill_offset: int = SPILL_OFFSET       # Beyond Yul heap
    fmp_slot: int = YUL_FMP_SLOT           # Solidity free memory pointer slot
    heap_start: int = YUL_HEAP_START       # Yul heap start


@dataclass
class DebugConfig:
    """Configuration for debug output."""
    save_raw_ir: bool = True
    save_opt_ir: bool = True
    save_assembly: bool = True
    verbose_inlining: bool = True
    output_dir: str = "debug"


@dataclass
class OutputConfig:
    """Configuration for output files (defaults from utils/constants.py)."""
    dir: str = DEFAULT_OUTPUT_DIR
    suffix: str = "_opt"


@dataclass
class ParserConfig:
    """Configuration for parser."""
    recursion_limit: int = 5000


@dataclass
class BackendConfig:
    """Configuration for EVM backend."""
    evm_version: str = "cancun"
    experimental: bool = False


@dataclass
class SafetyConfig:
    """Configuration for transpiler safety checks.
    
    strict_intrinsics: If True, dataoffset/datasize/loadimmutable failures
                       raise exceptions instead of returning 0 with a warning.
                       Default is False for backward compatibility.
    """
    strict_intrinsics: bool = False


@dataclass
class PathsConfig:
    """Configuration for project paths (defaults from utils/constants.py)."""
    configs: str = DEFAULT_CONFIG_DIR
    sol_dir: str = DEFAULT_SOL_DIR


@dataclass
class TranspilerConfig:
    """Complete transpiler configuration with sensible defaults."""
    inlining: InliningConfig = field(default_factory=InliningConfig)
    yul_optimizer: YulOptimizerConfig = field(default_factory=YulOptimizerConfig)
    optimization: OptimizationConfig = field(default_factory=OptimizationConfig)
    memory: MemoryConfig = field(default_factory=MemoryConfig)
    debug: DebugConfig = field(default_factory=DebugConfig)
    output: OutputConfig = field(default_factory=OutputConfig)
    parser: ParserConfig = field(default_factory=ParserConfig)
    backend: BackendConfig = field(default_factory=BackendConfig)
    paths: PathsConfig = field(default_factory=PathsConfig)
    safety: SafetyConfig = field(default_factory=SafetyConfig)
    
    @classmethod
    def from_dict(cls, data: dict) -> "TranspilerConfig":
        """Create config from dictionary, overlaying on defaults."""
        config = cls()  # Start with defaults
        
        if "inlining" in data:
            d = data["inlining"]
            config.inlining = InliningConfig(
                stmt_threshold=d.get("stmt_threshold", config.inlining.stmt_threshold),
                call_threshold=d.get("call_threshold", config.inlining.call_threshold),
                enabled=d.get("enabled", config.inlining.enabled),
            )
        
        if "yul_optimizer" in data:
            d = data["yul_optimizer"]
            config.yul_optimizer = YulOptimizerConfig(
                level=d.get("level", config.yul_optimizer.level),
                max_passes=d.get("max_passes", config.yul_optimizer.max_passes),
            )
        
        if "optimization" in data:
            d = data["optimization"]
            config.optimization = OptimizationConfig(
                level=d.get("level", config.optimization.level),
                djmp_threshold=d.get("djmp_threshold", config.optimization.djmp_threshold),
            )
        
        if "memory" in data:
            d = data["memory"]
            config.memory = MemoryConfig(
                venom_start=d.get("venom_start", config.memory.venom_start),
                spill_offset=d.get("spill_offset", config.memory.spill_offset),
                fmp_slot=d.get("fmp_slot", config.memory.fmp_slot),
                heap_start=d.get("heap_start", config.memory.heap_start),
            )
        
        if "debug" in data:
            d = data["debug"]
            config.debug = DebugConfig(
                save_raw_ir=d.get("save_raw_ir", config.debug.save_raw_ir),
                save_opt_ir=d.get("save_opt_ir", config.debug.save_opt_ir),
                save_assembly=d.get("save_assembly", config.debug.save_assembly),
                verbose_inlining=d.get("verbose_inlining", config.debug.verbose_inlining),
                output_dir=d.get("output_dir", config.debug.output_dir),
            )
        
        if "output" in data:
            d = data["output"]
            config.output = OutputConfig(
                dir=d.get("dir", config.output.dir),
                suffix=d.get("suffix", config.output.suffix),
            )
        
        if "parser" in data:
            d = data["parser"]
            config.parser = ParserConfig(
                recursion_limit=d.get("recursion_limit", config.parser.recursion_limit),
            )
        
        if "backend" in data:
            d = data["backend"]
            config.backend = BackendConfig(
                evm_version=d.get("evm_version", config.backend.evm_version),
                experimental=d.get("experimental", config.backend.experimental),
            )
        
        if "paths" in data:
            d = data["paths"]
            config.paths = PathsConfig(
                configs=d.get("configs", config.paths.configs),
                sol_dir=d.get("sol_dir", config.paths.sol_dir),
            )
        
        if "safety" in data:
            d = data["safety"]
            config.safety = SafetyConfig(
                strict_intrinsics=d.get("strict_intrinsics", config.safety.strict_intrinsics),
            )
        
        return config


# =============================================================================
# Config File Loading
# =============================================================================

DEFAULT_CONFIG_PATHS = [
    "yul2venom.config.yaml",
    "yul2venom.config.yml",
    ".yul2venom.yaml",
    ".yul2venom.yml",
]


def find_config_file(start_dir: Optional[Path] = None) -> Optional[Path]:
    """Search for config file in package dir, then current and parent directories."""
    # Priority 1: Check yul2venom package directory (where this config.py lives)
    package_dir = Path(__file__).parent
    for name in DEFAULT_CONFIG_PATHS:
        config_path = package_dir / name
        if config_path.exists():
            return config_path
    
    # Priority 2: Search from CWD upwards (for project-specific overrides)
    if start_dir is None:
        start_dir = Path.cwd()
    
    current = start_dir
    while current != current.parent:
        for name in DEFAULT_CONFIG_PATHS:
            config_path = current / name
            if config_path.exists():
                return config_path
        current = current.parent
    
    return None


def load_config(config_path: Optional[str] = None) -> TranspilerConfig:
    """
    Load configuration with hierarchy: defaults → file → (CLI applied separately).
    
    Args:
        config_path: Explicit path to config file. If None, searches default locations.
    
    Returns:
        TranspilerConfig with defaults, overlaid with file settings if found.
    """
    # Always start with defaults
    config = TranspilerConfig()
    
    if yaml is None:
        # PyYAML not installed, use defaults only
        return config
    
    # Find config file
    if config_path:
        path = Path(config_path)
        if not path.exists():
            print(f"Warning: Config file not found: {config_path}", file=sys.stderr)
            return config
    else:
        path = find_config_file()
        if path is None:
            # No config file, use defaults
            return config
    
    # Overlay file config on defaults
    try:
        with open(path, "r") as f:
            data = yaml.safe_load(f) or {}
        config = TranspilerConfig.from_dict(data)
        print(f"Loaded config from: {path}", file=sys.stderr)
    except Exception as e:
        print(f"Warning: Failed to load config: {e}", file=sys.stderr)
    
    return config


def apply_cli_overrides(config: TranspilerConfig, args: Any) -> TranspilerConfig:
    """
    Apply CLI argument overrides to config (CLI has highest priority).
    
    Args:
        config: Base config (from defaults + file)
        args: argparse Namespace with CLI arguments
    
    Returns:
        Config with CLI overrides applied
    """
    # Optimization level from CLI
    if hasattr(args, 'optimize') and args.optimize:
        config.optimization = OptimizationConfig(level=args.optimize)
    
    # Yul optimizer level from CLI
    if hasattr(args, 'yul_opt_level') and args.yul_opt_level:
        config.yul_optimizer = YulOptimizerConfig(
            level=args.yul_opt_level,
            max_passes=config.yul_optimizer.max_passes
        )
    
    # Output directory from CLI
    if hasattr(args, 'output') and args.output:
        config.output = OutputConfig(
            dir=str(Path(args.output).parent) if args.output else config.output.dir,
            suffix=config.output.suffix
        )
    
    return config


# =============================================================================
# Global Config Singleton
# =============================================================================

_global_config: Optional[TranspilerConfig] = None


def get_config() -> TranspilerConfig:
    """Get global config, loading from file on first call."""
    global _global_config
    if _global_config is None:
        _global_config = load_config()
    return _global_config


def set_config(config: TranspilerConfig) -> None:
    """Set global config."""
    global _global_config
    _global_config = config


def reset_config() -> None:
    """Reset global config (for testing)."""
    global _global_config
    _global_config = None


def get_default_config() -> TranspilerConfig:
    """Get fresh default configuration (ignores file/global)."""
    return TranspilerConfig()
