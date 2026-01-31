"""
Yul2Venom Testing Package

Test utilities and frameworks for the Yul2Venom transpiler.

Key modules:
- test_framework: Comprehensive transpilation testing
- vyper_ir_helper: Vyper IR generation for comparison
- export_bytecode, inspect_bytecode: Bytecode analysis tools
"""

from pathlib import Path

# Package directories
TESTING_DIR = Path(__file__).parent.absolute()
YUL2VENOM_DIR = TESTING_DIR.parent
CONFIGS_DIR = YUL2VENOM_DIR / "configs"
OUTPUT_DIR = YUL2VENOM_DIR / "output"
DEBUG_DIR = YUL2VENOM_DIR / "debug"

# Default timeouts (seconds)
TRANSPILE_TIMEOUT = 120
FORGE_TEST_TIMEOUT = 300
