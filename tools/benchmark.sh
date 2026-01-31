#!/bin/bash
# Yul2Venom Benchmark Wrapper
# This script runs the benchmark with proper terminal settings to avoid mouse tracking issues

# Disable mouse tracking
printf '\033[?1000l\033[?1006l\033[?1015l'

# Set environment for clean output
export TERM=dumb
export NO_COLOR=1
export CI=1
export FORCE_COLOR=0

# Change to project directory
cd "$(dirname "$0")/.." || exit 1

# Run benchmark with all arguments passed through
python3.11 tools/benchmark.py "$@"
exit_code=$?

# Ensure mouse tracking is disabled after
printf '\033[?1000l\033[?1006l\033[?1015l'

exit $exit_code
