#!/usr/bin/env python3
"""
Yul2Venom Test Framework - Comprehensive transpilation testing and analysis.

USAGE:
    python3 test_framework.py --test-all          # Full dry run: transpile + test all
    python3 test_framework.py --prepare-all       # Prepare (compile Solidity to Yul)
    python3 test_framework.py --transpile-all     # Transpile all contracts
    python3 test_framework.py --analyze <vnm>     # Analyze VNM file

CONTRACT CATEGORIES:
    Each category has specific bytecode requirements for its test pattern:

    ┌─────────────┬─────────────────────┬──────────────────────────────────┐
    │ Category    │ Bytecode Type       │ Test Pattern                     │
    ├─────────────┼─────────────────────┼──────────────────────────────────┤
    │ core/       │ runtime only        │ vm.etch (direct code injection)  │
    │ bench/      │ runtime only        │ vm.etch (direct code injection)  │
    │ repro/      │ runtime only        │ vm.etch (direct code injection)  │
    │ init/       │ init + runtime      │ CREATE opcode (deployment)       │
    └─────────────┴─────────────────────┴──────────────────────────────────┘

    - Runtime only: Pure runtime bytecode for vm.etch tests
    - Init + runtime: Full init code that decodes constructor args at deploy time

FEATURES:
    1. Batch preparation (Solidity -> Yul)
    2. Smart transpilation (knows bytecode type per category)
    3. Automated Forge test execution
    4. VNM IR analysis (phi nodes, memory ops, loops)
    5. Bytecode comparison tools
"""

import subprocess
import sys
import os
import json
import argparse
import hashlib
import re
from pathlib import Path
from dataclasses import dataclass, field
from typing import List, Dict, Optional, Tuple
from datetime import datetime
from enum import Enum

# Directory constants
SCRIPT_DIR = Path(__file__).parent.absolute()
YUL2VENOM_DIR = SCRIPT_DIR.parent
CONFIGS_DIR = YUL2VENOM_DIR / "configs"
CONFIGS_BENCH_DIR = YUL2VENOM_DIR / "configs" / "bench"
CONFIGS_INIT_DIR = YUL2VENOM_DIR / "configs" / "init"
CONFIGS_REPRO_DIR = YUL2VENOM_DIR / "configs" / "repro"
OUTPUT_DIR = YUL2VENOM_DIR / "output"
DEBUG_DIR = YUL2VENOM_DIR / "debug"
FOUNDRY_DIR = YUL2VENOM_DIR / "foundry"
FOUNDRY_SRC = FOUNDRY_DIR / "src"
FOUNDRY_SRC_BENCH = FOUNDRY_DIR / "src" / "bench"
FOUNDRY_SRC_INIT = FOUNDRY_DIR / "src" / "init"
FOUNDRY_SRC_REPRO = FOUNDRY_DIR / "src" / "repro"

# Timeouts
PREPARE_TIMEOUT = 60
TRANSPILE_TIMEOUT = 120
FORGE_TEST_TIMEOUT = 300


class BytecodeType(Enum):
    """Bytecode output type for transpilation."""
    RUNTIME_ONLY = "runtime"   # Pure runtime for vm.etch tests
    WITH_INIT = "init"         # Full init+runtime for CREATE deployment


@dataclass
class TranspileResult:
    """Result of a single transpilation attempt."""
    config_path: str
    success: bool
    bytecode_size: int = 0
    error_message: str = ""
    duration_ms: float = 0
    bytecode_hash: str = ""
    
    def to_dict(self):
        return {
            "config": self.config_path,
            "success": self.success,
            "size": self.bytecode_size,
            "error": self.error_message,
            "duration_ms": self.duration_ms,
            "hash": self.bytecode_hash
        }


