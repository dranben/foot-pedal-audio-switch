# 🦶🔊 Foot Pedal Audio Switch

**Tap a USB foot pedal to instantly switch your Windows sound between two outputs** —
headphones and speakers, for example. It runs silently in the background and
starts with Windows, so switching audio is always one foot-tap away. No more
digging through the sound menu mid-game, mid-call, or mid-stream.

![Platform](https://img.shields.io/badge/platform-Windows%2010%20%2F%2011-0078D6?logo=windows)
![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2-334b4c?logo=autohotkey)
![PowerShell](https://img.shields.io/badge/PowerShell-5%2B-5391FE?logo=powershell&logoColor=white)
![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)

```
 ┌──────────┐   sends    ┌─────────────────────┐   runs   ┌──────────────────┐
 │  foot    │ ──F24──▶   │ pedal-listener.ahk  │ ──────▶  │ toggle-audio.ps1 │
 │  pedal   │            │  (always running)   │          │  flips default   │
 └──────────┘            └─────────────────────┘          │  playback device │
                                                          └──────────────────┘
   tap  ───────────────────────────────────────────────▶  🔊 Headphones ⇄ Speakers
```

Built for an [iKKEGOL](https://www.ikkegol.com) single mechanical foot pedal +
an Elgato Wave:3 and a Realtek USB output, but it works with **any USB foot
pedal that can send a keystroke** and **any two playback devices**.

---

## Why

Windows has no built-in hotkey to change the default audio output. If you
regularly bounce between, say, headphones for focus and speakers to share
sound, you're stuck clicking through Settings every time. A foot pedal makes it
a reflex — your hands never leave the keyboard.

## Features

- **One-tap toggle** between any two playback devices.
- **Follows you everywhere** — sets both the default *and* the "communication"
  device, so Discord / Teams / Zoom switch too.
- **Silent & always-on** — tiny tray app, auto-starts at login, no console flashes.
- **Zero-edit setup** — an interactive picker writes your device choices; no
  code editing needed.
- **Robust** — matches devices by name, so it keeps working when Windows
  reshuffles device numbers.
- **Brief on-screen confirmation** (`🔊 Speakers` / `🔊 Headphones`) on each tap.

## Requirements

- Windows 10 or 11
- A USB foot pedal that can be programmed to send a keystroke (e.g. iKKEGOL /
  PCsensor). Any programmable pedal, macro key, or even a spare keyboard key works.
- The setup script installs the rest for you (AutoHotkey v2 + the
  [AudioDeviceCmdlets](https://github.com/frgnca/AudioDeviceCmdlets) module).

## Quick start

```powershell
git clone https://github.com/dranben/foot-pedal-audio-switch.git
cd foot-pedal-audio-switch

# 1. Pick your two audio devices (writes devices.txt) — no code editing:
powershell -ExecutionPolicy Bypass -File .\choose-devices.ps1

# 2. Install dependencies + register it to start with Windows + run it now:
powershell -ExecutionPolicy Bypass -File .\setup.ps1
```

Then **program your pedal to send `F24`** (see below) and you're done — tap to switch.

## Program the pedal

The listener waits for the **F24** key (a real key that exists in the HID spec
but no physical keyboard has and nothing in Windows uses — so it can never
collide with a real shortcut). Point your pedal at it:

1. Install your pedal's configuration app. For iKKEGOL / PCsensor pedals that's
   **FootSwitch**, from <https://www.ikkegol.com/downloads.html>.
2. Plug in the pedal, open the app, set the pedal action to **Keyboard**, and
   assign the key **F24**. Click **Apply / Set** to save it to the pedal.
3. Tap the pedal — your audio flips, with a `🔊` confirmation.

> **App doesn't offer F24?** Pick any rare key/combo it *does* support
> (F13–F24, or e.g. Ctrl+Alt+F12), then change the `F24:: DoToggle()` line in
> [`pedal-listener.ahk`](pedal-listener.ahk) to match and reload it from the tray.

## Everyday use

- It's already running and starts with Windows — nothing to launch.
- Right-click the tray speaker icon for **Toggle audio now / Reload / Exit**.
- Change devices anytime: re-run `choose-devices.ps1` (or edit
  [`devices.txt`](devices.txt)) and reload from the tray.

## Configuration

`devices.txt` holds the two outputs (first two non-comment lines = device A and
B, matched as name substrings):

```
Elgato Wave:3
Realtek USB2.0 Audio
```

List current device names anytime:

```powershell
Get-AudioDevice -List | Where-Object Type -eq Playback | Select Index,Default,Name
```

## How it works

| File | Purpose |
|------|---------|
| [`pedal-listener.ahk`](pedal-listener.ahk) | Tiny always-on AutoHotkey v2 tray app. The pedal's key (F24) triggers the toggle. |
| [`toggle-audio.ps1`](toggle-audio.ps1) | Flips the default playback (+ communication) device. Reads `devices.txt`. |
| [`choose-devices.ps1`](choose-devices.ps1) | Interactive picker → writes `devices.txt`. |
| [`setup.ps1`](setup.ps1) | One-shot installer: deps + Startup shortcut + launch. |
| [`devices.txt`](devices.txt) | Your two devices. |

## Troubleshooting

- **Nothing happens on tap** → Confirm the pedal sends F24: open Notepad and
  tap it (F24 prints nothing, so instead test with the tray menu →
  *Toggle audio now*; if that works, the pedal key is the issue — reprogram it).
- **"device not found"** → Names changed or the device is unplugged; re-run
  `choose-devices.ps1`.
- **Listener not running** → Re-run `setup.ps1`, or double-click
  `pedal-listener.ahk`.

## Uninstall

- Delete the Startup shortcut: `…\Start Menu\Programs\Startup\FootPedalAudioSwitch.lnk`
- Right-click the tray icon → **Exit**, then delete the folder.
- Optionally uninstall AutoHotkey and the AudioDeviceCmdlets module.

## Credits

- Default-device switching via [frgnca/AudioDeviceCmdlets](https://github.com/frgnca/AudioDeviceCmdlets).
- Hotkey listening via [AutoHotkey v2](https://www.autohotkey.com/).

## License

[MIT](LICENSE) — free to use, modify, and share.

<sub>Keywords: switch default audio output device Windows hotkey · foot pedal
audio switcher · change playback device shortcut · AutoHotkey audio toggle ·
iKKEGOL / PCsensor FootSwitch · Elgato Wave / Realtek · Discord communication
device switch.</sub>
