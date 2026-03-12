# AeroSpace Cheatsheet

AeroSpace is a tiling window manager for macOS. Windows are automatically arranged in a grid — no manual dragging needed.

**All shortcuts use `Alt` (Option ⌥) as the modifier.**

---

## Focus (move cursor between windows)
| Key | Action |
|-----|--------|
| `Alt+h` | Focus window to the left |
| `Alt+j` | Focus window below |
| `Alt+k` | Focus window above |
| `Alt+l` | Focus window to the right |

---

## Move Windows
| Key | Action |
|-----|--------|
| `Alt+Shift+h` | Move window left |
| `Alt+Shift+j` | Move window down |
| `Alt+Shift+k` | Move window up |
| `Alt+Shift+l` | Move window right |

---

## Resize
| Key | Action |
|-----|--------|
| `Alt+-` | Shrink window (smart, -50px) |
| `Alt+=` | Grow window (smart, +50px) |

---

## Layout
| Key | Action |
|-----|--------|
| `Alt+/` | Toggle tiles layout (horizontal ↔ vertical) |
| `Alt+,` | Toggle accordion layout |
| `Alt+f` | Toggle float / tiling for current window |

**Tiles** = traditional tiling grid. **Accordion** = stacked windows, only one visible at a time (peek with focus keys).

---

## Workspaces
| Key | Action |
|-----|--------|
| `Alt+1` – `Alt+9` | Switch to workspace 1–9 |
| `Alt+Shift+1` – `Alt+Shift+9` | Move current window to workspace 1–9 |
| `Alt+Tab` | Toggle back to previous workspace |
| `Alt+Shift+Tab` | Move workspace to next monitor |

**Multi-monitor layout** (set dynamically by `assign_workspaces.sh`):
- 1 monitor → workspaces 1–9 all on monitor 1
- 2 monitors → workspaces 1–4 on primary, 5–9 on secondary
- 3+ monitors → workspaces 1–3 / 4–6 / 7–9

---

## Monitors
| Key | Action |
|-----|--------|
| `Alt+Shift+→` | Focus next monitor |
| `Alt+Shift+←` | Focus previous monitor |
| `Alt+Shift+m` | Reassign workspaces (run after plugging/unplugging monitors) |

---

## Window Joining (merge into container)
| Key | Action |
|-----|--------|
| `Alt+Ctrl+h` | Join with window to the left |
| `Alt+Ctrl+j` | Join with window below |
| `Alt+Ctrl+k` | Join with window above |
| `Alt+Ctrl+l` | Join with window to the right |

---

## Apps & System
| Key | Action |
|-----|--------|
| `Alt+Enter` | Open Alacritty |
| `Alt+Shift+b` | Open Brave Browser |
| `Alt+Shift+q` | Close focused window |
| `Alt+r` | Reload AeroSpace config |

---

## Service Mode (`Alt+Shift+;`)
A temporary mode for special operations. Press to enter, `Esc` or `r` to exit.

| Key (in service mode) | Action |
|-----------------------|--------|
| `Esc` / `r` | Flatten workspace tree + exit service mode |
| `f` | Toggle float + exit |
| `Backspace` | Close all windows except current |
| `Alt+Shift+h/j/k/l` | Join with neighbor + exit |
| `↑` / `↓` | Volume up / down |
| `Shift+↓` | Mute |

---

## Tips
- AeroSpace ignores gaps for the MacBook notch area automatically
- After connecting a new monitor, press `Alt+Shift+m` to reassign workspaces
- Windows that don't tile well (dialogs, etc.) can be floated with `Alt+f`
- Run `aerospace list-windows --all` in terminal to debug window state
