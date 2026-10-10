# Elgato — Stream Deck & Wave Link

Operational workflow (export/import) lives in **`elgato/README.md`**. This page
is the reference: install commands, raw config locations, and what's portable.

## Install

| OS | Stream Deck | Wave Link |
|---|---|---|
| macOS | `brew install --cask elgato-stream-deck` (in Brewfile) | `brew install --cask elgato-wave-link` (in Brewfile) |
| Windows | `winget install Elgato.StreamDeck` (in run_once) | Wave Link v3 handled specially in run_once (see note) |
| Linux | StreamController (Flatpak, in `run_once_setup-streaming.sh`) | No official Wave Link |

### Wave Link version on Windows (v2 vs v3)

**Wave Link 3 requires Windows 11.** The v3 MSIX declares `MinimumOSVersion
10.0.22000.0`, so on **Windows 10** winget reports "no applicable installer" and
falls back to **v2.0.6.3780** — the last version that runs on Win10. That fallback
is correct, not a bug: there is no v3 for Windows 10.

On **Windows 11**, v3 ships as an **MSIX**, a separate package from the old Win32
**v2**, and neither obvious upgrade route works:

- `winget upgrade Elgato.WaveLink` → exit 43 ("no applicable upgrade") — can't
  upgrade a Win32 install into an MSIX one.
- v2's **in-app "Check for updates"** only offers the newest **v2**, never v3.
- A plain `winget install` skips because it sees v2 in Add/Remove Programs as
  "already installed".

`run_once_install-packages-windows.ps1` handles both: on Win11 it removes any
legacy (non-v3) Wave Link first (needs admin — bootstrap runs elevated) then
installs the v3 MSIX; on Win10 it just installs the newest supported (v2). Mixer
settings survive either way (they live in `%APPDATA%\Elgato\WaveLink`).

By hand on **Windows 11**, in an **elevated** PowerShell:

```powershell
winget uninstall --id Elgato.WaveLink -e
winget install   --id Elgato.WaveLink -e --accept-source-agreements --accept-package-agreements
```

On **Windows 10**, `winget install --id Elgato.WaveLink -e` gets you v2 (the latest
that runs there).

## Windows audio routing (Wave Link 3)

Unlike macOS, Windows apps can't output to a **mix**. Apps play into Wave Link
**channels** (Windows *output* devices); the **mixes** (Personal, Stream) are
built inside Wave Link and appear in Windows as *input* devices.

```
Spotify      → Music       ─┐
Discord      → Discord     ─┼─► Personal Mix → speakers / headphones (what you hear)
OBS          → OBS Studio  ─┤
everything   → System      ─┴─► Stream Mix   → OBS input (what viewers hear)
else / games
```

Required setup:

- **Windows default output = `System (Elgato Virtual Audio)`**, set in Wave Link
  Settings → default output device, with **lock on**. Wave Link re-applies its
  saved default on every start, so setting it only in Windows Sound settings
  gets reverted. With System as default, any unassigned app or game is captured.
- **Headphones/speakers are Personal Mix outputs** in Wave Link — never the
  Windows default (that bypasses Wave Link entirely).
- **OBS** captures `Stream Mix (Elgato Virtual Audio)` and
  `Microphone (Elgato Virtual Audio)` as audio inputs; keep **Desktop Audio
  disabled** to avoid doubled audio. Either add both as global Mic/Aux devices
  (Settings → Audio) *or* as per-scene sources — never both. Browser-source
  alerts can leave "Control audio via OBS" off; they reach the stream via System.
- Balance stream vs. personal levels with the per-channel sliders in Wave Link,
  not in OBS.

Troubleshooting:

- **Apps play but you hear nothing** (channel meters move, mixes silent): Wave
  Link's engine stalled after a device change (`AUDCLNT_E_DEVICE_INVALIDATED` in
  the log at `%LOCALAPPDATA%\Packages\Elgato.WaveLink_*\LocalState\Logs`). Quit
  Wave Link from the tray and reopen it.
- **An app/game skips Wave Link** even though System is default: it has a stale
  per-app output override (Windows remembers one per exe, including for devices
  that no longer exist). Reset it in Settings → System → Sound → Volume mixer, or
  delete its entry under
  `HKCU\Software\Microsoft\Internet Explorer\LowRegistry\Audio\PolicyConfig\PropertyStore`
  (export the key first). Also check the game's own audio device setting is
  "Default".

## Portability summary

- **Stream Deck profiles** (`.streamDeckProfile`): shareable across mac/Windows.
  Buttons that launch apps or run commands are OS-specific — keep per-OS variants
  or prefer cross-platform actions (URLs, hotkeys, OBS websocket).
- **Wave Link backups** (`.wavelink`): **not** shareable across OS (Elgato limitation).
  Keep separate backups under `elgato/wave-link/macos/` and `.../windows/`.

## Raw config locations (for debugging — do not commit these directly)

**Stream Deck profiles (live store):**
- macOS: `~/Library/Application Support/com.elgato.StreamDeck/ProfilesV2`
- Windows: `%AppData%\Elgato\StreamDeck\ProfilesV2`

**Wave Link config:**
- macOS: `~/Library/Application Support/Elgato/WaveLink`
- Windows: `%AppData%\Elgato\WaveLink`

These live stores hold absolute paths and device serials, so we sync the
GUI **exports** in `elgato/` rather than these folders.

## Optional: auto-load Stream Deck profiles from a fixed path

Stream Deck can pull default profiles from a custom folder instead of importing
by hand:
- macOS: `defaults write com.elgato.StreamDeck custom_default_profiles "$HOME/dotfiles/elgato/stream-deck/profiles"`
- Windows: add a String value `custom_default_profiles` under
  `HKCU\Software\Elgato Systems GmbH\StreamDeck` pointing at the repo folder.

Restart Stream Deck after setting it. (Advanced — the manual import flow in
`elgato/README.md` is the supported default.)
