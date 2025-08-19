"""
Pytest configuration and fixtures for Yul-to-Venom validation tests.
"""

import pytest
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))
sys.path.insert(0, "/Users/harkal/projects/charles_cooper/repos/vyper")

from test_validation.runners.solc_compiler import SolcCompiler
from test_validation.runners.yul_transpiler import YulTranspiler
from test_validation.validators.execution_validator import ExecutionValidator


@pytest.fixture(scope="session")
def solc_compiler():
    """Provide SolcCompiler instance."""
    try:
        return SolcCompiler()
    except RuntimeError as e:
        pytest.skip(f"solc not available: {e}")


@pytest.fixture(scope="session")
def yul_transpiler():
    """Provide YulTranspiler instance."""
    return YulTranspiler()


@pytest.fixture(scope="session")
def execution_validator():
    """Provide ExecutionValidator instance."""
    return ExecutionValidator()


@pytest.fixture(scope="session")
def fixtures_dir():
    """Provide path to fixtures directory."""
    return Path(__file__).parent / "fixtures"


@pytest.fixture
def simple_yul():
    """Provide simple Yul code for testing."""
    return """
    object "Test" {
        code {
            mstore(0, 42)
            return(0, 32)
        }
    }
    """


@pytest.fixture
def simple_solidity(fixtures_dir):
    """Provide path to simple Solidity contract."""
    sol_file = fixtures_dir / "solidity" / "SimpleStorage.sol"
    if not sol_file.exists():
        pytest.skip(f"Solidity fixture not found: {sol_file}")
    return sol_file