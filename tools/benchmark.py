#!/usr/bin/env python3
"""
Yul2Venom Benchmark Tool

Production-grade benchmarking comparing transpiled bytecode against various Solc configurations.

Usage:
    python3.11 tools/benchmark.py [--config config.yaml] [--output report.md]
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import time
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Optional

# Add project root to path
PROJECT_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

# Import path sanitization utility
from utils.constants import sanitize_paths

# ANSI escape sequence pattern (includes mouse tracking, cursor movement, etc)
ANSI_ESCAPE = re.compile(r'''
    \x1b       # ESC
    (?:        # Start non-capturing group
        \[     # CSI
        [0-9;?<>=]*[A-Za-z~]  # Parameters + letter (covers all CSI sequences)
    |
        \][^\x07]*\x07  # OSC
    |
        [PX^_][^\x1b]*\x1b\\  # DCS/SOS/PM/APC
    )
''', re.VERBOSE)

# Also match caret-notation like ^[[A
CARET_ESCAPE = re.compile(r'\^?\[\[[0-9;?<>=]*[A-Za-z~]')

def strip_ansi(text: str) -> str:
    """Remove all ANSI escape sequences from text."""
    # Remove real escape sequences
    text = ANSI_ESCAPE.sub('', text)
    # Remove caret-notation escape sequences (^[[A style)
    text = CARET_ESCAPE.sub('', text)
    # Also remove raw ^[ representations
    text = text.replace('\x1b', '')
    return text

# ============================================================================
# Configuration
# ============================================================================

@dataclass
class BenchmarkConfig:
    """Benchmark configuration."""
    # Contracts to benchmark
    contracts: list[str] = field(default_factory=lambda: [
        "Arithmetic",
        "ControlFlow",
        "StateManagement", 
        "DataStructures",
        "Functions",
        "Events",
        "Encoding",
        "Edge",
    ])
    
    # Transpiler optimization level (none, O0, O2, O3, Os, debug, yul-o2, native)
    # yul-o2 = PASSES_YUL_O2 (optimized for Yul-sourced IR) - use this for benchmarks
    transpiler_opt_level: str = "yul-o2"
    
    # Yul source optimizer level (none, safe, standard, aggressive, maximum)
    yul_opt_level: str = "aggressive"
    
    # Solc optimization runs to test
    # Note: optimizer-runs affects both default and via-ir modes
    optimization_runs: list[int] = field(default_factory=lambda: [
        200,    # Default
    ])
    
    # Solc compilation modes
    # - default: Traditional optimizer (--optimize) - supports runs permutation
    # - via_ir: Compile via IR (--via-ir --optimize) - supports runs permutation
    # - ir_optimized: Output optimized IR (--ir-optimized) - NO runs (single output)
    solc_modes: list[str] = field(default_factory=lambda: [
        "default",       # --optimize (no via-ir) - traditional optimizer
        "via_ir",       # --via-ir --optimize - compile via Yul then optimize
        "ir_optimized", # --ir-optimized --optimize - output optimized Yul IR (no runs)
    ])
    
    # Baseline for comparison (format: "mode_runs", e.g., "default_200")
    baseline: str = "default_200"
    
    # Paths
    foundry_dir: Path = field(default_factory=lambda: PROJECT_ROOT / "foundry")
    output_dir: Path = field(default_factory=lambda: PROJECT_ROOT / "output")
    configs_dir: Path = field(default_factory=lambda: PROJECT_ROOT / "configs" / "bench")
    bench_src: Path = field(default_factory=lambda: PROJECT_ROOT / "foundry" / "src" / "bench")
    
    # Report output
    report_file: Path = field(default_factory=lambda: PROJECT_ROOT / "benchmark_report.md")
    json_file: Path = field(default_factory=lambda: PROJECT_ROOT / "benchmark_data.json")
    
    # Force rebuild
    force_rebuild: bool = True
    
    # Verbose output
    verbose: bool = False
    
    # Gas benchmarking
    gas_enabled: bool = False


def load_config(config_path: Optional[Path]) -> BenchmarkConfig:
    """Load configuration from YAML profile file.
    
    Supports two formats:
    1. Flat format (legacy): keys map directly to BenchmarkConfig fields
    2. Nested format (new): structured with optimization/solc/output sections
    
    Args:
        config_path: Path to YAML profile file
        
    Returns:
        Populated BenchmarkConfig
    """
    config = BenchmarkConfig()
    
    if not config_path or not config_path.exists():
        return config
    
    try:
        import yaml
        with open(config_path) as f:
            data = yaml.safe_load(f)
        
        if not data:
            return config
        
        # === Parse nested format (new profiles) ===
        
        # Contracts list
        if 'contracts' in data:
            config.contracts = data['contracts']
        
        # Optimization section
        opt = data.get('optimization', {})
        if 'venom_level' in opt:
            config.transpiler_opt_level = opt['venom_level']
        if 'yul_level' in opt:
            config.yul_opt_level = opt['yul_level']
        
        # Solc section
        solc = data.get('solc', {})
        if 'runs' in solc:
            config.optimization_runs = solc['runs']
        if 'modes' in solc:
            config.solc_modes = solc['modes']
        if 'baseline' in solc:
            config.baseline = solc['baseline']
        
        # Output section
        output = data.get('output', {})
        if 'report' in output:
            config.report_file = PROJECT_ROOT / output['report']
        if 'json' in output:
            config.json_file = PROJECT_ROOT / output['json']
        
        # Benchmarks section (new format)
        benchmarks = data.get('benchmarks', {})
        if 'gas' in benchmarks:
            config.gas_enabled = benchmarks['gas']
        if 'bytecode' in benchmarks:
            # bytecode is always enabled; this is for future extensibility
            pass
        
        # Top-level options
        if 'gas_enabled' in data:
            config.gas_enabled = data['gas_enabled']
        if 'verbose' in data:
            config.verbose = data['verbose']
        if 'force_rebuild' in data:
            config.force_rebuild = data['force_rebuild']
        
        # === Legacy flat format fallback ===
        # Direct key mapping for backward compatibility
        for key in ['transpiler_opt_level', 'yul_opt_level', 'optimization_runs',
                    'solc_modes', 'baseline', 'verbose', 'gas_enabled', 'force_rebuild']:
            if key in data and not isinstance(data[key], dict):
                setattr(config, key, data[key])
        
        if 'report_file' in data:
            config.report_file = Path(data['report_file'])
        if 'json_file' in data:
            config.json_file = Path(data['json_file'])
            
    except ImportError:
        print("[WARN] PyYAML not installed. Run: pip install pyyaml")
    except Exception as e:
        print(f"[WARN] Failed to load profile: {e}")
    
    return config


# ============================================================================
# Result Types
# ============================================================================


@dataclass
class CompilationResult:
    """Result of a single compilation."""
    success: bool
    bytecode_size: int  # bytes
    error: Optional[str] = None
    compile_time_ms: float = 0.0
    bytecode_path: Optional[Path] = None  # Path to bytecode file for gas testing


@dataclass
class GasResult:
    """Gas usage for a function call."""
    function: str
    min_gas: int = 0
    avg_gas: int = 0
    max_gas: int = 0
    calls: int = 0


@dataclass
class ContractResults:
    """Results for a single contract across all configurations."""
    contract: str
    transpiled: CompilationResult = field(default_factory=lambda: CompilationResult(False, 0))
    solc_results: dict[str, CompilationResult] = field(default_factory=dict)
    # Per-config gas results: config_name -> list of GasResult
    gas_results: dict[str, list[GasResult]] = field(default_factory=dict)


# ============================================================================
# Compilation Functions
# ============================================================================

def run_command(cmd: list[str], cwd: Optional[Path] = None, timeout: int = 120, env: Optional[dict] = None) -> tuple[int, str, str]:
    """Run a command and return (returncode, stdout, stderr).
    
    Uses TERM=dumb and NO_COLOR=1 to suppress terminal escape sequences.
    Output is cleaned of any remaining ANSI codes.
    """
    try:
        # Set up clean environment to suppress terminal escape codes
        cmd_env = os.environ.copy()
        cmd_env["TERM"] = "dumb"
        cmd_env["NO_COLOR"] = "1"
        cmd_env["FORCE_COLOR"] = "0"
        cmd_env["CI"] = "1"  # Many tools disable fancy output in CI
        if env:
            cmd_env.update(env)
        
        result = subprocess.run(
            cmd, 
            capture_output=True, 
            text=True, 
            cwd=cwd,
            timeout=timeout,
            env=cmd_env
        )
        # Strip any remaining ANSI codes from output
        return result.returncode, strip_ansi(result.stdout), strip_ansi(result.stderr)
    except subprocess.TimeoutExpired:
        return -1, "", "Timeout"
    except Exception as e:
        return -1, "", str(e)


def get_bytecode_size(path: Path) -> int:
    """Get bytecode size in bytes from a bin file (binary or hex text)."""
    if not path.exists():
        return 0
    
    # First try reading as binary (yul2venom.py outputs raw bytes)
    try:
        content = path.read_bytes()
        # Check if it looks like raw bytecode (not ASCII hex)
        if len(content) > 0 and not all(c in b'0123456789abcdefABCDEF\n\r\t x' for c in content[:100]):
            return len(content)
    except Exception:
        pass
    
    # Fall back to hex text format
    try:
        content = path.read_text().strip()
        if content.startswith("0x"):
            content = content[2:]
        return len(content) // 2
    except Exception:
        return 0


def get_artifact_size(artifact_path: Path) -> int:
    """Get deployed bytecode size from Forge artifact."""
    if not artifact_path.exists():
        return 0
    try:
        with open(artifact_path) as f:
            data = json.load(f)
        bytecode = data.get("deployedBytecode", {}).get("object", "")
        if bytecode.startswith("0x"):
            bytecode = bytecode[2:]
        return len(bytecode) // 2
    except Exception:
        return 0


def transpile_contract(config: BenchmarkConfig, contract: str) -> CompilationResult:
    """Transpile a contract through the full Yul2Venom pipeline using yul2venom.py CLI."""
    start_time = time.time()
    
    try:
        config_path = config.configs_dir / f"{contract}.yul2venom.json"
        src_path = config.bench_src / f"{contract}.sol"
        
        if not src_path.exists():
            return CompilationResult(False, 0, f"Source not found: {src_path}")
        
        # Check if yul file exists (from config or default path)
        yul_exists = False
        if config_path.exists():
            with open(config_path) as f:
                cfg = json.load(f)
            yul_path = cfg.get("yul", "")
            if yul_path and (PROJECT_ROOT / yul_path).exists():
                yul_exists = True
        
        # If config or yul doesn't exist, run prepare
        if not config_path.exists() or not yul_exists:
            # Run prepare command to generate config and yul
            rc, stdout, stderr = run_command([
                "python3.11", str(PROJECT_ROOT / "yul2venom.py"),
                "prepare", str(src_path),
                "--config", str(config_path)
            ], cwd=PROJECT_ROOT, timeout=120)
            
            if rc != 0:
                return CompilationResult(False, 0, f"Prepare failed: {stderr[:200]}")
            
            # After prepare, relocate yul to output/bench/ and update config
            with open(config_path) as f:
                cfg = json.load(f)
            old_yul_path = cfg.get("yul", "")
            if old_yul_path:
                old_abs = PROJECT_ROOT / old_yul_path
                new_abs = config.output_dir / Path(old_yul_path).name
                if old_abs.exists() and old_abs != new_abs:
                    config.output_dir.mkdir(parents=True, exist_ok=True)
                    shutil.move(str(old_abs), str(new_abs))
                    cfg["yul"] = str(new_abs.relative_to(PROJECT_ROOT))
                    with open(config_path, 'w') as f:
                        json.dump(cfg, f, indent=2)
        
        # Run transpile command with specified optimization levels
        cmd = [
            "python3.11", str(PROJECT_ROOT / "yul2venom.py"),
            "transpile", str(config_path),
            "-O", config.transpiler_opt_level,
            "--runtime-only"  # Output runtime bytecode only (no init code)
        ]
        # Add yul optimization level if specified
        if config.yul_opt_level and config.yul_opt_level != "none":
            cmd.extend(["--yul-opt-level", config.yul_opt_level])
        
        # Verbose logging
        if config.verbose:
            print(f"    → Yul Optimizer: {config.yul_opt_level or 'disabled'}")
            print(f"    → Venom IR Pipeline: {config.transpiler_opt_level}")
        
        rc, stdout, stderr = run_command(cmd, cwd=PROJECT_ROOT, timeout=180)
        
        # Parse and show optimization stats if verbose
        if config.verbose and "Yul Source Optimization Report" in stderr:
            # Extract key stats from optimizer output
            for line in stderr.split('\n'):
                if 'Reduction' in line or 'Applied Rules:' in line:
                    print(f"    {line.strip()}")
                elif line.strip().startswith('•'):
                    print(f"      {line.strip()}")
        
        # Find the output bytecode file FIRST
        # yul2venom.py outputs to same directory as yul file, named <Contract>_opt.bin
        with open(config_path) as f:
            cfg = json.load(f)
        
        # Get contract name and output directory from config's yul path
        contract_name = contract
        yul_path = cfg.get("yul", "")
        yul_output_dir = PROJECT_ROOT / "output"  # default
        if yul_path:
            # Extract contract name from yul path like "output/Arithmetic.yul"
            yul_path_obj = Path(yul_path)
            base = yul_path_obj.stem
            if base:
                contract_name = base
            # yul2venom.py outputs to the same directory as the yul file
            # e.g., output/Arithmetic.yul -> output/Arithmetic_opt.bin
            if yul_path_obj.parent.name:
                yul_output_dir = PROJECT_ROOT / yul_path_obj.parent
        
        # Primary: look in same directory as yul file
        bin_path = yul_output_dir / f"{contract_name}_opt.bin"
        
        if not bin_path.exists():
            # Fallback 1: config.output_dir (for backwards compatibility)
            bin_path = config.output_dir / f"{contract_name}_opt.bin"
        
        if not bin_path.exists():
            # Try _opt_runtime.bin pattern (older format)
            bin_path = config.output_dir / f"{contract_name}_opt_runtime.bin"
        
        # Check success by output file existence (more reliable than return code)
        # Return code may be non-zero if optimizer prints warnings to stderr
        if not bin_path.exists():
            if rc != 0:
                return CompilationResult(False, 0, f"Transpile failed: {stderr[:300]}")
            return CompilationResult(False, 0, f"Output not found: {bin_path}")
        
        size = get_bytecode_size(bin_path)
        elapsed = (time.time() - start_time) * 1000
        
        return CompilationResult(True, size, compile_time_ms=elapsed)
        
    except Exception as e:
        return CompilationResult(False, 0, str(e))


def compile_solc(config: BenchmarkConfig, contract: str, mode: str, runs: int) -> CompilationResult:
    """Compile a contract with Solc.
    
    Modes:
    - default: forge --optimize (traditional optimizer)
    - via_ir: forge --via-ir --optimize (Yul-based optimizer)  
    - ir_optimized: solc --ir-optimized --optimize (direct optimized Yul to bytecode)
    """
    start_time = time.time()
    
    try:
        src_path = config.bench_src / f"{contract}.sol"
        if not src_path.exists():
            return CompilationResult(False, 0, f"Source not found: {src_path}")
        
        # Set up output directory
        out_dir = config.output_dir / f"solc_{mode}_{runs}"
        out_dir.mkdir(parents=True, exist_ok=True)
        
        if mode == "ir_optimized":
            # ir_optimized mode uses solc --ir-optimized --optimize
            # Note: --ir-optimized doesn't support --optimizer-runs
            cmd = [
                "solc",
                "--ir-optimized",
                "--optimize",
                "--combined-json", "bin-runtime",
                str(src_path),
            ]
            
            rc, stdout, stderr = run_command(cmd, cwd=PROJECT_ROOT, timeout=180)
            
            if rc != 0:
                return CompilationResult(False, 0, f"Solc failed: {stderr[:200]}")
            
            # Parse combined-json output - only first line (before "Optimized IR:")
            try:
                # Extract just the JSON line (first line)
                json_line = stdout.split('\n')[0]
                data = json.loads(json_line)
                contracts = data.get("contracts", {})
                # Find the contract (key format: "path:ContractName")
                bytecode = ""
                for key, val in contracts.items():
                    if key.endswith(f":{contract}"):
                        bytecode = val.get("bin-runtime", "")
                        break
                
                if not bytecode:
                    return CompilationResult(False, 0, f"Contract not found in output")
                
                size = len(bytecode) // 2
                elapsed = (time.time() - start_time) * 1000
                return CompilationResult(True, size, compile_time_ms=elapsed)
                
            except json.JSONDecodeError as e:
                return CompilationResult(False, 0, f"JSON parse error: {e}")
        
        else:
            # default and via_ir modes use forge
            cmd = [
                "forge", "build",
                "--contracts", f"src/bench/{contract}.sol",
                "--optimize",
                "--optimizer-runs", str(runs),
                "--out", str(out_dir),
                "--force",
            ]
            
            if mode == "via_ir":
                cmd.append("--via-ir")
            # Note: default mode (no via_ir) is the default, no flag needed
            
            rc, stdout, stderr = run_command(cmd, cwd=config.foundry_dir, timeout=180)
            
            if rc != 0:
                return CompilationResult(False, 0, f"Forge failed: {stderr[:200]}")
            
            # Get artifact size
            artifact_path = out_dir / f"{contract}.sol" / f"{contract}.json"
            size = get_artifact_size(artifact_path)
            elapsed = (time.time() - start_time) * 1000
            
            if size == 0:
                return CompilationResult(False, 0, "No bytecode in artifact")
            
            return CompilationResult(True, size, compile_time_ms=elapsed)
        
    except Exception as e:
        return CompilationResult(False, 0, str(e))


def run_gas_benchmark(config: BenchmarkConfig, contract: str, bytecode_path: Optional[Path]) -> list[GasResult]:
    """
    Run gas benchmark for a contract with optional bytecode injection.
    
    If bytecode_path is provided, sets BYTECODE_PATH env var for the test.
    Parses forge gas report to extract per-function gas usage.
    """
    results = []
    
    # Set up environment with clean terminal settings
    env = os.environ.copy()
    env["TERM"] = "dumb"
    env["NO_COLOR"] = "1"
    env["FORCE_COLOR"] = "0"
    env["CI"] = "1"
    
    if bytecode_path and bytecode_path.exists():
        # Use absolute path since forge runs in foundry directory
        env["BYTECODE_PATH"] = str(bytecode_path.absolute())
    else:
        # For native Solc, pass empty string to use native contract
        env["BYTECODE_PATH"] = ""
    
    # Run forge test with extra verbose output to see traces with gas
    test_contract = f"{contract}Test"
    cmd = [
        "forge", "test",
        "--match-contract", test_contract,
        "-vvvv"  # Extra verbose for traces with function gas
    ]
    
    try:
        result = subprocess.run(
            cmd,
            cwd=config.foundry_dir,
            capture_output=True,
            text=True,
            timeout=300,
            env=env
        )
        
        # Clean output of any escape sequences
        output = strip_ansi(result.stdout + result.stderr)
        
        # Parse gas from trace lines - handles two formats:
        # Native:   [799] Arithmetic::safeAdd(10, 20) [staticcall]
        # Injected: [686] 0x0000...1111::safeAdd(10, 20) [staticcall]
        # We match both ContractName:: and 0x...:: patterns
        trace_pattern = re.compile(r'\[(\d+)\]\s+(?:' + contract + r'|0x[0-9a-fA-F]+)::(\w+)\(')
        seen_funcs = set()
        
        for line in output.split('\n'):
            match = trace_pattern.search(line)
            if match:
                gas = int(match.group(1))
                func_name = match.group(2)
                # Avoid duplicates - take first occurrence (call, not the return)
                if func_name not in seen_funcs:
                    seen_funcs.add(func_name)
                    results.append(GasResult(
                        function=func_name,
                        min_gas=gas,
                        avg_gas=gas,
                        max_gas=gas,
                        calls=1
                    ))
                
    except subprocess.TimeoutExpired:
        if config.verbose:
            print(f"    Gas benchmark timed out")
    except Exception as e:
        if config.verbose:
            print(f"    Gas benchmark error: {e}")
    
    return results


# ============================================================================
# Benchmarking
# ============================================================================

def benchmark_contract(config: BenchmarkConfig, contract: str) -> ContractResults:
    """Benchmark a single contract across all configurations."""
    results = ContractResults(contract=contract)
    
    # Transpile with current optimization levels
    # Show both Yul source optimization (yul_opt_level) and Venom IR optimization (transpiler_opt_level)
    opt_label = f"{config.yul_opt_level}+{config.transpiler_opt_level}" if config.yul_opt_level else config.transpiler_opt_level
    print(f"  [Transpiling ({opt_label})]", end=" ", flush=True)
    results.transpiled = transpile_contract(config, contract)
    if results.transpiled.success:
        print(f"✓ {results.transpiled.bytecode_size} bytes")
    else:
        print(f"✗ {results.transpiled.error or 'failed'}")
    
    # Compile with each Solc configuration
    for mode in config.solc_modes:
        for runs in config.optimization_runs:
            # ir_optimized doesn't use runs parameter
            if mode == "ir_optimized":
                key = "ir_optimized"
                label = "ir_optimized"
            else:
                key = f"{mode}_{runs}"
                label = f"{mode} runs={runs}"
            
            # Skip duplicate ir_optimized runs (only run once)
            if key in results.solc_results:
                continue
                
            print(f"  [Solc {label}]", end=" ", flush=True)
            results.solc_results[key] = compile_solc(config, contract, mode, runs)
            r = results.solc_results[key]
            if r.success:
                print(f"✓ {r.bytecode_size} bytes")
            else:
                print(f"✗ {r.error or 'failed'}")
    
    # Run gas benchmarks if enabled
    if config.gas_enabled:
        print(f"  [Gas Benchmarks]")
        
        # Gas test for transpiled bytecode
        if results.transpiled.success:
            # yul2venom.py writes to output/bench/<Contract>_opt.bin (from config)
            bin_path = config.output_dir / f"{contract}_opt.bin"
            if bin_path.exists():
                print(f"    Transpiled...", end=" ", flush=True)
                gas = run_gas_benchmark(config, contract, bin_path)
                results.gas_results["transpiled"] = gas
                print(f"✓ {len(gas)} functions")
        
        # Gas test for native (no bytecode injection = uses Solc compiled)
        print(f"    Native (Solc)...", end=" ", flush=True)
        gas = run_gas_benchmark(config, contract, None)
        results.gas_results["native"] = gas
        print(f"✓ {len(gas)} functions")
    
    return results


def run_benchmarks(config: BenchmarkConfig) -> list[ContractResults]:
    """Run all benchmarks."""
    all_results = []
    
    config.output_dir.mkdir(parents=True, exist_ok=True)
    
    for i, contract in enumerate(config.contracts, 1):
        print(f"\n[{i}/{len(config.contracts)}] {contract}")
        print("-" * 50)
        results = benchmark_contract(config, contract)
        all_results.append(results)
    
    return all_results


# ============================================================================
# Reporting
# ============================================================================

def calculate_delta(value: int, baseline: int) -> str:
    """Calculate percentage difference from baseline."""
    if baseline == 0 or value == 0:
        return "N/A"
    delta = (value - baseline) / baseline * 100
    if delta >= 0:
        return f"+{delta:.1f}%"
    else:
        return f"{delta:.1f}%"


def format_size(size: int, success: bool = True) -> str:
    """Format size for display."""
    if not success or size == 0:
        return "FAILED"
    return str(size)


def generate_markdown_report(config: BenchmarkConfig, results: list[ContractResults]) -> str:
    """Generate markdown benchmark report with properly aligned tables."""
    lines = [
        "# Yul2Venom Benchmark Report",
        "",
        f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        f"**Baseline:** `{config.baseline}`",
        "",
        "---",
        "",
        "## Summary",
        "",
    ]
    
    # Summary statistics
    successful = sum(1 for r in results if r.transpiled.success)
    lines.append(f"- **Contracts benchmarked:** {len(results)}")
    lines.append(f"- **Transpilation success:** {successful}/{len(results)}")
    lines.append(f"- **Optimization runs tested:** {config.optimization_runs}")
    lines.append(f"- **Solc modes:** {config.solc_modes}")
    lines.append("")
    
    # Build configs list
    configs = []
    for mode in config.solc_modes:
        if mode == "ir_optimized":
            if "ir_optimized" not in configs:
                configs.append("ir_optimized")
        else:
            for runs in config.optimization_runs:
                configs.append(f"{mode}_{runs}")
    
    # Column widths for uniform tables
    COL_CONTRACT = 18
    COL_SIZE = 12
    COL_DELTA = 12
    
    def pad(text: str, width: int, align: str = "left") -> str:
        """Pad text to width with specified alignment."""
        if align == "center":
            return text.center(width)
        elif align == "right":
            return text.rjust(width)
        return text.ljust(width)
    
    # ========== Bytecode Size Table ==========
    lines.extend([
        "## Bytecode Size (bytes)",
        "",
    ])
    
    # Build header with consistent widths
    header_parts = [pad("Contract", COL_CONTRACT), pad("Transpiled", COL_SIZE, "center")]
    sep_parts = ["-" * COL_CONTRACT, ":" + "-" * (COL_SIZE - 2) + ":"]
    
    for cfg in configs:
        header_parts.append(pad(cfg, COL_SIZE, "center"))
        sep_parts.append(":" + "-" * (COL_SIZE - 2) + ":")
    
    lines.append("| " + " | ".join(header_parts) + " |")
    lines.append("|" + "|".join(sep_parts) + "|")
    
    # Data rows
    for r in results:
        row_parts = [
            pad(r.contract, COL_CONTRACT),
            pad(format_size(r.transpiled.bytecode_size, r.transpiled.success), COL_SIZE, "center"),
        ]
        for cfg in configs:
            res = r.solc_results.get(cfg)
            if res:
                row_parts.append(pad(format_size(res.bytecode_size, res.success), COL_SIZE, "center"))
            else:
                row_parts.append(pad("N/A", COL_SIZE, "center"))
        lines.append("| " + " | ".join(row_parts) + " |")
    
    # ========== Delta Table ==========
    lines.extend([
        "",
        f"## Size Delta vs Baseline (`{config.baseline}`)",
        "",
    ])
    
    # Header
    header_parts = [pad("Contract", COL_CONTRACT), pad("Transpiled", COL_DELTA, "center")]
    sep_parts = ["-" * COL_CONTRACT, ":" + "-" * (COL_DELTA - 2) + ":"]
    
    for cfg in configs:
        if cfg != config.baseline:
            header_parts.append(pad(cfg, COL_DELTA, "center"))
            sep_parts.append(":" + "-" * (COL_DELTA - 2) + ":")
    
    lines.append("| " + " | ".join(header_parts) + " |")
    lines.append("|" + "|".join(sep_parts) + "|")
    
    # Data rows
    for r in results:
        baseline_result = r.solc_results.get(config.baseline)
        baseline_size = baseline_result.bytecode_size if baseline_result and baseline_result.success else 0
        
        row_parts = [
            pad(r.contract, COL_CONTRACT),
            pad(calculate_delta(r.transpiled.bytecode_size, baseline_size), COL_DELTA, "center"),
        ]
        for cfg in configs:
            if cfg != config.baseline:
                res = r.solc_results.get(cfg)
                if res and res.success:
                    row_parts.append(pad(calculate_delta(res.bytecode_size, baseline_size), COL_DELTA, "center"))
                else:
                    row_parts.append(pad("N/A", COL_DELTA, "center"))
        lines.append("| " + " | ".join(row_parts) + " |")
    
    # Gas benchmark results (if any)
    has_gas_data = any(r.gas_results for r in results)
    if has_gas_data:
        lines.extend([
            "",
            "---",
            "",
            "## Gas Usage (avg gas per function call)",
            "",
        ])
        
        for r in results:
            if not r.gas_results:
                continue
                
            lines.extend([
                f"### {r.contract}",
                "",
            ])
            
            # Build gas table
            # Columns: Function | Transpiled | Native | Delta
            # Build labels with config details
            transpiled_label = f"Transpiled ({config.yul_opt_level}+{config.transpiler_opt_level})"
            native_label = f"Native (Solc {config.baseline})"
            
            transpiled_gas = {g.function: g for g in r.gas_results.get("transpiled", [])}
            native_gas = {g.function: g for g in r.gas_results.get("native", [])}
            
            all_functions = sorted(set(transpiled_gas.keys()) | set(native_gas.keys()))
            
            if all_functions:
                lines.extend([
                    f"| Function | {transpiled_label} | {native_label} | Delta |",
                    "|:---------|:----------:|:-------------:|:-----:|",
                ])
                
                for func in all_functions:
                    t_gas = transpiled_gas.get(func)
                    n_gas = native_gas.get(func)
                    
                    t_str = str(t_gas.avg_gas) if t_gas else "N/A"
                    n_str = str(n_gas.avg_gas) if n_gas else "N/A"
                    
                    if t_gas and n_gas and n_gas.avg_gas > 0:
                        delta = ((t_gas.avg_gas - n_gas.avg_gas) / n_gas.avg_gas) * 100
                        if delta >= 0:
                            delta_str = f"+{delta:.1f}%"
                        else:
                            delta_str = f"{delta:.1f}%"
                    else:
                        delta_str = "N/A"
                    
                    lines.append(f"| {func} | {t_str} | {n_str} | {delta_str} |")
                
                lines.append("")
    
    # Configuration details
    lines.extend([
        "",
        "---",
        "",
        "## Configuration",
        "",
        "| Setting | Value |",
        "|---------|-------|",
        f"| Baseline | `{config.baseline}` |",
        f"| Optimization Runs | `{config.optimization_runs}` |",
        f"| Solc Modes | `{config.solc_modes}` |",
        "",
        "### Mode Descriptions",
        "",
        "- **default**: `solc --optimize --optimizer-runs=N` (traditional optimizer)",
        "- **via_ir**: `solc --via-ir --optimize --optimizer-runs=N` (Yul-based optimizer)",
        "- **ir_optimized**: `solc --ir-optimized --optimize` (outputs optimized Yul IR)",
        "- **Transpiled**: Yul → Venom IR → EVM via Yul2Venom",
        "",
        "### Interpretation",
        "",
        "- **Negative delta** = smaller than baseline (better)",
        "- **Positive delta** = larger than baseline (worse)",
        "- **FAILED** = compilation/transpilation failed",
    ])
    
    return "\n".join(lines)


def generate_json_data(config: BenchmarkConfig, results: list[ContractResults]) -> dict:
    """Generate JSON data for programmatic access.
    
    Error messages are sanitized to remove absolute paths.
    """
    data = {
        "generated": datetime.now().isoformat(),
        "config": {
            "baseline": config.baseline,
            "optimization_runs": config.optimization_runs,
            "solc_modes": config.solc_modes,
            "transpiler_opt_level": config.transpiler_opt_level,
        },
        "results": {}
    }
    
    for r in results:
        contract_data = {
            "transpiled": {
                "success": r.transpiled.success,
                "size": r.transpiled.bytecode_size,
                "error": sanitize_paths(r.transpiled.error) if r.transpiled.error else None,
            },
            "solc": {},
            "gas": {}
        }
        
        # Add Solc results
        for key, res in r.solc_results.items():
            contract_data["solc"][key] = {
                "success": res.success,
                "size": res.bytecode_size,
                "error": sanitize_paths(res.error) if res.error else None,
            }
        
        # Add gas results
        for variant, gas_list in r.gas_results.items():
            contract_data["gas"][variant] = [
                {
                    "function": g.function,
                    "avg_gas": g.avg_gas,
                    "min_gas": g.min_gas,
                    "max_gas": g.max_gas,
                    "calls": g.calls
                }
                for g in gas_list
            ]
        
        data["results"][r.contract] = contract_data
    
    return data


# ============================================================================
# Main
# ============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="Yul2Venom Benchmark Tool",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    python3.11 tools/benchmark.py
    python3.11 tools/benchmark.py --contracts Arithmetic,Functions
    python3.11 tools/benchmark.py --runs 0,200,1000000
    python3.11 tools/benchmark.py --baseline default_0
        """
    )
    parser.add_argument(
        "--profile", "-p",
        type=Path,
        help="Path to YAML profile file (tools/profiles/aggressive.yaml)"
    )
    parser.add_argument(
        "--contracts",
        type=str,
        help="Comma-separated list of contracts to benchmark"
    )
    parser.add_argument(
        "--runs",
        type=str,
        help="Comma-separated list of optimization runs (e.g., 0,200,1000000)"
    )
    parser.add_argument(
        "--modes",
        type=str,
        default=None,  # Use profile value if not specified
        help="Comma-separated Solc modes (default, via_ir, ir_optimized)"
    )
    parser.add_argument(
        "--baseline",
        type=str,
        help="Baseline for comparison (e.g., default_200)"
    )
    parser.add_argument(
        "--output", "-o",
        type=Path,
        help="Output report file (markdown)"
    )
    parser.add_argument(
        "--json",
        type=Path,
        help="Output JSON data file"
    )
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Verbose output"
    )
    parser.add_argument(
        "--gas",
        action="store_true",
        help="Run gas benchmarks (slower, requires BenchTest contracts)"
    )
    parser.add_argument(
        "--transpiler-opt", "-O",
        type=str,
        choices=["none", "O0", "O2", "O3", "Os", "debug", "yul-o2", "native"],
        default=None,  # Use profile value if not specified
        help="Venom IR optimization level (profile default: yul-o2)"
    )
    parser.add_argument(
        "--yul-opt-level", "-Y",
        type=str,
        choices=["none", "safe", "standard", "aggressive", "maximum"],
        default=None,  # Use profile value if not specified
        help="Yul source optimizer level (profile default: aggressive)"
    )
    args = parser.parse_args()
    
    # Load configuration from profile file
    config = load_config(args.profile)
    
    # Apply CLI overrides
    if args.contracts:
        config.contracts = [c.strip() for c in args.contracts.split(",")]
    if args.runs:
        config.optimization_runs = [int(r.strip()) for r in args.runs.split(",")]
    if args.modes:
        config.solc_modes = [m.strip() for m in args.modes.split(",")]
    if args.baseline:
        config.baseline = args.baseline
    if args.output:
        config.report_file = args.output
    if args.json:
        config.json_file = args.json
    if args.verbose:
        config.verbose = True
    if args.gas:
        config.gas_enabled = True
    if args.transpiler_opt:
        config.transpiler_opt_level = args.transpiler_opt
    if args.yul_opt_level:
        config.yul_opt_level = args.yul_opt_level
    
    # Print banner
    print("=" * 60)
    print("  Yul2Venom Benchmark Tool")
    print("=" * 60)
    print(f"  Contracts: {len(config.contracts)}")
    print(f"  Venom IR Optimization: {config.transpiler_opt_level}")
    print(f"  Yul Source Optimization: {config.yul_opt_level}")
    print(f"  Solc Optimization Runs: {config.optimization_runs}")
    print(f"  Solc Modes: {config.solc_modes}")
    print(f"  Baseline: {config.baseline}")
    if config.gas_enabled:
        print("  Gas Benchmarking: Enabled")
    print("=" * 60)
    
    # Run benchmarks
    results = run_benchmarks(config)
    
    # Generate reports
    print("\n" + "=" * 60)
    print("  Generating Reports")
    print("=" * 60)
    
    report = generate_markdown_report(config, results)
    config.report_file.write_text(report)
    print(f"  Markdown report: {config.report_file}")
    
    json_data = generate_json_data(config, results)
    config.json_file.write_text(json.dumps(json_data, indent=2))
    print(f"  JSON data: {config.json_file}")
    
    # Print summary
    print("\n" + "=" * 60)
    print("  Summary")
    print("=" * 60)
    
    # Build config columns
    configs = []
    for mode in config.solc_modes:
        if mode == "ir_optimized":
            if "ir_optimized" not in configs:
                configs.append("ir_optimized")
        else:
            for runs in config.optimization_runs:
                configs.append(f"{mode}_{runs}")
    
    # Compute dynamic column widths based on data
    # Headers
    headers = ["Contract", "Transpiled"]
    for cfg in configs:
        label = f"*{cfg}" if cfg == config.baseline else cfg
        headers.append(label)
    headers.append("Delta")
    
    # Compute widths from headers first
    col_widths = [len(h) for h in headers]
    
    # Update widths from data
    for r in results:
        # Contract name
        col_widths[0] = max(col_widths[0], len(r.contract))
        
        # Transpiled size
        trans_str = format_size(r.transpiled.bytecode_size, r.transpiled.success)
        col_widths[1] = max(col_widths[1], len(trans_str))
        
        # Solc results
        for i, cfg in enumerate(configs):
            res = r.solc_results.get(cfg)
            if res and res.success:
                col_widths[2 + i] = max(col_widths[2 + i], len(str(res.bytecode_size)))
            else:
                col_widths[2 + i] = max(col_widths[2 + i], 6)  # "FAILED"
        
        # Delta
        baseline_res = r.solc_results.get(config.baseline)
        baseline_size = baseline_res.bytecode_size if baseline_res and baseline_res.success else 0
        delta_str = calculate_delta(r.transpiled.bytecode_size, baseline_size)
        col_widths[-1] = max(col_widths[-1], len(delta_str))
    
    # Add padding
    col_widths = [w + 2 for w in col_widths]
    
    # Print header
    header_parts = []
    for i, h in enumerate(headers):
        if i == 0:
            header_parts.append(f"{h:<{col_widths[i]}}")
        else:
            header_parts.append(f"{h:>{col_widths[i]}}")
    print("\n" + " ".join(header_parts))
    
    # Print separator
    total_width = sum(col_widths) + len(col_widths) - 1
    print("-" * total_width)
    print(f"  (* = baseline: {config.baseline})")
    print()
    
    # Print data rows
    for r in results:
        baseline_res = r.solc_results.get(config.baseline)
        baseline_size = baseline_res.bytecode_size if baseline_res and baseline_res.success else 0
        
        trans_str = format_size(r.transpiled.bytecode_size, r.transpiled.success)
        row_parts = [
            f"{r.contract:<{col_widths[0]}}",
            f"{trans_str:>{col_widths[1]}}",
        ]
        
        for i, cfg in enumerate(configs):
            res = r.solc_results.get(cfg)
            if res and res.success:
                row_parts.append(f"{res.bytecode_size:>{col_widths[2 + i]}}")
            else:
                row_parts.append(f"{'FAILED':>{col_widths[2 + i]}}")
        
        delta_str = calculate_delta(r.transpiled.bytecode_size, baseline_size)
        row_parts.append(f"{delta_str:>{col_widths[-1]}}")
        print(" ".join(row_parts))
    
    print("\n" + "=" * 60)
    print(f"  Report saved to: {config.report_file}")
    print("=" * 60)


if __name__ == "__main__":
    main()