@dataclass
class VenomAnalysis:
    """Analysis of a Venom IR file."""
    path: str
    num_blocks: int = 0
    num_phi_nodes: int = 0
    num_mstore: int = 0
    num_mload: int = 0
    num_loops: int = 0
    identity_ops: List[str] = field(default_factory=list)
    phi_details: List[str] = field(default_factory=list)
    
    def to_dict(self):
        return {
            "path": self.path,
            "blocks": self.num_blocks,
            "phi_nodes": self.num_phi_nodes,
            "mstore": self.num_mstore,
            "mload": self.num_mload,
            "loops": self.num_loops,
            "identity_ops": self.identity_ops,
            "phi_details": self.phi_details
        }


def get_bytecode_type(config_path: str) -> BytecodeType:
    """Determine the required bytecode type based on config directory.
    
    - configs/init/* -> WITH_INIT (needs full init code for CREATE deployment)
    - configs/* (core, bench, repro) -> RUNTIME_ONLY (for vm.etch tests)
    """
    path = Path(config_path)
    if "init" in path.parts:
        return BytecodeType.WITH_INIT
    return BytecodeType.RUNTIME_ONLY


def get_category(config_path: str) -> str:
    """Get the category name for a config (core, bench, init, repro)."""
    path = Path(config_path)
    if "bench" in path.parts:
        return "bench"
    if "init" in path.parts:
        return "init"
    if "repro" in path.parts:
        return "repro"
    return "core"


def run_command(cmd: List[str], cwd: str = None, timeout: int = 60) -> Tuple[bool, str, str]:
    """Run a command and return (success, stdout, stderr)."""
    try:
        result = subprocess.run(
            cmd, 
            capture_output=True, 
            text=True, 
            cwd=cwd,
            timeout=timeout
        )
        return result.returncode == 0, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return False, "", "Command timed out"
    except Exception as e:
        return False, "", str(e)


def discover_contracts() -> Dict[str, Tuple[Path, Path]]:
    """Discover all Solidity contracts from foundry/src/ directories.
    
    Returns dict: config_path -> (solidity_path, yul_path)
    This works even when configs don't exist yet.
    """
    mapping = {}
    
    # Core contracts (foundry/src/*.sol -> configs/*.yul2venom.json)
    for sol in FOUNDRY_SRC.glob("*.sol"):
        name = sol.stem
        config_path = CONFIGS_DIR / f"{name}.yul2venom.json"
        yul_path = OUTPUT_DIR / f"{name}.yul"
        mapping[str(config_path)] = (sol, yul_path)
    
    # Bench contracts (foundry/src/bench/*.sol -> configs/bench/*.yul2venom.json)
    if FOUNDRY_SRC_BENCH.exists():
        for sol in FOUNDRY_SRC_BENCH.glob("*.sol"):
            name = sol.stem
            config_path = CONFIGS_BENCH_DIR / f"{name}.yul2venom.json"
            yul_path = OUTPUT_DIR / f"{name}.yul"
            mapping[str(config_path)] = (sol, yul_path)
    
    # Init contracts (foundry/src/init/*.sol -> configs/init/*.yul2venom.json)
    if FOUNDRY_SRC_INIT.exists():
        for sol in FOUNDRY_SRC_INIT.glob("*.sol"):
            name = sol.stem
            config_path = CONFIGS_INIT_DIR / f"{name}.yul2venom.json"
            yul_path = OUTPUT_DIR / f"{name}.yul"
            mapping[str(config_path)] = (sol, yul_path)
    
    # Repro contracts (foundry/src/repro/*.sol -> configs/repro/*.yul2venom.json)
    if FOUNDRY_SRC_REPRO.exists():
        for sol in FOUNDRY_SRC_REPRO.glob("*.sol"):
            name = sol.stem
            config_path = CONFIGS_REPRO_DIR / f"{name}.yul2venom.json"
            yul_path = OUTPUT_DIR / f"{name}.yul"
            mapping[str(config_path)] = (sol, yul_path)
    
    return mapping


