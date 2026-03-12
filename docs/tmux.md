# Tmux Cheatsheet

**Prefix key: `Ctrl+a`** (not the default `Ctrl+b`)

> Write `C-a` + `key` means: hold Ctrl, press a, release both, then press key.

---

## Sessions

| Key / Command           | Action                                 |
| ----------------------- | -------------------------------------- |
| `tmux new -s <name>`    | Create a named session                 |
| `tmux ls`               | List sessions                          |
| `tmux attach -t <name>` | Attach to a session                    |
| `C-a d`                 | Detach from session (leave it running) |
| `C-a $`                 | Rename current session                 |
| `C-a s`                 | Interactive session switcher           |

---

## Windows (tabs)

| Key       | Action                                 |
| --------- | -------------------------------------- |
| `C-a c`   | Create new window                      |
| `C-a ,`   | Rename current window                  |
| `C-a w`   | Interactive window list                |
| `C-a 1–9` | Switch to window by number (1-indexed) |
| `C-a C-h` | Previous window                        |
| `C-a C-l` | Next window                            |
| `C-a C-a` | Toggle last window                     |
| `C-a X`   | Kill current window (no confirmation)  |

---

## Panes (splits)

| Key           | Action                                    |
| ------------- | ----------------------------------------- |
| `C-a \|`      | Split vertically (side by side)           |
| `C-a -`       | Split horizontally (top/bottom)           |
| `C-a h/j/k/l` | Move focus left/down/up/right (vim-style) |
| `C-a H/J/K/L` | Resize pane (repeatable, 5 cells)         |
| `C-a z`       | Zoom/unzoom pane (fullscreen toggle)      |
| `C-a x`       | Kill current pane (no confirmation)       |
| `C-a >`       | Swap pane with next                       |
| `C-a <`       | Swap pane with previous                   |
| `C-a q`       | Show pane numbers (press number to jump)  |

---

## Copy Mode (vi-style)

| Key          | Action                                 |
| ------------ | -------------------------------------- |
| `C-a [`      | Enter copy mode                        |
| `v`          | Begin selection                        |
| `C-v`        | Toggle rectangle selection             |
| `y`          | Yank (copy) selection + exit copy mode |
| `Enter`      | Same as `y`                            |
| `q` or `Esc` | Exit copy mode                         |
| `C-a p`      | Paste buffer                           |

Navigation in copy mode uses **vim keys**: `h/j/k/l`, `/` to search, `n/N` for next/prev match.

---

## Misc

| Key     | Action                    |
| ------- | ------------------------- |
| `C-a r` | Reload tmux config        |
| `C-a :` | Enter tmux command prompt |
| `C-a ?` | Show all keybindings      |
| `C-a t` | Show clock                |

---

## Plugins (TPM)

| Key         | Action                |
| ----------- | --------------------- |
| `C-a I`     | Install plugins       |
| `C-a U`     | Update plugins        |
| `C-a Alt+u` | Remove unused plugins |

**Installed plugins:**

- `tmux-sensible` — sane defaults
- `tmux-resurrect` — save/restore sessions across reboots (`C-a C-s` save, `C-a C-r` restore)
- `tmux-continuum` — auto-save every 15 min, auto-restore on tmux start

---

## Tips

- Mouse is **enabled** — click to select panes/windows, scroll to scroll history
- Sessions persist when you close the terminal; reattach with `tmux attach`
- `C-a z` to zoom a pane, work in it, `C-a z` again to unzoom
