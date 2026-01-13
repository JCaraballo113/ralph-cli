$ErrorActionPreference = "Stop"

$Repo = if ($env:RALPH_REPO) { $env:RALPH_REPO } else { "jcaraballo/ralph-cli" }
$Prefix = if ($env:RALPH_PREFIX) { $env:RALPH_PREFIX } else { Join-Path $env:LOCALAPPDATA "ralph" }
$InstallDir = if ($env:RALPH_INSTALL_DIR) { $env:RALPH_INSTALL_DIR } else { Join-Path $Prefix "share\ralph" }
$BinDir = if ($env:RALPH_BIN_DIR) { $env:RALPH_BIN_DIR } else { Join-Path $Prefix "bin" }
$ZipUrl = "https://github.com/$Repo/releases/latest/download/ralph.zip"

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  Write-Error "Node.js is required. Install Node.js and re-run."
  exit 1
}

$tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) ("ralph-" + [System.Guid]::NewGuid())
New-Item -ItemType Directory -Path $tmpDir | Out-Null
$zipPath = Join-Path $tmpDir "ralph.zip"

Invoke-WebRequest -Uri $ZipUrl -OutFile $zipPath
Expand-Archive -Path $zipPath -DestinationPath $tmpDir -Force

if (Test-Path $InstallDir) {
  Remove-Item $InstallDir -Recurse -Force
}
New-Item -ItemType Directory -Path (Split-Path $InstallDir) -Force | Out-Null
Move-Item -Path (Join-Path $tmpDir "ralph") -Destination $InstallDir

New-Item -ItemType Directory -Path $BinDir -Force | Out-Null
$cmdPath = Join-Path $BinDir "ralph.cmd"
$nodePath = Join-Path $InstallDir "bin\ralph"
$cmd = "@echo off`r`nnode `"$nodePath`" %*`r`n"
Set-Content -Path $cmdPath -Value $cmd -Encoding ASCII

if (-not $env:RALPH_NO_MODIFY_PATH) {
  $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
  if (-not $currentPath) { $currentPath = "" }
  $parts = $currentPath -split ";" | Where-Object { $_ -and $_.Trim() -ne "" }
  if ($parts -notcontains $BinDir) {
    $newPath = ($parts + $BinDir) -join ";"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "Added $BinDir to PATH for current user. Restart your shell."
  }
} else {
  Write-Host "Add $BinDir to PATH to run ralph."
}

Write-Host "Installed ralph to $InstallDir"
Write-Host "Run: ralph --help"
