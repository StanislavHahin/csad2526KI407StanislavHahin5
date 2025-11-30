CI Scripts
==========

This repository provides two convenience scripts for running the project's build and tests locally or in CI environments:

- `ci.sh` — POSIX-compatible shell script for Linux/macOS
- `ci.cmd` — Windows batch script for cmd.exe
- `ci.ps1` — PowerShell script (recommended on Windows / cross-platform via PowerShell Core)

How to run:

POSIX (Linux/macOS):
```
./ci.sh
```

Windows (cmd.exe):
```
ci.cmd
```
Note: `ci.cmd --mode test` will only run tests using an *already configured* build directory. If the build directory is not configured (no `CMakeCache.txt` present), the script will print a helpful error suggesting to run `ci.cmd --mode all` or `ci.cmd --mode build` first.

Behavior:
- Creates a `build/` directory if it doesn't exist
- Configures CMake to use `CMAKE_BUILD_TYPE=Release` (configurable via `CONFIG`/`CMAKE_BUILD_TYPE`) and runs the build
- Runs `ctest` and prints any failing test output (skips tests if `ctest` isn't found)
- Attempts to build in parallel using CMake's `--parallel` option when available; falls back to native `-j` or `/m` flags if required
- Checks that `cmake` is available and prints a helpful error message if missing

Notes:
- The scripts assume `cmake`, a C/C++ compiler and `ctest` are available on your PATH
- On Windows, Visual Studio developer tools (or a working C/C++ toolchain) are required
- `ci.ps1` (PowerShell) is available for Windows and PowerShell Core runners
- A GitHub Actions workflow `.github/workflows/ci.yml` is included to invoke these scripts on Linux/Windows/macOS
