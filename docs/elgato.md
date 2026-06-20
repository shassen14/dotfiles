# Elgato — Stream Deck & Wave Link

Operational workflow (export/import) lives in **`elgato/README.md`**. This page
is the reference: install commands, raw config locations, and what's portable.

## Install

| OS | Stream Deck | Wave Link |
|---|---|---|
| macOS | `brew install --cask elgato-stream-deck` (in Brewfile) | `brew install --cask elgato-wave-link` (in Brewfile) |
| Windows | `winget install Elgato.StreamDeck` (in run_once) | `winget install Elgato.WaveLink` (in run_once) |
| Linux | StreamController (Flatpak, in `run_once_setup-streaming.sh`) | No official Wave Link |

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
