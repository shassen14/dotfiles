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
