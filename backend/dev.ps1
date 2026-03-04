# # Always use the embedded Python shipped with the app
# $PythonExe = Join-Path $PSScriptRoot "..\..\..\runtimes\python\python.exe"

# if (-not (Test-Path $PythonExe)) {
#     Write-Host "ERROR: Embedded Python not found at: $PythonExe"
#     Write-Host "Expected path relative to this script: ..\..\..\runtimes\python\python.exe"
#     exit 1
# }

# # Normalize to an absolute path (avoids path quirks)
# $PythonExe = (Resolve-Path $PythonExe).Path

# # Ensure embedded Python is first in PATH (helps any subprocesses)
# $env:Path = (Split-Path $PythonExe) + ";" + $env:Path

# # Set environment variables
# $env:CORS_ALLOW_ORIGIN = "http://localhost:5173;http://localhost:8080"

# # Use default port 8080 if PORT is not set
# if (-not $env:PORT) {
#     $env:PORT = 8080
# }

# # Optional: print which Python is used (good for troubleshooting)
# Write-Host "Using Python: $PythonExe"
# & $PythonExe -c "import sys; print('sys.executable:', sys.executable)"

# # Run uvicorn using the embedded Python
# & $PythonExe -m uvicorn open_webui.main:app --port $env:PORT --host 0.0.0.0 --reload


# Always use the embedded Python shipped with the app
$PythonExe = Join-Path $PSScriptRoot "..\..\..\runtimes\python\python.exe"

if (-not (Test-Path $PythonExe)) {
    Write-Host "ERROR: Embedded Python not found at: $PythonExe"
    Write-Host "Expected path relative to this script: ..\..\..\runtimes\python\python.exe"
    exit 1
}

# Normalize to an absolute path (avoids path quirks)
$PythonExe = (Resolve-Path $PythonExe).Path

# Ensure embedded Python is first in PATH (helps any subprocesses)
$env:Path = (Split-Path $PythonExe) + ";" + $env:Path

# Set environment variables
$env:CORS_ALLOW_ORIGIN = "http://localhost:5173;http://localhost:8080"

# Use default port 8080 if PORT is not set
if (-not $env:PORT) {
    $env:PORT = 8080
}

# Read Foundry port from status.txt and configure connection
$statusFile = Join-Path $PSScriptRoot "..\..\..\..\status.txt"
if (Test-Path $statusFile) {
    $statusContent = Get-Content $statusFile -Raw
    if ($statusContent -match "http://127\.0\.0\.1:(\d+)") {
        $foundryPort = $matches[1]
        $env:OLLAMA_API_BASE_URL = "http://localhost:11434"
        Write-Host "Configured Foundry connection on port: $foundryPort" -ForegroundColor Green
    }
}

# Optional: print which Python is used (good for troubleshooting)
Write-Host "Using Python: $PythonExe"
& $PythonExe -c "import sys; print('sys.executable:', sys.executable)"

# Run uvicorn using the embedded Python
& $PythonExe -m uvicorn open_webui.main:app --port $env:PORT --host 0.0.0.0 --reload
