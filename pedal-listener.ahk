#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent
; ============================================================================
;  Foot Pedal Audio Switch  (listener)
;  Catches the key your ikkegol pedal sends and toggles the default Windows
;  playback device between Headphones (Elgato Wave:3) and Speakers (Realtek).
;
;  The pedal must be programmed (with the ikkegol FootSwitch app) to send F24.
;  F24 is a real key that exists in the HID spec but no normal keyboard has
;  it and nothing in Windows uses it -- so it can never collide with anything.
;
;  To use a DIFFERENT key instead, change the hotkey line below (e.g. to
;  ^!F12 for Ctrl+Alt+F12) and program the pedal to match.
; ============================================================================

TraySetIcon("imageres.dll", 198)          ; little speaker icon in the tray
A_IconTip := "Foot Pedal Audio Switch (F24 = toggle)"

toggleScript := A_ScriptDir "\toggle-audio.ps1"
resultFile   := A_Temp "\footpedal_audio_result.txt"
lastFire     := 0

; --- Tray menu -------------------------------------------------------------
tray := A_TrayMenu
tray.Delete()
tray.Add("Toggle audio now", (*) => DoToggle())
tray.Add("Reload", (*) => Reload())
tray.Add("Exit", (*) => ExitApp())
tray.Default := "Toggle audio now"

; --- The pedal key ---------------------------------------------------------
F24:: DoToggle()

DoToggle() {
    global lastFire, toggleScript, resultFile

    now := A_TickCount
    if (now - lastFire < 400)             ; debounce: ignore bounces / double-taps
        return
    lastFire := now

    ; Run PowerShell fully hidden (no console flash), capture its one-word output.
    cmd := A_ComSpec ' /c powershell.exe -NoProfile -ExecutionPolicy Bypass '
         . '-File "' toggleScript '" > "' resultFile '"'
    RunWait(cmd, , "Hide")

    out := ""
    try out := Trim(FileRead(resultFile), " `t`r`n")
    if (out = "")
        out := "Switched"

    Flash(out)
}

; Brief centered on-screen confirmation, then auto-dismiss.
Flash(text) {
    ToolTip("🔊  " text, , , 1)
    SetTimer(() => ToolTip(, , , 1), -900)
}