def get_config_contract_mapping() -> Dict[str, Tuple[Path, Path]]:
    """Get mapping of existing config files to their Solidity sources.
    
    Returns dict: config_path -> (solidity_path, yul_path)
    Only returns configs that already exist.
    """
    all_contracts = discover_contracts()
    # Filter to only configs that exist
    return {k: v for k, v in all_contracts.items() if Path(k).exists()}


def prepare_contract(config_path: str, sol_path: Path) -> Tuple[bool, str]:
    """Prepare a contract (compile Solidity to Yul)."""
    cmd = ["python3.11", "yul2venom.py", "prepare", str(sol_path), "-c", config_path]
    success, stdout, stderr = run_command(cmd, cwd=str(YUL2VENOM_DIR), timeout=PREPARE_TIMEOUT)
    
    if not success:
        error = stderr.strip() or stdout.strip()
        return False, error[:200]
    
    return True, ""


def transpile_contract(config_path: str, runtime_only: bool = False, with_init: bool = False) -> TranspileResult:
    """Transpile a single contract and return results.
    
    Args:
        config_path: Path to the .yul2venom.json config file
        runtime_only: If True, generate runtime-only bytecode (for vm.etch tests)
        with_init: If True, generate full init+runtime bytecode (for deployment)
    """
    import time
    start = time.time()
    
    cmd = ["python3.11", "yul2venom.py", "transpile", config_path, "-O", "O2"]
    if runtime_only:
        cmd.append("--runtime-only")
    if with_init:
        cmd.append("--with-init")
    success, stdout, stderr = run_command(cmd, cwd=str(YUL2VENOM_DIR), timeout=TRANSPILE_TIMEOUT)
    
    duration = (time.time() - start) * 1000
    
    result = TranspileResult(
        config_path=config_path,
        success=success,
        duration_ms=duration
    )
    
    if success:
        # Extract bytecode info from output
        for line in stdout.split('\n'):
            if 'Size:' in line and 'bytes' in line:
                try:
                    size = int(re.search(r'(\d+)\s*bytes', line).group(1))
                    result.bytecode_size = size
                except:
                    pass
        
        # Try to compute bytecode hash
        config = Path(config_path)
        # Determine output path based on config location
        if "bench" in str(config):
            name = config.stem.replace('.yul2venom', '')
            bin_path = OUTPUT_DIR / 'bench' / f'{name}_opt.bin'
        else:
            name = config.stem.replace('.yul2venom', '')
            bin_path = OUTPUT_DIR / f'{name}_opt.bin'
        
        if bin_path.exists():
            with open(bin_path, 'rb') as f:
                result.bytecode_hash = hashlib.md5(f.read()).hexdigest()[:8]
    else:
        # Extract error message
        combined = stdout + stderr
        for line in combined.split('\n'):
            if 'Error' in line or 'error' in line or 'Failed' in line or 'Assertion' in line:
                result.error_message = line.strip()[:100]
                break
        if not result.error_message:
            result.error_message = combined[-200:].strip()
    
    return result


def check_yul_exists(config_path: str) -> bool:
    """Check if Yul file exists for a config."""
    try:
        with open(config_path, 'r') as f:
            config = json.load(f)
        yul_path = YUL2VENOM_DIR / config.get('yul', '')
        return yul_path.exists()
    except:
        return False


def analyze_venom(vnm_path: str) -> VenomAnalysis:
    """Analyze a Venom IR file."""
    analysis = VenomAnalysis(path=vnm_path)
    
    if not os.path.exists(vnm_path):
        return analysis
    
    with open(vnm_path, 'r') as f:
        content = f.read()
    
    # Count blocks (lines that look like labels)
    for line in content.split('\n'):
        stripped = line.strip()
        if stripped.endswith(':') and not stripped.startswith('%'):
            analysis.num_blocks += 1
    
    # Count phi nodes
    phi_matches = re.findall(r'(%.* = phi .*)', content)
    analysis.num_phi_nodes = len(phi_matches)
    analysis.phi_details = phi_matches[:20]  # First 20
    
    # Count memory operations  
    analysis.num_mstore = content.count('mstore ')
    analysis.num_mload = content.count('mload ')
    
    # Count loops
    analysis.num_loops = content.count('_loop_')
    
    # Find identity operations (add X, 0)
    identity_pattern = re.compile(r'(%\S+ = add %\S+, 0)')
    analysis.identity_ops = identity_pattern.findall(content)
    
    return analysis


