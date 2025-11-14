# CI/CD Scripts Documentation

## Overview
This project includes CI/CD scripts for automated building and testing across multiple platforms.

## Scripts

### Windows
- **ci.bat** - Windows batch script for building and testing
- **ci.cmd** - Alternative Windows batch format (same functionality as ci.bat)

Usage:
```cmd
.\ci.bat
```

### Linux/macOS
- **ci.sh** - Bash script for building and testing

Usage:
```bash
chmod +x ci.sh
./ci.sh
```

## What the Scripts Do

1. **Create build directory** - Creates a `build/` directory for out-of-source builds
2. **Configure project** - Runs CMake with appropriate generator for the platform
3. **Build project** - Compiles the project using the configured build system
4. **Run tests** - Executes unit tests via CTest (if available)

## Build Requirements

- CMake (3.10 or higher)
- C++ compiler (MinGW, GCC, Clang, or MSVC)
- Make/build tools appropriate for your platform

### Windows
- MinGW (for MinGW Makefiles generator)

### Linux/macOS
- GCC/Clang
- Make

## Environment Variables

Tests are currently disabled by default using `-DENABLE_TESTS=OFF` in CMake configuration to ensure compatibility when external dependencies (like Google Test) cannot be downloaded. To enable tests locally, modify the CMake command in the scripts.

## Output

The scripts generate:
- `build/main.exe` (Windows) or `build/main` (Linux/macOS) - Main executable
- `build/libmath_operations.a` - Math operations library

## Exit Codes

- `0` - Build and tests completed successfully
- `1` - Build or configuration failed
