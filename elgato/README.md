# Elgato configs (Stream Deck + Wave Link)

These files are **not** managed by chezmoi. Stream Deck profiles and Wave Link
backups are imported through each app's GUI, not symlinked into a config dir, so
they live here as plain artifacts you commit and import by hand.

```
elgato/
  stream-deck/profiles/     # shared .streamDeckProfile exports (import on mac + windows)
  wave-link/macos/          # .wavelink backups (macOS only)
  wave-link/windows/        # .wavelink backups (Windows only — NOT shareable with macOS)
```

## What is and isn't portable

| Thing | Cross-platform? | Notes |
|---|---|---|
| Stream Deck `.streamDeckProfile` | Mostly | Bundles icons/animations. Buttons that *launch an app* or *run a command* are OS-specific — keep a mac and a windows variant of those buttons, or use cross-platform actions (open URL, hotkey, OBS/websocket). |
| Wave Link `.wavelink` backup | **No** | Elgato does not support sharing presets between macOS and Windows. Keep separate backups per OS. |

## Stream Deck workflow

**Export (do this after you change a profile):**
1. Stream Deck app → top-right `...` → **Profiles**.
2. Right-click a profile → **Export** → save into `elgato/stream-deck/profiles/`.
3. `git add -A && git commit -m "stream deck: update <profile>"`

**Import (new machine):**
1. Stream Deck app → Profiles → **Import** → pick the `.streamDeckProfile`.
2. Fix any launch/command buttons for the current OS.

## Wave Link workflow

**Export:** tray/menubar icon → right-click → **Backup and Restore** → select a
backup → **Export** → save into `elgato/wave-link/macos/` or `.../windows/`.

**Import:** same menu → **Import** → pick the `.wavelink` file for *this* OS.

## Installation

- macOS: installed via `Brewfile` (`elgato-stream-deck`, `elgato-wave-link`).
- Windows: installed via `run_once_install-packages-windows.ps1` (`Elgato.StreamDeck`, `Elgato.WaveLink`).
- Linux: Stream Deck via `StreamController` (Flatpak) in `run_once_setup-streaming.sh`; no official Wave Link.

See `docs/elgato.md` for the fuller guide.
