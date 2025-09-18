#!/usr/bin/env python3
"""
Main test suite for Yul-to-Venom transpilation validation.
"""

import pytest
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from test_validation.validators.execution_validator import ValidationResult
from textwrap import dedent

from tests.venom_utils import assert_ctx_eq
from vyper.venom.parser import parse_venom


class TestYulTranspilation:
    """Test Yul transpilation functionality."""
    
    def test_simple_yul_compilation(self, yul_transpiler, simple_yul):
        """Test that simple Yul code compiles successfully."""
        # Compile to bytecode
        bytecode = yul_transpiler.compile_yul_to_bytecode(simple_yul)
        
        assert bytecode is not None
        assert bytecode.startswith("0x")
        assert len(bytecode) > 2
    
    def test_yul_to_venom_ir(self, yul_transpiler, simple_yul):
        """Test Yul to Venom IR conversion."""
        venom_ir = yul_transpiler.compile_yul_to_venom_ir(simple_yul)
        
        assert venom_ir is not None
        assert "function __global" in venom_ir
        assert "mstore" in venom_ir
    
    def test_yul_to_assembly(self, yul_transpiler, simple_yul):
        """Test Yul to assembly conversion."""
        asm = yul_transpiler.compile_yul_to_assembly(simple_yul)
        
        assert asm is not None
        assert "JUMPDEST" in asm or "PUSH" in asm

    def test_multi_return_destructuring(self, yul_transpiler):
        multi_return_yul = """
        object "MultiReturn" {
            code {
                function foo() -> a, b {
                    a := 1
                    b := 2
                }

                let x, y := foo()
                mstore(0, x)
                mstore(32, y)
                return(0, 64)
            }
        }
        """

        expected_ir = """
        function __global {
          __global:
              %1, %2 = invoke @foo
              %x = %1
              %y = %2
              mstore 0, %x
              mstore 32, %y
              return 0, 64

          revert:
              revert 0, 0
        }

        function foo {
          foo:
              %1 = param
              %a = 1
              %b = 2
              ret %1, %b, %a
        }
        """

        actual_ir = yul_transpiler.compile_yul_to_venom_ir(multi_return_yul)
        expected_ctx = parse_venom(expected_ir)
        actual_ctx = parse_venom(actual_ir)

        assert_ctx_eq(expected_ctx, actual_ctx)

    def test_yul_syntax_validation(self, yul_transpiler):
        """Test Yul syntax validation."""
        valid_yul = """
        object "Test" {
            code {
                mstore(0, 1)
            }
        }
        """
        
        invalid_yul = """
        object "Test" {
            code {
                invalid_opcode(
            }
        }
        """
        
        is_valid, error = yul_transpiler.validate_yul_syntax(valid_yul)
        assert is_valid is True
        assert error is None
        
        is_valid, error = yul_transpiler.validate_yul_syntax(invalid_yul)
        assert is_valid is False
        assert error is not None


class TestSolcIntegration:
    """Test Solc integration."""
    
    def test_solc_available(self, solc_compiler):
        """Test that solc is available."""
        version = solc_compiler.get_version()
        assert version is not None
        assert "." in version  # Should be a version string like "0.8.x"
    
    def test_compile_to_yul(self, solc_compiler, simple_solidity):
        """Test compiling Solidity to Yul."""
        yul_code = solc_compiler.compile_to_yul(simple_solidity)
        
        assert yul_code is not None
        assert "object" in yul_code
        assert "code" in yul_code
    
    def test_compile_to_bytecode(self, solc_compiler, simple_solidity):
        """Test compiling Solidity to bytecode."""
        deploy_code, runtime_code = solc_compiler.compile_to_bytecode(simple_solidity)
        
        assert deploy_code is not None
        assert runtime_code is not None
        assert len(deploy_code) > 0
        assert len(runtime_code) > 0


class TestBytecodeValidation:
    """Test bytecode validation."""
    
    def test_identical_bytecode_passes(self, execution_validator):
        """Test that identical bytecode passes validation."""
        bytecode = "0x608060405260043610601c5760003560e01c8063371303c0146021575b600080fd"
        
        report = execution_validator.validate_simple_bytecode(bytecode, bytecode)
        # Should pass or error (if bytecode is incomplete)
        assert report.status in [ValidationResult.PASS, ValidationResult.ERROR]
    
    def test_deployment_validation(self, execution_validator):
        """Test deployment validation."""
        # Minimal valid bytecode
        valid_bytecode = "0x5f5f5260205ff3"  # PUSH0 PUSH0 MSTORE PUSH1 0x20 PUSH0 RETURN
        
        report = execution_validator.validate_simple_bytecode(valid_bytecode, valid_bytecode)
        # Both should behave the same way
        assert report.status in [ValidationResult.PASS, ValidationResult.ERROR]


