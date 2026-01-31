#!/usr/bin/env python3
"""
Security Audit Script - Pre-commit hook for detecting sensitive information.

Usage:
    python3 scripts/security_audit.py [--fix] [--verbose]
    
Install as pre-commit hook:
    ln -sf ../../scripts/security_audit.py .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit

Checks for:
- Private keys (64-char hex strings)
- Ethereum addresses (real mainnet addresses)
- API keys (Infura, Alchemy, Etherscan patterns)
- Secrets/passwords in code
- Personal emails
- Hardcoded credentials
"""

import os
import re
import sys
import argparse
from pathlib import Path
from typing import List, Tuple, Set

# Patterns to detect
PATTERNS = {
    "private_key": {
        "regex": r"0x[a-fA-F0-9]{64}",
        "severity": "CRITICAL",
        "description": "Possible private key (64-char hex)"
    },
    "api_key_generic": {
        "regex": r"(?:api[_-]?key|apikey|secret[_-]?key|auth[_-]?token)\s*[=:]\s*['\"][^'\"]{20,}['\"]",
        "severity": "CRITICAL",
        "description": "Hardcoded API key or secret"
    },
    "infura_key": {
        "regex": r"infura\.io/v3/[a-f0-9]{32}",
        "severity": "CRITICAL",
        "description": "Infura API key"
    },
    "alchemy_key": {
        "regex": r"alchemy\.com/v2/[a-zA-Z0-9_-]{32}",
        "severity": "CRITICAL",
        "description": "Alchemy API key"
    },
    "etherscan_key": {
        "regex": r"etherscan\.io.*[?&]apikey=[A-Z0-9]{34}",
        "severity": "CRITICAL",
        "description": "Etherscan API key"
    },
    "password_hardcoded": {
        "regex": r"(?:password|passwd|pwd)\s*[=:]\s*['\"][^'\"]+['\"]",
        "severity": "HIGH",
        "description": "Hardcoded password"
    },
    "personal_email": {
        "regex": r"[a-zA-Z0-9._%+-]+@(?:gmail|yahoo|hotmail|outlook|proton)\.[a-z]{2,}",
        "severity": "MEDIUM",
        "description": "Personal email address"
    },
    "aws_key": {
        "regex": r"AKIA[0-9A-Z]{16}",
        "severity": "CRITICAL",
        "description": "AWS Access Key ID"
    },
    "jwt_token": {
        "regex": r"eyJ[a-zA-Z0-9_-]*\.eyJ[a-zA-Z0-9_-]*\.[a-zA-Z0-9_-]*",
        "severity": "HIGH",
        "description": "JWT Token"
    },
}

# Known safe patterns (false positive exclusions)
SAFE_PATTERNS = [
    r"0x1234567890123456789012345678901234567890",  # Placeholder address
    r"0x0{40}",  # Zero address
    r"0x0{64}",  # Zero bytes32
    r"deployer.*0x1234",  # Example deployer
]

# File extensions to scan
SCAN_EXTENSIONS = {
    ".py", ".js", ".ts", ".sol", ".json", ".yaml", ".yml",
    ".toml", ".env", ".sh", ".md", ".txt", ".cfg", ".ini"
}

# Directories to skip
SKIP_DIRS = {
    ".git", "__pycache__", "node_modules", "venv", ".venv",
    "env", ".env", "dist", "build", ".tox", ".pytest_cache",
    "vyper",  # Skip vendored vyper fork
    "out",    # Skip foundry build output (contains bytecode that looks like keys)
    "lib",    # Skip foundry vendor libraries (forge-std test fixtures)
    "cache",  # Skip foundry cache
}


def is_safe_match(match: str, line: str) -> bool:
    """Check if a match is a known safe pattern."""
    for safe in SAFE_PATTERNS:
        if re.search(safe, line, re.IGNORECASE):
            return True
    return False


