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

# Read Foundry port from status.txt and configure OpenAI-compatible endpoint
$statusFile = Join-Path $PSScriptRoot "..\..\..\..\status.txt"
if (Test-Path $statusFile) {
    $statusContent = Get-Content $statusFile -Raw
    if ($statusContent -match "http://127\.0\.0\.1:(\d+)") {
        $foundryPort = $matches[1]
        $foundryOpenAIBaseUrl = "http://localhost:$foundryPort/v1"

        # Foundry exposes OpenAI-compatible routes under /v1
        $env:ENABLE_OPENAI_API = "True"
        $env:OPENAI_API_BASE_URL = $foundryOpenAIBaseUrl
        $env:OPENAI_API_BASE_URLS = $foundryOpenAIBaseUrl
        $env:OPENAI_API_KEY = ""
        $env:OPENAI_API_KEYS = ""

        Write-Host "Configured Foundry OpenAI endpoint: $foundryOpenAIBaseUrl" -ForegroundColor Green

        # Disable Ollama API only when Ollama is not installed to avoid wrong /api/* calls.
        $ollamaInstalled = $false
        if (Get-Command ollama -ErrorAction SilentlyContinue) {
            $ollamaInstalled = $true
        } elseif (Test-Path "$env:LOCALAPPDATA\Programs\Ollama\ollama.exe") {
            $ollamaInstalled = $true
        }

        if (-not $ollamaInstalled) {
            $env:ENABLE_OLLAMA_API = "False"
            Write-Host "Ollama not detected. Disabled Ollama API; Foundry will be used by default." -ForegroundColor Yellow
        } else {
            Write-Host "Ollama detected. Leaving Ollama API enabled." -ForegroundColor Gray
        }
    } else {
        Write-Host "Could not parse Foundry port from status.txt. Skipping Foundry endpoint setup." -ForegroundColor Yellow
    }
} else {
    Write-Host "status.txt not found. Skipping Foundry endpoint setup." -ForegroundColor Yellow
}


# Optional: print which Python is used (good for troubleshooting)
Write-Host "Using Python: $PythonExe"
& $PythonExe -c "import sys; print('sys.executable:', sys.executable)"

# Run uvicorn using the embedded Python
& $PythonExe -m uvicorn open_webui.main:app --port $env:PORT --host 0.0.0.0 --reload