def prepare_all(verbose: bool = True) -> List[Tuple[str, bool, str]]:
    """Prepare all contracts (Solidity -> Yul).
    
    Uses discover_contracts() to find Sol files directly, allowing
    preparation even when configs don't exist yet.
    """
    mapping = discover_contracts()
    
    if verbose:
        print(f"Found {len(mapping)} contracts to prepare")
        print("=" * 60)
    
    results = []
    
    for config_path, (sol_path, yul_path) in sorted(mapping.items()):
        name = Path(config_path).stem.replace('.yul2venom', '')
        if verbose:
            print(f"  {name:30s} ... ", end='', flush=True)
        
        success, error = prepare_contract(config_path, sol_path)
        results.append((config_path, success, error))
        
        if verbose:
            if success:
                print("✓")
            else:
                print(f"✗ {error[:50]}")
    
    if verbose:
        passed = sum(1 for _, s, _ in results if s)
        print("=" * 60)
        print(f"Prepared: {passed}/{len(results)}")
    
    return results


def transpile_all(runtime_only: bool = False, include_bench: bool = True, include_init: bool = True) -> List[TranspileResult]:
    """Transpile all contracts and return results.
    
    Args:
        runtime_only: If True, passes --runtime-only to all core and bench contracts
                      (used for vm.etch tests that need runtime bytecode only).
                      Does NOT apply to init contracts which always use --with-init.
        include_bench: If True, include bench contracts from configs/bench/
        include_init: If True, include init contracts from configs/init/ (uses --with-init flag)
    """
    results = []
    
    # Collect core of configs
    configs = list(CONFIGS_DIR.glob('*.yul2venom.json'))
    if include_bench and CONFIGS_BENCH_DIR.exists():
        configs.extend(CONFIGS_BENCH_DIR.glob('*.yul2venom.json'))
    # Always include repro configs (they use runtime-only like bench)
    if CONFIGS_REPRO_DIR.exists():
        configs.extend(CONFIGS_REPRO_DIR.glob('*.yul2venom.json'))
    
    # Collect init configs separately (need special handling with --with-init)
    init_configs = []
    if include_init and CONFIGS_INIT_DIR.exists():
        init_configs = list(CONFIGS_INIT_DIR.glob('*.yul2venom.json'))
    
    total_configs = len(configs) + len(init_configs)
    print(f"Found {total_configs} configs to transpile ({len(configs)} core/bench, {len(init_configs)} init)")
    print("=" * 60)
    
    passed = 0
    failed = 0
    
    # Transpile core and bench configs
    for config in sorted(configs):
        name = config.stem.replace('.yul2venom', '')
        
        # Check if Yul exists
        if not check_yul_exists(str(config)):
            print(f"  {name:30s} ... ✗ Yul file not found")
            failed += 1
            results.append(TranspileResult(
                config_path=str(config),
                success=False,
                error_message="Yul file not found"
            ))
            continue
        
        print(f"  {name:30s} ... ", end='', flush=True)
        
        result = transpile_contract(str(config), runtime_only=runtime_only)
        results.append(result)
        
        if result.success:
            passed += 1
            print(f"✓ {result.bytecode_size} bytes ({result.duration_ms:.0f}ms)")
        else:
            failed += 1
            print(f"✗ {result.error_message[:50]}")
    
    # Transpile init configs with --with-init flag
    for config in sorted(init_configs):
        name = config.stem.replace('.yul2venom', '')
        
        if not check_yul_exists(str(config)):
            print(f"  {name:30s} ... ✗ Yul file not found")
            failed += 1
            results.append(TranspileResult(
                config_path=str(config),
                success=False,
                error_message="Yul file not found"
            ))
            continue
        
        print(f"  {name:30s} ... ", end='', flush=True)
        
        # Init contracts use --with-init, not runtime_only
        result = transpile_contract(str(config), with_init=True)
        results.append(result)
        
        if result.success:
            passed += 1
            print(f"✓ {result.bytecode_size} bytes ({result.duration_ms:.0f}ms)")
        else:
            failed += 1
            print(f"✗ {result.error_message[:50]}")
    
    print("=" * 60)
    print(f"Results: {passed} passed, {failed} failed, {len(results)} total")
    
    # Save results
    DEBUG_DIR.mkdir(exist_ok=True)
    results_path = DEBUG_DIR / 'transpile_results.json'
    with open(results_path, 'w') as f:
        json.dump([r.to_dict() for r in results], f, indent=2)
    print(f"Results saved to {results_path}")
    
    return results


