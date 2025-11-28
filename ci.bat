@echo off
rem Simple CI wrapper for Windows (cmd.exe)
rem Usage: ci.bat [build_dir] [Release|Debug]

setlocal

set CI_RC=0

if "%1"=="" (
  set BUILD_DIR=build
) else (
  set BUILD_DIR=%1
)

if "%2"=="" (
  set CONFIG=Release
) else (
  set CONFIG=%2
)

echo [CI] Using build dir: %BUILD_DIR%, config: %CONFIG%

where cmake >nul 2>nul
if errorlevel 1 (
  echo [CI] ERROR: cmake not found on PATH
  exit /b 1
)

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
if %ERRORLEVEL% NEQ 0 (
  echo [CI] ERROR: CMake configuration failed
  set CI_RC=1
  goto :FINISH
)

rem Detect CPU count via environment variable
if "%NUMBER_OF_PROCESSORS%"=="" (
  set NUM_PROCS=1
) else (
  set NUM_PROCS=%NUMBER_OF_PROCESSORS%
)

echo [CI] Detected CPU count: %NUM_PROCS%

echo [CI] Building project
set "BUILD_LOG=%TEMP%\ci_build_output.txt"
if exist "%BUILD_LOG%" del /f /q "%BUILD_LOG%" >nul 2>nul

  rem Try parallel build first; use 'if errorlevel' to detect non-zero exit codes
  cmake --build . --config "%CONFIG%" --parallel %NUM_PROCS% > "%BUILD_LOG%" 2>&1
  if errorlevel 1 (
    rem Fallback: try without --parallel
    cmake --build . --config "%CONFIG%" > "%BUILD_LOG%" 2>&1
  )

  type "%BUILD_LOG%"

  if errorlevel 1 (
    echo [CI] ERROR: Build failed
    set CI_RC=1
    goto :FINISH
  ) else (
    echo [CI] Build succeeded
  )

if "%CTEST_FOUND%"=="1" (
  echo [CI] Running unit tests
  ctest --test-dir . --output-on-failure -C "%CONFIG%"
  if %ERRORLEVEL% NEQ 0 (
    echo [CI] ERROR: Tests failed
    set CI_RC=1
    goto :FINISH
  )
) else (
  echo [CI] Skipping tests (no ctest found)
)

:FINISH
if %CI_RC% EQU 0 (
  echo [CI] CI script finished successfully
  popd
  exit /b 0
) else (
  echo [CI] ERROR: CI script failed
  popd
  exit /b 1
)
 