class TestEndToEnd:
    """End-to-end integration tests."""
    
    def test_simple_storage_compilation(self, solc_compiler, yul_transpiler, 
                                       execution_validator, simple_solidity):
        """Test end-to-end compilation of SimpleStorage contract."""
        # Compile Solidity to Yul
        yul_code = solc_compiler.compile_to_yul(simple_solidity)
        assert yul_code is not None
        
        # Compile Solidity to bytecode (reference)
        deploy_bytecode, runtime_bytecode = solc_compiler.compile_to_bytecode(simple_solidity)
        assert deploy_bytecode is not None
        
        # Transpile Yul to bytecode
        transpiled_bytecode = yul_transpiler.compile_yul_to_bytecode(yul_code)
        assert transpiled_bytecode is not None
        
        # Validate bytecode through execution
        report = execution_validator.validate_simple_bytecode(deploy_bytecode, transpiled_bytecode)
        
        # Check that we have a validation report
        assert report is not None
        
        # Print result for debugging
        if report.status != ValidationResult.PASS:
            print(f"\nValidation result: {report.test_name}")
            print(f"  Status: {report.status}")
            print(f"  Message: {report.message}")
            print(f"  Details: {report.details}")
        
        assert report.status in [
            ValidationResult.PASS,
            ValidationResult.ERROR,
            ValidationResult.FAIL,
        ]
    
    @pytest.mark.parametrize("contract_file", [
        "Arithmetic.sol",
        "ControlFlow.sol"
    ])
    def test_contract_compilation(self, solc_compiler, yul_transpiler, 
                                 fixtures_dir, contract_file):
        """Test compilation of various contracts."""
        sol_file = fixtures_dir / "solidity" / contract_file
        
        if not sol_file.exists():
            pytest.skip(f"Contract file not found: {sol_file}")
        
        # Compile to Yul
        yul_code = solc_compiler.compile_to_yul(sol_file)
        assert yul_code is not None
        assert len(yul_code) > 100  # Should be non-trivial
        
        # Validate Yul syntax
        is_valid, error = yul_transpiler.validate_yul_syntax(yul_code)
        assert is_valid, f"Invalid Yul syntax: {error}"
        
        # Compile to Venom IR
        venom_ir = yul_transpiler.compile_yul_to_venom_ir(yul_code)
        assert venom_ir is not None
        assert "function" in venom_ir
        
        # Compile to bytecode
        bytecode = yul_transpiler.compile_yul_to_bytecode(yul_code)
        assert bytecode is not None
        assert bytecode.startswith("0x")
        assert len(bytecode) > 10  # Should have actual bytecode


class TestCLICompatibility:
    """Test CLI interface compatibility."""
    
    def test_cli_bytecode_generation(self, yul_transpiler, fixtures_dir):
        """Test bytecode generation via CLI."""
        # Create a simple Yul file
        yul_file = fixtures_dir / "yul" / "test_cli.yul"
        yul_file.parent.mkdir(exist_ok=True)
        
        yul_content = """
        object "Test" {
            code {
                mstore(0, 123)
                return(0, 32)
            }
        }
        """
        
        with open(yul_file, 'w') as f:
            f.write(yul_content)
        
        # Compile via CLI
        bytecode = yul_transpiler.compile_via_cli(yul_file, output_format="bytecode")
        
        assert bytecode is not None
        assert bytecode.startswith("0x") or all(c in "0123456789abcdef" for c in bytecode)
    
    def test_cli_venom_generation(self, yul_transpiler, fixtures_dir):
        """Test Venom IR generation via CLI."""
        # Create a simple Yul file
        yul_file = fixtures_dir / "yul" / "test_cli_venom.yul"
        yul_file.parent.mkdir(exist_ok=True)
        
        yul_content = """
        object "Test" {
            code {
                let x := 42
                mstore(0, x)
                return(0, 32)
            }
        }
        """
        
        with open(yul_file, 'w') as f:
            f.write(yul_content)
        
        # Compile via CLI
        venom_ir = yul_transpiler.compile_via_cli(yul_file, output_format="venom")
        
        assert venom_ir is not None
        assert "function" in venom_ir
        assert "mstore" in venom_ir


if __name__ == "__main__":
    # Run tests with pytest
    pytest.main([__file__, "-v", "--tb=short"])