def transpile_for_testing() -> List[TranspileResult]:
    """Transpile ALL contracts with correct bytecode types for testing.
    
    This is the canonical way to prepare all contracts for Forge tests.
    Each category gets the correct bytecode type:
    
    - init/  -> --with-init (full init code for CREATE deployment)
    - all others -> default (generates both _opt.bin and _opt_runtime.bin)
    
    Tests need BOTH files: _opt.bin (for CREATE) and _opt_runtime.bin (for vm.etch)
    
    Returns list of all transpilation results.
    """
    results = []
    
    # Collect ALL configs from all directories
    all_configs = []
    
    # Core configs
    for config in CONFIGS_DIR.glob('*.yul2venom.json'):
        all_configs.append(('core', config))
    
    # Bench configs
    if CONFIGS_BENCH_DIR.exists():
        for config in CONFIGS_BENCH_DIR.glob('*.yul2venom.json'):
            all_configs.append(('bench', config))
    
    # Repro configs
    if CONFIGS_REPRO_DIR.exists():
        for config in CONFIGS_REPRO_DIR.glob('*.yul2venom.json'):
            all_configs.append(('repro', config))
    
    # Init configs
    if CONFIGS_INIT_DIR.exists():
        for config in CONFIGS_INIT_DIR.glob('*.yul2venom.json'):
            all_configs.append(('init', config))
    
    # Group by category for display
    categories = {}
    for cat, config in all_configs:
        if cat not in categories:
            categories[cat] = []
        categories[cat].append(config)
    
    total = len(all_configs)
    print(f"Transpiling {total} contracts for testing")
    print(f"  • core:  {len(categories.get('core', []))} contracts (runtime only)")
    print(f"  • bench: {len(categories.get('bench', []))} contracts (runtime only)")
    print(f"  • repro: {len(categories.get('repro', []))} contracts (runtime only)")
    print(f"  • init:  {len(categories.get('init', []))} contracts (init + runtime)")
    print("=" * 60)
    
    passed = 0
    failed = 0
    
    # Transpile each config with correct bytecode type
    for category, config in sorted(all_configs, key=lambda x: (x[0], x[1].stem)):
        name = config.stem.replace('.yul2venom', '')
        bytecode_type = get_bytecode_type(str(config))
        
        if not check_yul_exists(str(config)):
            print(f"  [{category:5s}] {name:30s} ... ✗ Yul not found")
            failed += 1
            results.append(TranspileResult(
                config_path=str(config),
                success=False,
                error_message="Yul file not found"
            ))
            continue
        
        print(f"  [{category:5s}] {name:30s} ... ", end='', flush=True)
        
        # Transpilation strategy:
        # - init/  -> --with-init (full init code for CREATE deployment)
        # - all others -> default (generates both _opt.bin and _opt_runtime.bin)
        # Tests need both files: _opt.bin (for CREATE) and _opt_runtime.bin (for vm.etch)
        if bytecode_type == BytecodeType.WITH_INIT:
            result = transpile_contract(str(config), with_init=True)
            type_label = "init"
        else:
            # Default mode generates both _opt.bin and _opt_runtime.bin
            result = transpile_contract(str(config))
            type_label = "both"
        
        results.append(result)
        
        if result.success:
            passed += 1
            print(f"✓ {result.bytecode_size} bytes [{type_label}] ({result.duration_ms:.0f}ms)")
        else:
            failed += 1
            print(f"✗ {result.error_message[:40]}")
    
    print("=" * 60)
    print(f"Results: {passed} passed, {failed} failed, {len(results)} total")
    
    # Save results
    DEBUG_DIR.mkdir(exist_ok=True)
    results_path = DEBUG_DIR / 'transpile_results.json'
    with open(results_path, 'w') as f:
        json.dump([r.to_dict() for r in results], f, indent=2)
    print(f"Results saved to {results_path}")
    
    return results


