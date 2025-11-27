#!/usr/bin/env sh
# CI script for POSIX-like systems (Linux, macOS)
set -eu

BUILD_DIR=${BUILD_DIR:-build}
CONFIG=${CONFIG:-Release}

echo "[CI] Using build dir: ${BUILD_DIR}, config: ${CONFIG}"

orig_dir=$(pwd)
trap 'cd "${orig_dir}"' EXIT

# Detect number of CPU cores with several fallbacks
detect_jobs() {
  if command -v nproc >/dev/null 2>&1; then
    nproc
  elif command -v getconf >/dev/null 2>&1; then
    getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1
  elif command -v sysctl >/dev/null 2>&1; then
    sysctl -n hw.ncpu 2>/dev/null || echo 1
  else
    echo 1
  fi
}

<<<<<<< HEAD
echo "Configuring project with CMake..."
cmake .. -DENABLE_TESTS=ON
=======
NUM_JOBS=$(detect_jobs)
>>>>>>> ff864ba (ci: add and harden CI scripts (ci.sh, ci.cmd, ci.ps1); add GH Actions workflow; update CI_SCRIPTS.md)

echo "[CI] Detected CPU count: ${NUM_JOBS}"

# Check for required tools early
if ! command -v cmake >/dev/null 2>&1; then
  echo "[CI] ERROR: cmake not found on PATH"
  exit 1
fi

if ! command -v ctest >/dev/null 2>&1; then
  echo "[CI] WARNING: ctest not found on PATH; tests will be skipped"
  CTEST_FOUND=0
else
  CTEST_FOUND=1
fi

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

echo "[CI] Configuring project with CMake"
# Use explicit source/build directory flags for clarity
cmake -S .. -B . -DCMAKE_BUILD_TYPE="${CONFIG}"

echo "[CI] Building project"
# Prefer CMake's --parallel if available (CMake >= 3.12), otherwise fall back to passing -j to the native build tool
if cmake --help | grep -- '--parallel' >/dev/null 2>&1; then
  if cmake --build . --config "${CONFIG}" --parallel "${NUM_JOBS}"; then
    echo "[CI] Build succeeded"
  else
    echo "[CI] ERROR: Build failed"
    exit 1
  fi
else
  # Fallback: pass -j to the underlying tool (Make/Ninja)
  if cmake --build . --config "${CONFIG}" -- -j"${NUM_JOBS}"; then
    echo "[CI] Build succeeded"
  else
    echo "[CI] Build failed, retrying without parallelism"
    cmake --build . --config "${CONFIG}" || { echo "[CI] ERROR: Build failed"; exit 1; }
  fi
fi

if [ "${CTEST_FOUND}" -eq 1 ]; then
  echo "[CI] Running unit tests"
  if ! ctest --output-on-failure -C "${CONFIG}"; then
    echo "[CI] ERROR: Tests failed"
    exit 1
  fi
else
  echo "[CI] Skipping tests (no ctest found)"
fi

echo "[CI] CI script finished successfully"
