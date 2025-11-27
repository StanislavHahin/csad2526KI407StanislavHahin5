<#
ci.ps1 - PowerShell CI script for Windows / cross-platform (PowerShell Core)
Features:
- CPU detection via [Environment]::ProcessorCount
- cmake and ctest presence checks
- parallel build via cmake --parallel or fallback to native flags
- safe directory change using Push-Location/Pop-Location
#>
param(
    [string]$BuildDir = $env:BUILD_DIR,
    [string]$Config = $env:CONFIG
)

# Fallback to defaults if environment vars are not set
if (-not $BuildDir -or $BuildDir -eq '') { $BuildDir = 'build' }
if (-not $Config -or $Config -eq '') { $Config = 'Release' }

$ErrorActionPreference = 'Stop'

Write-Host "[CI] Using build dir: $BuildDir, config: $Config"

function Get-ProcessorCount {
    try { return [int][Environment]::ProcessorCount } catch { return 1 }
}

$numJobs = Get-ProcessorCount
Write-Host "[CI] Detected CPU count: $numJobs"

function Check-Command([string]$cmd) {
    return (Get-Command $cmd -ErrorAction SilentlyContinue) -ne $null
}

if (-not (Check-Command 'cmake')) {
    Write-Error "[CI] ERROR: cmake not found on PATH"
    exit 1
}

$ctestFound = Check-Command 'ctest'
if (-not $ctestFound) {
    Write-Host "[CI] WARNING: ctest not found on PATH; tests will be skipped"
}

if (-not (Test-Path $BuildDir)) { New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null }

Push-Location $BuildDir
try {
    Write-Host "[CI] Configuring project with CMake"
    & cmake -S .. -B . -DCMAKE_BUILD_TYPE="${Config}"

    Write-Host "[CI] Building project"
    # Prefer cmake --parallel; if unavailable, try passing -j to the native build tool
    try {
        # detect --parallel support
        $help = (& cmake --help) -join "`n"
        if ($help -match '--parallel') {
            & cmake --build . --config "$Config" --parallel $numJobs
        } else {
            # Try MSBuild /m or Make -j alternative
            try { & cmake --build . --config "$Config" -- /m:$numJobs } catch {
                & cmake --build . --config "$Config" -- -j$numJobs
            }
        }
    } catch {
        Write-Host "[CI] Build failed, retrying without parallelism"
        & cmake --build . --config "$Config" | Out-Host
    }

    if ($ctestFound) {
        Write-Host "[CI] Running unit tests"
        & ctest --output-on-failure -C "$Config" | Out-Host
    } else {
        Write-Host "[CI] Skipping tests (no ctest found)"
    }
}
finally {
    Pop-Location
}

Write-Host "[CI] CI script finished successfully"
