#!/usr/bin/env python3
"""
Yul2Venom Test Framework - Comprehensive transpilation testing and analysis.

Usage:
    python3 test_framework.py --transpile-all    # Transpile all contracts
    python3 test_framework.py --verify-all       # Run Forge tests
    python3 test_framework.py --analyze <vnm>    # Analyze VNM file
    python3 test_framework.py --compare <a> <b>  # Compare two VNM files
    python3 test_framework.py --full             # Full pipeline test

This framework provides:
1. Batch transpilation with status tracking
2. Automated Forge test execution
3. VNM IR analysis (phi nodes, memory ops, loops)
4. Bytecode comparison tools
5. Regression detection
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

# Import package constants
try:
    from . import YUL2VENOM_DIR, CONFIGS_DIR, OUTPUT_DIR, DEBUG_DIR, TRANSPILE_TIMEOUT, FORGE_TEST_TIMEOUT
except ImportError:
    # Fallback for direct execution
    SCRIPT_DIR = Path(__file__).parent.absolute()
    YUL2VENOM_DIR = SCRIPT_DIR.parent
    CONFIGS_DIR = YUL2VENOM_DIR / "configs"
    OUTPUT_DIR = YUL2VENOM_DIR / "output"
    DEBUG_DIR = YUL2VENOM_DIR / "debug"
    TRANSPILE_TIMEOUT = 120
    FORGE_TEST_TIMEOUT = 300


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


def transpile_contract(config_path: str, runtime_only: bool = False) -> TranspileResult:
    """Transpile a single contract and return results.
    
    Args:
        config_path: Path to the .yul2venom.json config file
        runtime_only: If True, generate runtime-only bytecode (no init code).
                      Default False since Forge tests need init code for deployment.
    """
    import time
    start = time.time()
    
    cmd = ["python3.11", "yul2venom.py", "transpile", config_path]
    if runtime_only:
        cmd.append("--runtime-only")
    success, stdout, stderr = run_command(cmd, cwd=str(YUL2VENOM_DIR), timeout=120)
    
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
        config_name = Path(config_path).stem.replace('.yul2venom', '')
        bin_path = YUL2VENOM_DIR / 'output' / f'{config_name}_opt.bin'
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


def analyze_venom(vnm_path: str) -> VenomAnalysis:
    """Analyze a Venom IR file."""
    analysis = VenomAnalysis(path=vnm_path)
    
    if not os.path.exists(vnm_path):
        return analysis
    
    with open(vnm_path, 'r') as f:
        content = f.read()
    
    # Count blocks (lines ending with : that aren't labels inside instructions)
    block_pattern = re.compile(r'^  \S+:.*?;', re.MULTILINE)
    analysis.num_blocks = len(block_pattern.findall(content))
    
    # Alternative: simpler block detection
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


def transpile_all() -> List[TranspileResult]:
    """Transpile all contracts and return results."""
    configs_dir = YUL2VENOM_DIR / 'configs'
    configs = list(configs_dir.glob('*.yul2venom.json'))
    
    print(f"Found {len(configs)} configs to transpile")
    print("=" * 60)
    
    results = []
    passed = 0
    failed = 0
    
    for config in sorted(configs):
        name = config.stem.replace('.yul2venom', '')
        print(f"  {name:30s} ... ", end='', flush=True)
        
        result = transpile_contract(str(config))
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
    results_dir = YUL2VENOM_DIR / 'debug'
    results_dir.mkdir(exist_ok=True)
    results_path = results_dir / 'transpile_results.json'
    with open(results_path, 'w') as f:
        json.dump([r.to_dict() for r in results], f, indent=2)
    print(f"Results saved to {results_path}")
    
    return results


def run_forge_tests(test_pattern: str = "test/yul2venom/*") -> Tuple[bool, str]:
    """Run Forge tests and return results."""
    print("Running Forge tests...")
    cmd = ["forge", "test", "--match-path", test_pattern, "-v"]
    success, stdout, stderr = run_command(cmd, cwd=str(YUL2VENOM_DIR.parent), timeout=300)
    
    # Parse results
    total = 0
    passed = 0
    failed = 0
    
    for line in stdout.split('\n'):
        if 'passed' in line.lower() and 'failed' in line.lower():
            match = re.search(r'(\d+)\s+passed.*?(\d+)\s+failed', line)
            if match:
                passed = int(match.group(1))
                failed = int(match.group(2))
                total = passed + failed
    
    print(f"Test Results: {passed} passed, {failed} failed, {total} total")
    return success, stdout


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


def full_pipeline_test():
    """Run the full testing pipeline."""
    print("=" * 60)
    print("YUL2VENOM FULL PIPELINE TEST")
    print(f"Timestamp: {datetime.now().isoformat()}")
    print("=" * 60)
    
    # 1. Transpile all
    print("\n[STEP 1] Transpiling all contracts...")
    results = transpile_all()
    
    # 2. Analyze generated IR
    print("\n[STEP 2] Analyzing generated IR...")
    for result in results:
        if result.success:
            name = Path(result.config_path).stem.replace('.yul2venom', '')
            raw_ir = YUL2VENOM_DIR / 'debug' / 'raw_ir.vnm'
            if raw_ir.exists():
                analysis = analyze_venom(str(raw_ir))
                print(f"  {name}: {analysis.num_blocks} blocks, {analysis.num_phi_nodes} phis, {len(analysis.identity_ops)} identity ops")
    
    # 3. Run Forge tests
    print("\n[STEP 3] Running Forge tests...")
    test_success, test_output = run_forge_tests()
    
    # 4. Summary
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    
    transpile_pass = sum(1 for r in results if r.success)
    transpile_fail = len(results) - transpile_pass
    
    print(f"Transpilation: {transpile_pass}/{len(results)} passed")
    print(f"Tests: {'PASSED' if test_success else 'FAILED'}")
    
    if transpile_fail > 0:
        print(f"\nFailed transpilations:")
        for r in results:
            if not r.success:
                name = Path(r.config_path).stem.replace('.yul2venom', '')
                print(f"  - {name}: {r.error_message[:60]}")
    
    return transpile_pass == len(results) and test_success


def main():
    parser = argparse.ArgumentParser(description="Yul2Venom Test Framework")
    parser.add_argument("--transpile-all", action="store_true", help="Transpile all contracts")
    parser.add_argument("--verify-all", action="store_true", help="Run all Forge tests")
    parser.add_argument("--analyze", type=str, help="Analyze VNM file")
    parser.add_argument("--compare", nargs=2, metavar=('A', 'B'), help="Compare two VNM files")
    parser.add_argument("--full", action="store_true", help="Full pipeline test")
    parser.add_argument("--json", action="store_true", help="Output JSON format")
    
    args = parser.parse_args()
    
    if args.transpile_all:
        results = transpile_all()
        if args.json:
            print(json.dumps([r.to_dict() for r in results], indent=2))
    
    elif args.verify_all:
        success, output = run_forge_tests()
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
        success = full_pipeline_test()
        sys.exit(0 if success else 1)
    
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