def run_forge_tests(test_pattern: str = None, verbose: bool = True) -> Tuple[bool, str, int, int]:
    """Run Forge tests and return (success, output, passed, failed)."""
    if verbose:
        print("Running Forge tests...")
    
    # Default: run all tests
    if test_pattern is None:
        cmd = ["forge", "test", "-v"]
    elif test_pattern == "core":
        # Core tests are in test/*.t.sol (not in subdirectories)
        # Exclude bench/, init/, repro/ subdirectories
        cmd = ["forge", "test", "--match-path", "test/*.t.sol", "-v"]
    elif test_pattern == "bench":
        cmd = ["forge", "test", "--match-path", "test/bench/*", "-v"]
    else:
        cmd = ["forge", "test", "--match-path", test_pattern, "-v"]
    
    # Run from foundry directory
    success, stdout, stderr = run_command(cmd, cwd=str(FOUNDRY_DIR), timeout=FORGE_TEST_TIMEOUT)
    
    # Parse results
    passed = 0
    failed = 0
    
    combined = stdout + stderr
    for line in combined.split('\n'):
        if 'passed' in line.lower() and 'failed' in line.lower():
            match = re.search(r'(\d+)\s+tests?\s+passed.*?(\d+)\s+failed', line)
            if match:
                passed = int(match.group(1))
                failed = int(match.group(2))
    
    if verbose:
        print(f"Test Results: {passed} passed, {failed} failed")
    
    return success, combined, passed, failed


def compare_vnm_files(path_a: str, path_b: str):
    """Compare two VNM files and show differences."""
    analysis_a = analyze_venom(path_a)
    analysis_b = analyze_venom(path_b)
    
    print(f"Comparing:")
    print(f"  A: {path_a}")
    print(f"  B: {path_b}")
    print("=" * 60)
    
    print(f"{'Metric':25s} {'A':>10s} {'B':>10s} {'Diff':>10s}")
    print("-" * 60)
    
    metrics = [
        ('Blocks', analysis_a.num_blocks, analysis_b.num_blocks),
        ('Phi Nodes', analysis_a.num_phi_nodes, analysis_b.num_phi_nodes),
        ('mstore', analysis_a.num_mstore, analysis_b.num_mstore),
        ('mload', analysis_a.num_mload, analysis_b.num_mload),
        ('Loops', analysis_a.num_loops, analysis_b.num_loops),
        ('Identity Ops', len(analysis_a.identity_ops), len(analysis_b.identity_ops)),
    ]
    
    for name, val_a, val_b in metrics:
        diff = val_b - val_a
        diff_str = f"+{diff}" if diff > 0 else str(diff) if diff < 0 else "-"
        print(f"{name:25s} {val_a:>10d} {val_b:>10d} {diff_str:>10s}")


