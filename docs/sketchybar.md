# SketchyBar Cheatsheet

SketchyBar is a custom macOS status bar that replaces the default menu bar.

---

## What's Displayed

### Left Side
| Item | Description |
|------|-------------|
| **Spaces (1–9)** | AeroSpace workspace indicators — highlights the active workspace. Click to switch. |
| **Front App** | Name of the currently focused application |

### Right Side
| Item | Description |
|------|-------------|
| **Spotify** | Current track + artist (shows only when Spotify is playing) |
| **CPU** | CPU usage % |
| **Volume** | Current audio output volume |
| **Battery** | Battery % + charging indicator |
| **Calendar** | Day of week + date |
| **Clock** | Current time (HH:MM) |

---

## Interaction
- **Click a workspace number** — switches to that AeroSpace workspace
- The bar updates **every second** for clock/battery

---

## Multi-Monitor Behavior
SketchyBar detects whether the built-in MacBook display is active:
- **Built-in display (lid open):** notch padding = 200px (avoids the notch)
- **External display only (clamshell):** notch padding = 0px

This runs automatically when SketchyBar starts.

---

## Managing SketchyBar

```bash
# Restart SketchyBar (after config changes)
brew services restart sketchybar

# Check if running
brew services list | grep sketchybar

# Reload config without restarting
sketchybar --reload

# Manually trigger workspace update (usually auto-triggered by AeroSpace)
sketchybar --trigger aerospace_workspace_changed FOCUSED_WORKSPACE="1"
```

---

## Config Location
`~/.config/sketchybar/` (managed by Chezmoi)

```
sketchybar/
  sketchybarrc          # Main config (bar appearance, plugin paths)
  variables.sh          # Colors, fonts, padding constants
  items/                # One file per bar item
    spaces.sh           # Workspace indicators
    front_app.sh        # Active app name
    spotify.sh          # Spotify now playing
    cpu.sh              # CPU usage
    volume.sh           # Volume
    battery.sh          # Battery
    clock.sh            # Clock
    calendar.sh         # Date
  plugins/              # Event handlers / update scripts for each item
```

---

## Tips
- If workspaces look wrong after connecting a monitor, press **`Alt+Shift+m`** in AeroSpace — this reassigns workspaces and SketchyBar will update automatically
- To change colors/fonts, edit `~/.config/sketchybar/variables.sh` then restart SketchyBar
- SketchyBar is started automatically at login via Homebrew services
