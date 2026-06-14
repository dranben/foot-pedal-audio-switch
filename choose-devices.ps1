# choose-devices.ps1
# Interactive picker: lists your playback devices and writes the two you choose
# to devices.txt, which toggle-audio.ps1 reads. No code editing required.

$ErrorActionPreference = 'Stop'
Import-Module AudioDeviceCmdlets -ErrorAction Stop

$devs = @(Get-AudioDevice -List | Where-Object { $_.Type -eq 'Playback' })
if ($devs.Count -lt 2) { throw "Need at least two playback devices; found $($devs.Count)." }

Write-Host "`nYour playback devices:`n" -ForegroundColor Green
for ($i = 0; $i -lt $devs.Count; $i++) {
    $mark = if ($devs[$i].Default) { ' (current default)' } else { '' }
    "{0,2}) {1}{2}" -f ($i + 1), $devs[$i].Name, $mark | Write-Host
}

function Pick($label) {
    while ($true) {
        $n = Read-Host "`nPick $label by number (1-$($devs.Count))"
        if ($n -match '^\d+$' -and [int]$n -ge 1 -and [int]$n -le $devs.Count) { return $devs[[int]$n - 1] }
        Write-Host "  Enter a number from 1 to $($devs.Count)." -ForegroundColor Yellow
    }
}

$a = Pick "the FIRST device (e.g. headphones)"
$b = Pick "the SECOND device (e.g. speakers)"
if ($a.Index -eq $b.Index) { throw "You picked the same device twice." }

$out = Join-Path $PSScriptRoot 'devices.txt'
@(
    '# Foot Pedal Audio Switch - the two outputs the pedal toggles between.'
    '# First two non-comment lines = device A and device B (name substrings).'
    '# Run choose-devices.ps1 to set these interactively, or just edit them here.'
    $a.Name
    $b.Name
) | Set-Content -Path $out -Encoding UTF8

Write-Host "`nSaved to devices.txt:" -ForegroundColor Green
Write-Host ("  A: " + $a.Name)
Write-Host ("  B: " + $b.Name)
Write-Host "`nTap your pedal (or the tray icon -> Toggle audio now) to test.`n"
