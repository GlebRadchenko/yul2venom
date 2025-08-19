#!/usr/bin/env python3
"""
Solc compiler wrapper for compiling Solidity contracts to Yul.
"""

import json
import subprocess
import tempfile
from pathlib import Path
from typing import Dict, Optional, Tuple


class SolcCompiler:
    """Wrapper for solc to compile Solidity contracts to Yul."""
    
    def __init__(self, solc_path: str = "solc"):
        """
        Initialize the SolcCompiler.
        
        Args:
            solc_path: Path to solc binary (default: "solc" in PATH)
        """
        self.solc_path = solc_path
        self._verify_solc()
    
    def _verify_solc(self):
        """Verify that solc is available and get version."""
        try:
            result = subprocess.run(
                [self.solc_path, "--version"],
                capture_output=True,
                text=True,
                check=True
            )
            # Parse version from output
            for line in result.stdout.split('\n'):
                if 'Version:' in line:
                    self.version = line.split('Version:')[1].strip()
                    break
        except (subprocess.CalledProcessError, FileNotFoundError) as e:
            raise RuntimeError(f"solc not found or not executable: {e}")
    
    def compile_to_yul(self, solidity_file: Path, optimize: bool = False) -> str:
        """
        Compile a Solidity file to Yul IR.
        
        Args:
            solidity_file: Path to the Solidity source file
            optimize: Whether to enable optimizer
        
        Returns:
            Yul IR code as string
        """
        if not solidity_file.exists():
            raise FileNotFoundError(f"Solidity file not found: {solidity_file}")
        
        cmd = [
            self.solc_path,
            "--ir",  # Output Yul IR
            "--no-color",
            str(solidity_file)
        ]
        
        if optimize:
            cmd.extend(["--optimize", "--optimize-runs", "200"])
        
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=True
            )
            
            # Extract Yul code from output
            # solc outputs the Yul after "IR:" marker
            yul_code = self._extract_yul_from_output(result.stdout)
            return yul_code
            
        except subprocess.CalledProcessError as e:
            raise RuntimeError(f"Compilation failed: {e.stderr}")
    
    def compile_to_bytecode(self, solidity_file: Path, optimize: bool = False) -> Tuple[str, str]:
        """
        Compile a Solidity file to bytecode (for comparison).
        
        Args:
            solidity_file: Path to the Solidity source file
            optimize: Whether to enable optimizer
        
        Returns:
            Tuple of (deployment_bytecode, runtime_bytecode)
        """
        if not solidity_file.exists():
            raise FileNotFoundError(f"Solidity file not found: {solidity_file}")
        
        # Get contract name from file
        contract_name = solidity_file.stem
        
        cmd = [
            self.solc_path,
            "--bin",
            "--bin-runtime",
            "--no-color",
            str(solidity_file)
        ]
        
        if optimize:
            cmd.extend(["--optimize", "--optimize-runs", "200"])
        
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                check=True
            )
            
            # Parse bytecode from output
            deployment_bytecode = ""
            runtime_bytecode = ""
            
            lines = result.stdout.split('\n')
            for i, line in enumerate(lines):
                if "Binary:" in line and i + 1 < len(lines):
                    deployment_bytecode = lines[i + 1].strip()
                elif "Binary of the runtime part:" in line and i + 1 < len(lines):
                    runtime_bytecode = lines[i + 1].strip()
            
            return deployment_bytecode, runtime_bytecode
            
        except subprocess.CalledProcessError as e:
            raise RuntimeError(f"Compilation failed: {e.stderr}")
    
    def compile_to_json(self, solidity_file: Path, optimize: bool = False) -> Dict:
        """
        Compile a Solidity file and get full JSON output.
        
        Args:
            solidity_file: Path to the Solidity source file
            optimize: Whether to enable optimizer
        
        Returns:
            JSON output from solc
        """
        if not solidity_file.exists():
            raise FileNotFoundError(f"Solidity file not found: {solidity_file}")
        
        # Prepare standard JSON input
        with open(solidity_file, 'r') as f:
            source_code = f.read()
        
        json_input = {
            "language": "Solidity",
            "sources": {
                str(solidity_file.name): {
                    "content": source_code
                }
            },
            "settings": {
                "optimizer": {
                    "enabled": optimize,
                    "runs": 200
                },
                "outputSelection": {
                    "*": {
                        "*": [
                            "abi",
                            "evm.bytecode",
                            "evm.deployedBytecode",
                            "evm.methodIdentifiers",
                            "ir",
                            "irOptimized"
                        ]
                    }
                }
            }
        }
        
        try:
            result = subprocess.run(
                [self.solc_path, "--standard-json"],
                input=json.dumps(json_input),
                capture_output=True,
                text=True,
                check=True
            )
            
            return json.loads(result.stdout)
            
        except subprocess.CalledProcessError as e:
            raise RuntimeError(f"Compilation failed: {e.stderr}")
    
    def _extract_yul_from_output(self, output: str) -> str:
        """
        Extract Yul code from solc output.
        
        Args:
            output: Raw output from solc --ir
        
        Returns:
            Extracted Yul code
        """
        # Look for the IR section
        lines = output.split('\n')
        yul_lines = []
        in_yul = False
        
        for line in lines:
            if line.strip().startswith("IR:"):
                in_yul = True
                continue
            elif in_yul:
                # Stop at the next section marker or end
                if line.startswith("Binary:") or line.startswith("======="):
                    break
                yul_lines.append(line)
        
        return '\n'.join(yul_lines).strip()
    
    def get_version(self) -> str:
        """Get the solc version."""
        return self.version


def main():
    """Test the compiler wrapper."""
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python solc_compiler.py <solidity_file>")
        sys.exit(1)
    
    compiler = SolcCompiler()
    print(f"Using solc version: {compiler.get_version()}")
    
    sol_file = Path(sys.argv[1])
    
    # Compile to Yul
    print("\n=== Compiling to Yul ===")
    yul_code = compiler.compile_to_yul(sol_file)
    print(yul_code[:500] + "..." if len(yul_code) > 500 else yul_code)
    
    # Compile to bytecode
    print("\n=== Compiling to bytecode ===")
    deploy_code, runtime_code = compiler.compile_to_bytecode(sol_file)
    print(f"Deployment bytecode: {deploy_code[:100]}...")
    print(f"Runtime bytecode: {runtime_code[:100]}...")


if __name__ == "__main__":
    main()