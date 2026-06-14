# Foot Pedal Audio Switch

Tap a USB foot pedal to toggle the default Windows playback device between two
outputs — in my setup, **Headphones (Elgato Wave:3)** and **Speakers (Realtek
USB2.0 Audio)**. Runs silently in the background every time the PC is on.

> **Using your own gear?** It works with any USB foot pedal that can be
> programmed to send a keystroke (built for an [iKKEGOL](https://www.ikkegol.com)
> single pedal), and any two playback devices. Put your two device names in
> `toggle-audio.ps1` (see [If a device gets renamed / replaced](#if-a-device-gets-renamed--replaced))
> and run `setup.ps1`.

## How it works

```
foot pedal  --(sends F24)-->  pedal-listener.ahk  -->  toggle-audio.ps1
                               (always running)        (flips the default device)
```

- **toggle-audio.ps1** — flips the default playback device (and the
  "communication" default, so Discord/Teams follow too). Matches devices by
  name, so it keeps working even if Windows reshuffles device indexes.
- **pedal-listener.ahk** — tiny always-on AutoHotkey v2 script. The pedal's
  key (**F24**) triggers the toggle. Shows a brief `🔊 Speakers` / `🔊 Headphones`
  tooltip. Lives in the system tray (right-click for *Toggle now / Reload / Exit*).
- **setup.ps1** — one-time installer (already run): installs the audio module +
  AutoHotkey, and drops a shortcut in your Startup folder so it auto-launches.

## ⚠️ One thing left to do: program the pedal to send F24

The PC side is fully installed and running. The pedal just needs to emit the
key the listener is waiting for.

1. Download the ikkegol **FootSwitch** configuration app (the utility that came
   with the pedal — "FootSwitch.exe" / "HID FootSwitch"). Plug the pedal in.
2. Open the app. It shows the single pedal as one button.
3. Set the pedal's action to **Keyboard**, then record/select the key **F24**.
   - If the app's key list doesn't include F24, pick another rare key/combo it
     *does* support (e.g. **F13–F24**, or **Ctrl+Alt+F12**), then update the
     hotkey in `pedal-listener.ahk` to match (see below) and double-click the
     script to reload.
4. Click **Apply / Set** to write it to the pedal's onboard memory.
5. Tap the pedal — audio should flip, with a tooltip confirming.

### Changing the key the listener waits for

In `pedal-listener.ahk`, change the line:

```ahk
F24:: DoToggle()
```

to your chosen key, e.g. `^!F12:: DoToggle()` for Ctrl+Alt+F12. Save, then
right-click the tray icon → **Reload** (or double-click the .ahk).

## Why F24?

F24 is a real key in the keyboard HID spec, but no physical keyboard has it and
nothing in Windows uses it — so the pedal can never collide with a real shortcut.

## Everyday use

- It's already running and set to start with Windows. Nothing to launch.
- Right-click the tray speaker icon for **Toggle audio now / Reload / Exit**.
- To stop it starting with Windows: delete
  `…\Start Menu\Programs\Startup\FootPedalAudioSwitch.lnk`.

## If a device gets renamed / replaced

Edit the two lines at the top of `toggle-audio.ps1`:

```powershell
$HEADPHONES = 'Elgato Wave:3'
$SPEAKERS   = 'Realtek USB2.0 Audio'
```

List current names anytime with:

```powershell
Get-AudioDevice -List | Where-Object Type -eq Playback | Select Index,Default,Name
```

## Files

| File | Purpose |
|------|---------|
| `toggle-audio.ps1`   | Switches the default playback device |
| `pedal-listener.ahk` | Catches the pedal key, runs the toggle |
| `setup.ps1`          | One-time installer + Startup registration |
| `README.md`          | This file |
