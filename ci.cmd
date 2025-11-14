@echo off
REM CI script for Windows (PowerShell-friendly cmd wrapper)
REM This script can be run from PowerShell: .\ci.cmd

setlocal enabledelayedexpansion

echo.
echo ==========================================
echo CI Script - Build ^& Test (Windows CMD)
echo ==========================================
echo.

REM Create build directory
echo [1/5] Creating build directory...
if not exist build mkdir build
cd build

REM Configure project with CMake
echo [2/5] Configuring project with CMake...
cmake .. -G "MinGW Makefiles"
if !errorlevel! neq 0 (
    echo Error: CMake configuration failed
    cd ..
    exit /b 1
)

REM Build the project
echo [3/5] Building project...
cmake --build . --config Release
if !errorlevel! neq 0 (
    echo Error: Build failed
    cd ..
    exit /b 1
)

REM Run unit tests
echo [4/5] Running unit tests with CTest...
ctest --output-on-failure
if !errorlevel! neq 0 (
    echo Error: Tests failed
    cd ..
    exit /b 1
)

REM Success message
echo.
echo ==========================================
echo Build and tests completed successfully!
echo ==========================================
echo.
echo Executables generated:
echo   - .\main.exe (Hello World executable)
echo   - .\unit_tests.exe (Unit tests executable)
echo.

cd ..
exit /b 0
