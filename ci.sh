#!/bin/bash
# CI script for Linux/macOS
# Builds the project using CMake and runs tests with CTest

set -e  # Exit on first error

echo "=========================================="
echo "CI Script - Build & Test"
echo "=========================================="
echo ""

# Create build directory
echo "[1/5] Creating build directory..."
mkdir -p build
cd build

# Configure project with CMake
echo "[2/5] Configuring project with CMake..."
cmake ..

# Build the project
echo "[3/5] Building project..."
cmake --build . --config Release

# Run unit tests
echo "[4/5] Running unit tests with CTest..."
ctest --output-on-failure

# Success message
echo ""
echo "=========================================="
echo "Build and tests completed successfully!"
echo "=========================================="
echo ""
echo "Executables generated:"
echo "  - ./main (Hello World executable)"
echo "  - ./unit_tests (Unit tests executable)"
echo ""