def full_pipeline_test(include_bench: bool = True):
    """Run the full testing pipeline."""
    print("=" * 60)
    print("YUL2VENOM FULL PIPELINE TEST")
    print(f"Timestamp: {datetime.now().isoformat()}")
    print("=" * 60)
    
    # 1. Prepare all
    print("\n[STEP 1] Preparing all contracts (Solidity -> Yul)...")
    prepare_results = prepare_all()
    prepare_pass = sum(1 for _, s, _ in prepare_results if s)
    
    # 2. Transpile all
    print("\n[STEP 2] Transpiling all contracts (Yul -> Bytecode)...")
    transpile_results = transpile_all(include_bench=include_bench)
    transpile_pass = sum(1 for r in transpile_results if r.success)
    
    # 3. Run Forge tests
    print("\n[STEP 3] Running Forge tests...")
    
    # Core tests (need full bytecode with init code)
    print("  [3a] Core tests...")
    core_success, core_output, core_passed, core_failed = run_forge_tests("core", verbose=False)
    print(f"       {core_passed} passed, {core_failed} failed")
    
    # Bench tests (use runtime-only via vm.etch)
    bench_passed = 0
    bench_failed = 0
    if include_bench:
        # Re-transpile bench with runtime-only for vm.etch tests
        print("  [3b] Re-transpiling bench contracts with --runtime-only...")
        for config in CONFIGS_BENCH_DIR.glob('*.yul2venom.json'):
            if check_yul_exists(str(config)):
                transpile_contract(str(config), runtime_only=True)
        
        print("  [3c] Bench tests...")
        bench_success, bench_output, bench_passed, bench_failed = run_forge_tests("bench", verbose=False)
        print(f"       {bench_passed} passed, {bench_failed} failed")
    
    # 4. Summary
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    
    total_tests_passed = core_passed + bench_passed
    total_tests_failed = core_failed + bench_failed
    
    print(f"Preparation:   {prepare_pass}/{len(prepare_results)}")
    print(f"Transpilation: {transpile_pass}/{len(transpile_results)}")
    print(f"Core Tests:    {core_passed}/{core_passed + core_failed}")
    if include_bench:
        print(f"Bench Tests:   {bench_passed}/{bench_passed + bench_failed}")
    print(f"Total Tests:   {total_tests_passed}/{total_tests_passed + total_tests_failed}")
    
    # Show failures
    failed_items = []
    for _, s, e in prepare_results:
        if not s:
            failed_items.append(("Prepare", e))
    for r in transpile_results:
        if not r.success:
            name = Path(r.config_path).stem.replace('.yul2venom', '')
            failed_items.append(("Transpile", f"{name}: {r.error_message[:50]}"))
    
    if failed_items:
        print(f"\nFailures ({len(failed_items)}):")
        for category, msg in failed_items[:10]:
            print(f"  [{category}] {msg}")
        if len(failed_items) > 10:
            print(f"  ... and {len(failed_items) - 10} more")
    
    all_passed = (
        prepare_pass == len(prepare_results) and
        transpile_pass == len(transpile_results) and
        total_tests_failed == 0
    )
    
    print("\n" + ("✓ ALL PASSED" if all_passed else "✗ SOME FAILURES"))
    return all_passed


def transpile_init_all() -> List[TranspileResult]:
    """Transpile all init contracts with --with-init flag.
    
    Init contracts require full init bytecode (not runtime-only) for deployment testing.
    """
    results = []
    
    if not CONFIGS_INIT_DIR.exists():
        print("No init configs found")
        return results
    
    configs = list(CONFIGS_INIT_DIR.glob('*.yul2venom.json'))
    
    print(f"Found {len(configs)} init configs to transpile")
    print("=" * 60)
    
    passed = 0
    failed = 0
    
    for config in sorted(configs):
        name = config.stem.replace('.yul2venom', '')
        
        # Check if Yul exists
        if not check_yul_exists(str(config)):
            print(f"  {name:30s} ... ✗ Yul file not found")
            failed += 1
            results.append(TranspileResult(
                config_path=str(config),
                success=False,
                error_message="Yul file not found"
            ))
            continue
        
        print(f"  {name:30s} ... ", end='', flush=True)
        
        result = transpile_contract(str(config), with_init=True)
        results.append(result)
        
        if result.success:
            passed += 1
            print(f"✓ {result.bytecode_size} bytes ({result.duration_ms:.0f}ms)")
        else:
            failed += 1
            print(f"✗ {result.error_message[:50]}")
    
    print("=" * 60)
    print(f"Init Results: {passed} passed, {failed} failed, {len(results)} total")
    
    return results


