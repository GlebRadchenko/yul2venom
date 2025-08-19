#!/bin/bash

echo "========================================"
echo "Yul-to-Venom Validation System Demo"
echo "========================================"
echo ""

# Test simple Yul compilation
echo "1. Testing simple Yul compilation..."
echo "----------------------------------------"
python3.11 test_simple.py
echo ""

# Show available test contracts
echo "2. Available test contracts:"
echo "----------------------------------------"
ls test_validation/fixtures/solidity/*.sol 2>/dev/null | while read f; do
    echo "   • $(basename $f)"
done
echo ""

# Run a minimal test with filter
echo "3. Running minimal validation test..."
echo "----------------------------------------"
echo "Note: This would normally test against solc-compiled bytecode"
echo "but requires solc to be installed."
echo ""

# Check if solc is available
if command -v solc &> /dev/null; then
    echo "✓ solc is installed"
    echo ""
    echo "You can run full validation tests with:"
    echo "  ./run_tests.sh"
    echo "  ./run_tests.sh --filter arithmetic"
    echo "  ./run_tests.sh --report results.json"
else
    echo "⚠️  solc is not installed"
    echo ""
    echo "To run full validation tests, install solc:"
    echo "  brew install solidity        # macOS"
    echo "  apt-get install solc         # Ubuntu/Debian"
fi

echo ""
echo "========================================"
echo "Demo complete!"
echo ""
echo "For more information, see:"
echo "  • test_validation/README.md"
echo "  • Run: python3.11 -m pytest test_validation/test_suite.py"
echo "========================================"