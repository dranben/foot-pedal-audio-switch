# setup.ps1  --  one-time installer for the Foot Pedal Audio Switch.
# Run this ONCE (normal user, no admin needed). Re-running is safe.
#
#   1. Installs the AudioDeviceCmdlets PowerShell module (does the switching)
#   2. Installs AutoHotkey v2 via winget (catches the pedal key)
#   3. Creates a Startup shortcut so the listener runs every time you log in
#   4. Starts the listener now

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$ahkScript = Join-Path $here 'pedal-listener.ahk'

function Say($m) { Write-Host "  $m" -ForegroundColor Cyan }

Write-Host "`n=== Foot Pedal Audio Switch -- setup ===`n" -ForegroundColor Green

# 1. Audio module ----------------------------------------------------------
Say "Checking AudioDeviceCmdlets module..."
if (-not (Get-Module -ListAvailable -Name AudioDeviceCmdlets)) {
    Say "Installing AudioDeviceCmdlets (current user)..."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    if (-not (Get-PackageProvider -ListAvailable -Name NuGet -ErrorAction SilentlyContinue)) {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser | Out-Null
    }
    if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') {
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }
    Install-Module -Name AudioDeviceCmdlets -Scope CurrentUser -Force -AllowClobber
    Say "  installed."
} else {
    Say "  already installed."
}

# 2. AutoHotkey v2 ---------------------------------------------------------
Say "Checking AutoHotkey v2..."
function Find-Ahk {
    @(
        "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey64.exe",
        "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey32.exe",
        "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe",
        "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey.exe",
        "$env:ProgramFiles\AutoHotkey\AutoHotkey.exe"
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1
}
$ahkExe = Find-Ahk

if (-not $ahkExe) {
    Say "Installing AutoHotkey v2 via winget..."
    winget install --id AutoHotkey.AutoHotkey -e --accept-source-agreements --accept-package-agreements --silent
    $ahkExe = Find-Ahk
}
if (-not $ahkExe) { throw "AutoHotkey did not install. Install it from https://www.autohotkey.com (v2) and re-run." }
Say "  using: $ahkExe"

# 3. Startup shortcut ------------------------------------------------------
Say "Creating Startup shortcut (runs on every login)..."
$startup = [Environment]::GetFolderPath('Startup')
$lnk = Join-Path $startup 'FootPedalAudioSwitch.lnk'
$w = New-Object -ComObject WScript.Shell
$s = $w.CreateShortcut($lnk)
$s.TargetPath       = $ahkExe
$s.Arguments        = "`"$ahkScript`""
$s.WorkingDirectory = $here
$s.Description       = 'Foot Pedal Audio Switch'
$s.Save()
Say "  $lnk"

# 4. Start it now ----------------------------------------------------------
Say "Starting the listener now..."
Get-Process AutoHotkey* -ErrorAction SilentlyContinue |
    Where-Object { $_.Path -and (Get-CimInstance Win32_Process -Filter "ProcessId=$($_.Id)").CommandLine -like "*pedal-listener.ahk*" } |
    Stop-Process -Force -ErrorAction SilentlyContinue
Start-Process -FilePath $ahkExe -ArgumentList "`"$ahkScript`"" -WorkingDirectory $here

Write-Host "`nDone." -ForegroundColor Green
Write-Host "The pedal toggles audio once you program it to send F24 (see README)." -ForegroundColor Yellow
