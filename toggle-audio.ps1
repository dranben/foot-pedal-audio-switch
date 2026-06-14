# toggle-audio.ps1
# Toggles the default Windows playback device between Headphones and Speakers.
# Called by pedal-listener.ahk on every foot-pedal press.
#
# Matching is by NAME SUBSTRING so it survives the device index changing
# (indexes shuffle when you plug/unplug other gear). Edit the two strings
# below if you ever rename a device.

$ErrorActionPreference = 'Stop'

$HEADPHONES = 'Elgato Wave:3'        # "Headphones (Elgato Wave:3)"
$SPEAKERS   = 'Realtek USB2.0 Audio' # "Speakers (Realtek USB2.0 Audio)"

Import-Module AudioDeviceCmdlets -ErrorAction Stop

$devices = Get-AudioDevice -List | Where-Object { $_.Type -eq 'Playback' }

$hp = $devices | Where-Object { $_.Name -like "*$HEADPHONES*" } | Select-Object -First 1
$sp = $devices | Where-Object { $_.Name -like "*$SPEAKERS*"   } | Select-Object -First 1

if (-not $hp) { throw "Headphones device matching '*$HEADPHONES*' not found." }
if (-not $sp) { throw "Speakers device matching '*$SPEAKERS*' not found." }

$current = $devices | Where-Object { $_.Default } | Select-Object -First 1

# If we're currently on Headphones, go to Speakers. Otherwise (Speakers, or
# any third device like the monitor) go to Headphones.
if ($current -and $current.Index -eq $hp.Index) {
    $target = $sp
} else {
    $target = $hp
}

# Set both the default (Console/Multimedia) and the default Communication role
# so apps that pick the "communication" device (Discord, Teams, calls) follow too.
Set-AudioDevice -Index $target.Index | Out-Null
Set-AudioDevice -Index $target.Index -CommunicationOnly | Out-Null

# Print the short label the AHK script shows in its tray tooltip.
if ($target.Index -eq $hp.Index) { Write-Output 'Headphones' } else { Write-Output 'Speakers' }
