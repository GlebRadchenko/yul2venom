#!/bin/bash

# Yul-to-Venom Test Runner Script

echo "========================================"
echo "Yul-to-Venom Validation System Test"
echo "========================================"

# Use python3.11 explicitly
PYTHON=python3.11

# Check if solc is installed
if ! command -v solc &> /dev/null; then
    echo "Error: solc is not installed"
    echo "Please install solc: brew install solidity"
    exit 1
fi

echo "[OK] solc found: $(solc --version | head -1)"

# Check Python version
echo "[OK] Python: $($PYTHON --version)"

# Install dependencies if needed
echo ""
echo "Installing dependencies..."
$PYTHON -m pip install -q -r requirements.txt

# Run the test orchestrator
echo ""
echo "Running validation tests..."
echo "========================================"
$PYTHON test_validation/test_orchestrator.py "$@"