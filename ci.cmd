@echo off
rem CI script for Windows (cmd.exe)
rem Usage: ci.cmd

@echo [CI] Starting Windows build
setlocal

rem ---------------------------
rem Parse args (supports --mode test|build|all) - default: all
set "MODE=all"
if "%1"=="--mode" (
	if "%2"=="" (
		echo [CI] ERROR: --mode requires an argument: test|build|all
		exit /b 1
	)
	set "MODE=%2"
	shift
	shift
)

rem Allow overrides via environment variables
if "%BUILD_DIR%"=="" set BUILD_DIR=build
if "%CONFIG%"=="" set CONFIG=Release

echo [CI] Using build dir: %BUILD_DIR%, config: %CONFIG%, mode: %MODE%

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

rem Detect available C/C++ compilers (msvc, mingw, clang)
set "COMPILER_FOUND=0"
where cl >nul 2>nul
if NOT errorlevel 1 (
	set "COMPILER=msvc"
	set "COMPILER_FOUND=1"
)
if "%COMPILER_FOUND%"=="0" where g++ >nul 2>nul && (
	set "COMPILER=gcc"
	set "COMPILER_FOUND=1"
)
if "%COMPILER_FOUND%"=="0" where clang++ >nul 2>nul && (
	set "COMPILER=clang"
	set "COMPILER_FOUND=1"
)
if "%COMPILER_FOUND%"=="0" (
	echo [CI] WARNING: No obvious C/C++ compiler found in PATH (cl, g++, or clang++)
	echo [CI] If you want to use Visual Studio/MSVC, run this script from the "Developer Command Prompt" or use 'vcvarsall.bat'
	echo [CI] Alternatively, install MinGW/MSYS2 or configure CMake to use a specific generator (e.g. Ninja)
)

if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
pushd "%BUILD_DIR%"

rem If running in test-only mode, verify the build dir is already configured and skip running cmake configure
if /I "%MODE%"=="test" (
	if exist "%BUILD_DIR%\CMakeCache.txt" (
		echo [CI] Test-only mode: using existing configured build directory
	) else (
		echo [CI] ERROR: Build directory is not configured. Run the script with --mode build or run configure/build first (e.g., "ci.cmd --mode all")
		goto :err
	)
) else (
	echo [CI] Configuring project with CMake
	cmake -S .. -B . -DCMAKE_BUILD_TYPE="%CONFIG%"
	if %ERRORLEVEL% NEQ 0 goto :err
)

rem Detect CPU count via environment variable as fallback
if "%NUMBER_OF_PROCESSORS%"=="" (
	set NUM_PROCS=1
) else (
	set NUM_PROCS=%NUMBER_OF_PROCESSORS%
)

echo [CI] Detected CPU count: %NUM_PROCS%

if /I "%MODE%"=="test" (
	echo [CI] Mode: test — skipping configure/build and running tests only
	if "%CTEST_FOUND%"=="1" (
		ctest --test-dir . --output-on-failure -C "%CONFIG%"
		if %ERRORLEVEL% NEQ 0 goto :err
	) else (
		echo [CI] ERROR: ctest not found — cannot run tests
		goto :err
	)
) else (
	echo [CI] Building project
)
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

if "%MODE%"=="all" (
	if "%CTEST_FOUND%"=="1" (
		echo [CI] Running unit tests
		ctest --test-dir . --output-on-failure -C "%CONFIG%"
		if %ERRORLEVEL% NEQ 0 goto :err
	) else (
		echo [CI] Skipping tests (no ctest found)
	)
)

echo [CI] CI script finished successfully
popd
exit /b 0

:err
echo [CI] ERROR: CI script failed
popd
exit /b 1