def main():

    parser = argparse.ArgumentParser(description="Yul2Venom Test Framework")
    parser.add_argument("--prepare-all", action="store_true", help="Prepare all contracts (Solidity -> Yul)")
    parser.add_argument("--transpile-all", action="store_true", help="Transpile all contracts")
    parser.add_argument("--init-all", action="store_true", help="Transpile all init contracts with --with-init")
    parser.add_argument("--test-all", action="store_true", help="Run all Forge tests")
    parser.add_argument("--test-core", action="store_true", help="Run core Forge tests only")
    parser.add_argument("--test-bench", action="store_true", help="Run bench Forge tests only")
    parser.add_argument("--test-init", action="store_true", help="Run init Forge tests (InitEdgeCasesTestRunner)")
    parser.add_argument("--analyze", type=str, help="Analyze VNM file")
    parser.add_argument("--compare", nargs=2, metavar=('A', 'B'), help="Compare two VNM files")
    parser.add_argument("--full", action="store_true", help="Full pipeline test")
    parser.add_argument("--json", action="store_true", help="Output JSON format")
    parser.add_argument("--runtime-only", action="store_true", help="Generate runtime-only bytecode")
    parser.add_argument("--no-bench", action="store_true", help="Exclude bench tests")

    
    args = parser.parse_args()
    
    if args.prepare_all:
        prepare_all()
    
    elif args.transpile_all:
        results = transpile_all(runtime_only=args.runtime_only, include_bench=not args.no_bench)
        if args.json:
            print(json.dumps([r.to_dict() for r in results], indent=2))
    
    elif args.init_all:
        # Transpile all init contracts with --with-init flag
        results = transpile_init_all()
        if args.json:
            print(json.dumps([r.to_dict() for r in results], indent=2))
    
    elif args.test_all:
        # Full dry run: transpile all contracts with correct bytecode types, then test
        transpile_for_testing()
        success, output, passed, failed = run_forge_tests()
        sys.exit(0 if success else 1)
    
    elif args.test_core:
        success, output, passed, failed = run_forge_tests("core")
        sys.exit(0 if success else 1)
    
    elif args.test_bench:
        success, output, passed, failed = run_forge_tests("bench")
        sys.exit(0 if success else 1)
    
    elif args.test_init:
        # Transpile init contracts first, then run init tests
        print("Transpiling init contracts with --with-init...")
        transpile_init_all()
        success, output, passed, failed = run_forge_tests("test/init/*")
        sys.exit(0 if success else 1)

    
    elif args.analyze:
        analysis = analyze_venom(args.analyze)
        if args.json:
            print(json.dumps(analysis.to_dict(), indent=2))
        else:
            print(f"Analysis of {args.analyze}")
            print("=" * 40)
            print(f"Blocks: {analysis.num_blocks}")
            print(f"Phi Nodes: {analysis.num_phi_nodes}")
            print(f"mstore: {analysis.num_mstore}")
            print(f"mload: {analysis.num_mload}")
            print(f"Loops: {analysis.num_loops}")
            print(f"Identity Ops: {len(analysis.identity_ops)}")
            if analysis.identity_ops:
                print("\nIdentity Operations:")
                for op in analysis.identity_ops[:10]:
                    print(f"  {op}")
            if analysis.phi_details:
                print("\nPhi Nodes:")
                for phi in analysis.phi_details[:10]:
                    print(f"  {phi}")
    
    elif args.compare:
        compare_vnm_files(args.compare[0], args.compare[1])
    
    elif args.full:
        success = full_pipeline_test(include_bench=not args.no_bench)
        sys.exit(0 if success else 1)
    
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
