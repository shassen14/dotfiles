# Cross-Platform Command Reference

Equivalent commands for the same task across **macOS**, **Linux**, and **Windows**.

Where possible, these are wrapped in shared aliases (see `home/dot_aliases.sh.tmpl`)
so the command you type is **identical on every OS** — only the implementation differs.

> Convention: `wifi`, `wific`, `wifi-status` etc. are the aliases. The columns below
> show what they expand to so you can run the raw command when an alias isn't available
> (e.g. on a fresh machine before `chezmoi apply`).

---

## WiFi / Network

| Alias         | macOS                                            | Linux (NetworkManager)               | Windows (PowerShell / cmd)              |
| ------------- | ------------------------------------------------ | ------------------------------------ | --------------------------------------- |
| `wifi`        | `system_profiler SPAirPortDataType`              | `nmcli device wifi list --rescan yes`| `netsh wlan show networks mode=bssid`   |
| `wific "SSID"`| `networksetup -setairportnetwork en0 "SSID" [pw]`| `nmcli device wifi connect "SSID" --ask` | `netsh wlan connect name="SSID"`    |
| `wifi-status` | `networksetup -getairportnetwork en0`            | `nmcli device status`                | `netsh wlan show interfaces`            |
| `wifi-saved`  | `networksetup -listpreferredwirelessnetworks en0`| `nmcli connection show`              | `netsh wlan show profiles`              |
| `wifi-on`     | `networksetup -setairportpower en0 on`           | `nmcli radio wifi on`                | `netsh interface set interface Wi-Fi enable` |
| `wifi-off`    | `networksetup -setairportpower en0 off`          | `nmcli radio wifi off`               | `netsh interface set interface Wi-Fi disable`|

**Quick connect (Linux/Ubuntu):**

```bash
wifi              # list nearby networks, note the SSID
wific "CoffeeShop"  # prompts for the password, then connects
```

**Notes**

- macOS `en0` is usually the WiFi interface. Confirm with `networksetup -listallhardwareports`.
- Windows: the `wific "SSID" password` function auto-creates a WPA2-PSK profile if the
  network is new, then connects. For an already-known network just use `wific "SSID"`.
- All three platforms expose the same function names (`wifi`, `wific`, `wifi-status`, …):
  macOS/Linux via `home/dot_aliases.sh.tmpl`, Windows via the PowerShell profile at
  `home/Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl`.

---

## System Update

| Alias    | macOS                                  | Linux (apt/dnf/pacman)                                  | Windows                          |
| -------- | -------------------------------------- | ------------------------------------------------------- | -------------------------------- |
| `update` | `brew update && brew upgrade && cleanup` | `sudo apt full-upgrade` / `dnf upgrade` / `pacman -Syu` | `winget upgrade --all` (manual)  |

---

## Dotfiles Sync (chezmoi — identical everywhere)

| Alias         | Action                                      |
| ------------- | ------------------------------------------- |
| `dots-push`   | `chezmoi re-add` → commit → push            |
| `dots-pull`   | `chezmoi update`                            |
| `dots-diff`   | `chezmoi diff`                              |
| `dots-status` | `chezmoi status`                            |

These work the same on all platforms because chezmoi is cross-platform.

---

## Window Manager Hotkeys

The tiling WM differs per OS — **AeroSpace** (macOS), **i3** (Linux), **komorebi + whkd**
(Windows) — but the **key letters are identical** so the muscle memory transfers. Only the
**modifier** changes, because each OS reserves a different key for itself:

| Platform | WM                | Modifier (`mod`)        | Config file                                   |
| -------- | ----------------- | ----------------------- | --------------------------------------------- |
| macOS    | AeroSpace         | **Alt** / Option (`⌥`)  | `home/dot_aerospace.toml.tmpl`                |
| Linux    | i3                | **Super** (`⊞`, Mod4)   | `home/private_dot_config/i3/config.tmpl`      |
| Windows  | komorebi + whkd   | **Alt**                 | `home/private_dot_config/komorebi/whkdrc`     |

> Why the modifier differs: macOS reserves Cmd (Spotlight, Cmd-Tab, app shortcuts) and Windows
> reserves the Win key (Win+L, Win+E…), so both WMs use **Alt**. On Linux **Alt** collides with
> GTK app menus (Alt+F = File), so i3 uses the free **Super** key. The action keys below are the
> same everywhere — just swap which modifier you hold.

### Apps & Session

| Action               | Hotkey                | Notes                                                              |
| -------------------- | --------------------- | ------------------------------------------------------------------ |
| Terminal             | `mod + shift + t`     | macOS: Ghostty · Linux: `$term` (also `mod+Enter`) · Win: `wt`     |
| Browser              | `mod + shift + b`     | macOS: Brave · Linux: `$browser` · Win: Edge                       |
| File manager         | `mod + shift + f`     | macOS: Finder · Linux: thunar · Win: explorer.exe                  |
| App launcher / search| `mod + d`             | **Linux only** (rofi). macOS → Spotlight `⌘Space`; Win → Start / `⊞ + S` (OS-native) |
| Close window         | `mod + shift + q`     |                                                                    |
| Reload / restart WM  | `mod + shift + r`     | Linux also has `mod + shift + c` (reload config only)              |
| Lock / suspend       | `mod + shift + s`     | macOS+Linux: lock then suspend · Win: lock only                    |

### Window & Layout

| Action               | Hotkey                | Notes                                                              |
| -------------------- | --------------------- | ------------------------------------------------------------------ |
| Toggle float         | `mod + f`             | Linux also accepts `mod + shift + space`                           |
| Toggle fullscreen    | `mod + shift + Enter` | Win: monocle layout                                                |
| Shrink window        | `mod + minus`         |                                                                    |
| Grow window          | `mod + equal`         |                                                                    |
| Cycle layout         | macOS `alt+/` / `alt+,` · Linux `mod+s/w/e` · Win `alt+/` | Per-WM layout sets differ |

### Focus, Move & Workspaces

| Action                       | Hotkey                          |
| ---------------------------- | ------------------------------- |
| Focus window (left/down/up/right) | `mod + h / j / k / l`      |
| Move window                  | `mod + shift + h / j / k / l`   |
| Switch to workspace 1–9      | `mod + 1` … `mod + 9`           |
| Move window to workspace 1–9 | `mod + shift + 1` … `mod + shift + 9` |
| Focus next/prev monitor      | `mod + shift + → / ←`           |

**Platform-specific extras** (no cross-platform equivalent):

- **macOS** — `alt+shift+m` reassign workspaces to monitors; `alt+ctrl+hjkl` join windows;
  `alt+shift+;` service mode.
- **Linux** — `mod+p` screenshot region (flameshot), `mod+shift+p` full screenshot; media/volume
  keys via `XF86Audio*`. (macOS/Windows screenshot is OS-native: `⌘⇧4` / `⊞+⇧+S`.)

> Keeping these in sync: the three config files above must change together. When you rebind one,
> update the other two with the **same key letter** and refresh the table in this section.

---

## Adding a new platform-specific command

1. Add the alias to `home/dot_aliases.sh.tmpl` (macOS/Linux) inside an
   `{{`{{ if eq .chezmoi.os "darwin" }}`}}` / `{{`{{ else }}`}}` block, keeping the **alias name identical**
   across branches so the interface stays uniform.
2. Add a row to the matching table here with the raw command per OS.
3. `chezmoi apply` and reload your shell.
