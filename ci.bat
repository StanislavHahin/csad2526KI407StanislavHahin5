@echo off
REM CI/CD Script for Windows
REM This script builds the project and runs tests

setlocal enabledelayedexpansion

echo === CI/CD Build and Test Script ===
echo Creating build directory...
if not exist build mkdir build

echo Changing to build directory...
cd build

echo Configuring project with CMake...
cmake .. -G "MinGW Makefiles" -DENABLE_TESTS=ON
if errorlevel 1 (
    echo CMake configuration failed
    exit /b 1
)

echo Building project...
cmake --build .
if errorlevel 1 (
    echo Build failed
    exit /b 1
)

echo Running tests with CTest...
ctest --output-on-failure
if errorlevel 1 (
    echo Tests failed
    exit /b 1
)

echo === Build and tests completed successfully ===
