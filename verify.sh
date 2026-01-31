#!/bin/bash
# Yul2Venom Verification Script
# Compare native solc bytecode with yul2venom transpiled bytecode

set -e

CONTRACT="${1:-LoopCheck}"
echo "=== Yul2Venom Verification: $CONTRACT ==="

# Paths
CONFIG="configs/${CONTRACT}.yul2venom.json"
SOL_FILE="foundry/src/${CONTRACT}.sol"
OUTPUT_DIR="output"

# Verify files exist
if [ ! -f "$CONFIG" ]; then
    echo "Error: Config not found: $CONFIG"
    echo "Usage: ./verify.sh <ContractName>"
    exit 1
fi

if [ ! -f "$SOL_FILE" ]; then
    echo "Error: Solidity file not found: $SOL_FILE"
    exit 1
fi

# 1. Native Compilation (Solc -> Bytecode)
echo ""
echo "[1/3] Compiling native bytecode with solc..."
mkdir -p "$OUTPUT_DIR/native"
solc --optimize --optimize-runs 3000000 --bin --overwrite "$SOL_FILE" -o "$OUTPUT_DIR/native" 2>/dev/null

NATIVE_BIN="$OUTPUT_DIR/native/${CONTRACT}.bin"
if [ -f "$NATIVE_BIN" ]; then
    NATIVE_SIZE=$(wc -c < "$NATIVE_BIN" | tr -d ' ')
    echo "  ✓ Native: $NATIVE_SIZE bytes"
else
    echo "  ✗ Native compilation failed"
    exit 1
fi

# 2. Custom Pipeline (Yul -> Venom -> Bytecode)
echo ""
echo "[2/3] Running yul2venom transpile..."
python3.11 yul2venom.py transpile "$CONFIG" --quiet

CUSTOM_BIN="$OUTPUT_DIR/${CONTRACT}_opt_runtime.bin"
if [ -f "$CUSTOM_BIN" ]; then
    CUSTOM_SIZE=$(wc -c < "$CUSTOM_BIN" | tr -d ' ')
    echo "  ✓ Custom: $CUSTOM_SIZE bytes"
else
    echo "  ✗ Custom pipeline failed"
    exit 1
fi

# 3. Compare
echo ""
echo "[3/3] Comparing bytecodes..."
if diff -q "$NATIVE_BIN" "$CUSTOM_BIN" > /dev/null 2>&1; then
    echo "  ✓ Bytecodes match!"
else
    echo "  ⚠ Bytecodes differ (expected for different optimizer)"
    echo "    Native: $NATIVE_SIZE bytes"
    echo "    Custom: $CUSTOM_SIZE bytes"
fi

echo ""
echo "=== Done ==="