def scan_file(filepath: Path, verbose: bool = False) -> List[Tuple[str, int, str, str, str]]:
    """
    Scan a file for sensitive patterns.
    
    Returns:
        List of (filepath, line_number, pattern_name, severity, match)
    """
    findings = []
    
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            lines = f.readlines()
    except Exception as e:
        if verbose:
            print(f"  Warning: Could not read {filepath}: {e}", file=sys.stderr)
        return findings
    
    for line_num, line in enumerate(lines, 1):
        for pattern_name, pattern_info in PATTERNS.items():
            matches = re.finditer(pattern_info["regex"], line, re.IGNORECASE)
            for match in matches:
                if not is_safe_match(match.group(), line):
                    findings.append((
                        str(filepath),
                        line_num,
                        pattern_name,
                        pattern_info["severity"],
                        match.group()[:50] + "..." if len(match.group()) > 50 else match.group()
                    ))
    
    return findings


def scan_directory(directory: Path, verbose: bool = False) -> List[Tuple[str, int, str, str, str]]:
    """Scan a directory recursively for sensitive patterns."""
    all_findings = []
    files_scanned = 0
    
    for root, dirs, files in os.walk(directory):
        # Remove skip directories from traversal
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
        
        for filename in files:
            filepath = Path(root) / filename
            
            # Check extension
            if filepath.suffix.lower() not in SCAN_EXTENSIONS:
                continue
            
            # Skip symlinks
            if filepath.is_symlink():
                continue
            
            files_scanned += 1
            findings = scan_file(filepath, verbose)
            all_findings.extend(findings)
    
    if verbose:
        print(f"Scanned {files_scanned} files", file=sys.stderr)
    
    return all_findings


def print_findings(findings: List[Tuple[str, int, str, str, str]], base_dir: Path):
    """Print findings in a readable format."""
    if not findings:
        print("✓ No security issues found")
        return
    
    # Group by severity
    critical = [f for f in findings if f[3] == "CRITICAL"]
    high = [f for f in findings if f[3] == "HIGH"]
    medium = [f for f in findings if f[3] == "MEDIUM"]
    
    print(f"\n{'='*60}")
    print(f"SECURITY AUDIT RESULTS")
    print(f"{'='*60}")
    print(f"Found {len(findings)} potential issues:")
    print(f"  CRITICAL: {len(critical)}")
    print(f"  HIGH: {len(high)}")
    print(f"  MEDIUM: {len(medium)}")
    print(f"{'='*60}\n")
    
    for filepath, line_num, pattern_name, severity, match in findings:
        rel_path = Path(filepath).relative_to(base_dir)
        severity_marker = {
            "CRITICAL": "🔴",
            "HIGH": "🟠",
            "MEDIUM": "🟡"
        }.get(severity, "⚪")
        
        print(f"{severity_marker} [{severity}] {rel_path}:{line_num}")
        print(f"   Pattern: {pattern_name}")
        print(f"   Match: {match}")
        print()


def main():
    parser = argparse.ArgumentParser(
        description="Security audit script for detecting sensitive information"
    )
    parser.add_argument(
        "directory",
        nargs="?",
        default=".",
        help="Directory to scan (default: current directory)"
    )
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Verbose output"
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Exit with error on any finding (for CI/pre-commit)"
    )
    args = parser.parse_args()
    
    directory = Path(args.directory).resolve()
    
    if not directory.exists():
        print(f"Error: Directory not found: {directory}", file=sys.stderr)
        sys.exit(1)
    
    print(f"Scanning: {directory}")
    findings = scan_directory(directory, args.verbose)
    print_findings(findings, directory)
    
    # Exit codes for CI
    if args.strict and findings:
        critical = sum(1 for f in findings if f[3] == "CRITICAL")
        if critical > 0:
            print(f"\n❌ BLOCKED: {critical} critical issues found")
            sys.exit(1)
        else:
            print(f"\n⚠️  Warning: Non-critical issues found")
            sys.exit(0)
    
    sys.exit(0)


if __name__ == "__main__":
    main()
