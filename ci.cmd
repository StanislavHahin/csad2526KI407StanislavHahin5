@echo off
rem CI script for Windows (cmd.exe)
rem Usage: ci.cmd

@echo [CI] Starting Windows build
setlocal

rem Allow overrides via environment variables
if "%BUILD_DIR%"=="" set BUILD_DIR=build
if "%CONFIG%"=="" set CONFIG=Release

echo [CI] Using build dir: %BUILD_DIR%, config: %CONFIG%

rem Check that cmake is available
where cmake >nul 2>nul
if errorlevel 1 (
	echo [CI] ERROR: cmake not found on PATH
	exit /b 1
)

rem Check for ctest but continue if missing (tests will be skipped)
where ctest >nul 2>nul
if errorlevel 1 (
	echo [CI] WARNING: ctest not found on PATH; tests will be skipped
	set "CTEST_FOUND=0"
) else (
	set "CTEST_FOUND=1"
)

if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
pushd "%BUILD_DIR%"

echo [CI] Configuring project with CMake
cmake -S .. -B . -DCMAKE_BUILD_TYPE="%CONFIG%"
if %ERRORLEVEL% NEQ 0 goto :err

rem Detect CPU count via environment variable as fallback
if "%NUMBER_OF_PROCESSORS%"=="" (
	set NUM_PROCS=1
) else (
	set NUM_PROCS=%NUMBER_OF_PROCESSORS%
)

echo [CI] Detected CPU count: %NUM_PROCS%

echo [CI] Building project
rem Use cmake's --parallel if it exists on this CMake build
cmake --help | findstr /C:"--parallel" >nul 2>nul
if %ERRORLEVEL% EQU 0 (
	cmake --build . --config "%CONFIG%" --parallel %NUM_PROCS%
	if %ERRORLEVEL% NEQ 0 goto :err
) else (
	rem Fallback for MSBuild or other generators: use single-thread fallback or native flag
	cmake --build . --config "%CONFIG%" -- /m:%NUM_PROCS% 2>nul || (
		cmake --build . --config "%CONFIG%" -- -j%NUM_PROCS% || goto :err
	)
)

if "%CTEST_FOUND%"=="1" (
	echo [CI] Running unit tests
	ctest --test-dir . --output-on-failure -C "%CONFIG%"
	if %ERRORLEVEL% NEQ 0 goto :err
) else (
	echo [CI] Skipping tests (no ctest found)
)

echo [CI] CI script finished successfully
popd
exit /b 0

:err
echo [CI] ERROR: CI script failed
popd
exit /b 1
