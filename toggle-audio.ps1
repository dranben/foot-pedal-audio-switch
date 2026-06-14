# toggle-audio.ps1
# Toggles the default Windows playback device between two outputs.
# Called by pedal-listener.ahk on every foot-pedal press.
#
# WHICH TWO DEVICES?  Run choose-devices.ps1 to pick them interactively
# (it writes devices.txt). If devices.txt is absent, the built-in defaults
# below are used. Matching is by NAME SUBSTRING so it survives the device
# index changing (indexes shuffle when you plug/unplug other gear).

$ErrorActionPreference = 'Stop'

# --- Built-in defaults (used only if devices.txt is missing) ---------------
$deviceA = 'Elgato Wave:3'        # e.g. "Headphones (Elgato Wave:3)"
$deviceB = 'Realtek USB2.0 Audio' # e.g. "Speakers (Realtek USB2.0 Audio)"

# --- Override from devices.txt if present (first two non-comment lines) -----
$cfg = Join-Path $PSScriptRoot 'devices.txt'
if (Test-Path $cfg) {
    $lines = Get-Content $cfg | ForEach-Object { $_.Trim() } |
             Where-Object { $_ -and -not $_.StartsWith('#') }
    if ($lines.Count -ge 2) { $deviceA = $lines[0]; $deviceB = $lines[1] }
}

Import-Module AudioDeviceCmdlets -ErrorAction Stop

$devices = Get-AudioDevice -List | Where-Object { $_.Type -eq 'Playback' }

$a = $devices | Where-Object { $_.Name -like "*$deviceA*" } | Select-Object -First 1
$b = $devices | Where-Object { $_.Name -like "*$deviceB*" } | Select-Object -First 1

if (-not $a) { throw "Device A matching '*$deviceA*' not found. Run choose-devices.ps1." }
if (-not $b) { throw "Device B matching '*$deviceB*' not found. Run choose-devices.ps1." }

$current = $devices | Where-Object { $_.Default } | Select-Object -First 1

# If we're currently on A, go to B. Otherwise (on B, or any third device) go to A.
$target = if ($current -and $current.Index -eq $a.Index) { $b } else { $a }

# Set both the default (Console/Multimedia) and the Communication default, so
# apps that use the "communication" device (Discord, Teams, calls) follow too.
Set-AudioDevice -Index $target.Index | Out-Null
Set-AudioDevice -Index $target.Index -CommunicationOnly | Out-Null

# Print a short label for the AHK tray tooltip (the part before " (").
Write-Output ($target.Name -replace ' \(.*$', '')
