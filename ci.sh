#!/bin/bash

# CI/CD Script for Linux/macOS
# This script builds the project and runs tests

set -e

echo "=== CI/CD Build and Test Script ==="
echo "Creating build directory..."
mkdir -p build

echo "Changing to build directory..."
cd build

echo "Configuring project with CMake..."
cmake .. -DENABLE_TESTS=ON

echo "Building project..."
cmake --build .

echo "Running tests with CTest..."
ctest --output-on-failure

echo "=== Build and tests completed successfully ==="
