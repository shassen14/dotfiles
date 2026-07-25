# Windows setup

Bringing a Windows PC up to parity with the macOS/Linux dotfiles. The Windows
support already exists in the repo — this is the runbook for *running* it.

## What you get

| macOS/Linux | Windows |
|---|---|
| Homebrew / apt | winget (`run_once_install-packages-windows.ps1`) |
| AeroSpace / i3 | komorebi + whkd (`private_dot_config/komorebi/`) |
| SketchyBar / polybar | YASB (`private_dot_config/yasb/`) |
| Ghostty / Alacritty | Windows Terminal (`AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json`) |
| `.zshrc` | PowerShell profile (`Documents/PowerShell/Microsoft.PowerShell_profile.ps1`) |
| Brave / Bitwarden / Discord / Spotify / Obsidian / OBS / OrcaSlicer | winget (`run_once_install-packages-windows.ps1`) |

> Windows Terminal **only** reads its `LocalState\settings.json` — a config under
> `~/.config/windows-terminal/` is ignored. That's why the source lives at the
> `AppData\Local\Packages\...\LocalState` target above; chezmoi writes it to the
> exact path WT loads.

## Use PowerShell 7, not Windows PowerShell 5.1

Windows ships with **Windows PowerShell 5.1** (the default "PowerShell" on
Windows 10). This repo's profile, aliases, and `~/.local/bin` PATH setup target
**PowerShell 7** (`pwsh`) — its profile lives in `Documents\PowerShell\`, while
5.1 reads `Documents\WindowsPowerShell\` and won't load any of it.

- Check your shell: `$PSVersionTable.PSVersion` (5.x = the old one).
- Launch v7 by running `pwsh`, or open **PowerShell 7** from the Start menu.
- The managed Windows Terminal config already sets **PowerShell 7** as the
  default profile, so new tabs/windows open `pwsh` automatically. (Override:
  Settings `Ctrl+,` → Startup → Default profile.)
- Note: anything added to the persistent user PATH works in *both* shells, so a
  binary like `claude` may run in 5.1 even though the profile didn't load.

## Keybindings

Two different layers, easy to confuse:

- **Windows Terminal tabs** (built-in WT shortcuts):
  - `Ctrl+Shift+T` — new tab · `Ctrl+Shift+W` — close tab
  - `Ctrl+Tab` / `Ctrl+Shift+Tab` — next / previous tab
  - `Ctrl+Alt+1..9` — jump straight to tab N
- **komorebi** (the tiling WM, handled by **whkd**) — full reference below.

The komorebi bindings live in `private_dot_config/komorebi/whkdrc` and mirror the
macOS AeroSpace bindings (`dot_aerospace.toml.tmpl`) and Linux i3 (`i3/config.tmpl`)
so the same muscle memory works on every machine. `alt` is the modifier (= the macOS
`alt`/Linux `$mod`).

| Action | Windows (whkd) | macOS / Linux equivalent |
|---|---|---|
| Terminal | `alt+shift+t` | same |
| Browser (Brave) | `alt+shift+b` | same |
| File manager | `alt+shift+f` | same |
| Close window | `alt+shift+q` | same |
| Focus left/down/up/right | `alt+h/j/k/l` | same |
| Move window | `alt+shift+h/j/k/l` | same |
| Shrink / grow | `alt+-` / `alt+=` | same |
| Toggle float | `alt+f` | same |
| Fullscreen / monocle | `alt+shift+enter` | same |
| Cycle layout | `alt+/` | same |
| Workspace N (left mon 1-4, right mon 5-9) | `alt+1..9` | same |
| Move window to workspace N | `alt+shift+1..9` | same |
| Cycle monitor | `alt+shift+right` | same |
| Focus last workspace | `alt+tab` | same (back-and-forth) |
| Lock + sleep | `alt+shift+s` | same |
| Reload config (soft) | `alt+shift+r` | `alt+shift+r` |
| Restart komorebi (hard) | `alt+ctrl+r` | — (Windows-specific) |

> **`alt+shift+s` = lock + sleep.** It locks the screen, then calls
> `SetSuspendState` to sleep the machine — matching Linux's `lock_and_suspend.sh`
> and macOS's `CGSession -suspend`. If your PC **hibernates instead of sleeping**,
> run `powercfg /hibernate off` once (rundll32's `SetSuspendState` follows the
> system hibernate setting). Windows requires sign-in on wake by default, so the
> screen stays secured.

> **Dual-monitor layout:** workspaces 1-4 are pinned to the left monitor and 5-9
> to the right via `komorebi.json` (`monitors[]` split + `display_index_preferences`
> by serial number, so they don't swap on reboot). Because each workspace lives on
> a specific monitor, the `alt+N` keys use `focus-monitor-workspace <mon> <ws>`
> rather than a bare workspace index. If your two monitors are physically swapped
> from this, flip the two serials in `display_index_preferences` (`komorebic
> monitor-information` lists them — the one with a negative `left` is on the left).

If the `alt+...` bindings do nothing, **whkd isn't running** — see Known gaps.
Note `alt+tab` is rebound by komorebi to "focus last workspace," so it no longer
does the Windows app-switcher while whkd is active.

## First-time bootstrap

1. Install **Git** and **PowerShell 7** (so you have a clean shell + git):
   ```powershell
   winget install --id Git.Git --exact
   winget install --id Microsoft.PowerShell --exact
   ```
2. Clone the repo **into your home folder** (`C:\Users\<you>`, the Windows
   equivalent of `~`) — *not* the Desktop or Downloads. The chezmoi config hard-
   codes the source as `~/dotfiles/home`, so the repo must live at
   `C:\Users\<you>\dotfiles`. A fresh PowerShell prompt already starts in your
   home folder, so just run:
   ```powershell
   cd $HOME
   git clone https://github.com/shassen14/dotfiles.git
   cd dotfiles
   ```
3. Run the bootstrap from an **elevated** PowerShell prompt (Run as Administrator —
   komorebi/whkd and some winget installs need it):
   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
   .\bootstrap.ps1
   ```
   This installs chezmoi, points it at the local `home/` source, and runs
   `chezmoi apply -v` — which triggers `run_once_install-packages-windows.ps1`
   (all the winget packages, including Stream Deck + Wave Link).

## After bootstrap

```powershell
chezmoi diff          # preview pending changes
chezmoi apply -v      # re-apply
```

Start the tiling WM (no reboot needed — tiling kicks in immediately):
```powershell
komorebic start --whkd            # start now
komorebic enable-autostart --whkd # start automatically on every login
```

## Status bar (YASB)

The Windows status bar is **YASB** (`AmN.yasb`), themed to match SketchyBar
(macOS) and polybar (Linux): **Tokyonight Night** palette + **FiraCode Nerd
Font**, with the same module set (workspaces · layout · window | media | cpu ·
memory · volume · battery · clock). Config lives in `~/.config/yasb/`
(`config.yaml` + `styles.css`).

The install script registers login autostart and starts it. Manual control:
```powershell
yasbc start          # start the bar
yasbc reload         # reload after editing config.yaml / styles.css
yasbc enable-autostart
```
Workspace numbers come from komorebi, so komorebi must be running for that
widget to populate.

## Debloat (`run_once_debloat-windows.ps1`)

A one-time script that strips Windows consumer bloat and applies privacy/QoL
tweaks. It's **conservative and reversible** — every removed app reinstalls from
the Store, every registry value flips back. Because this box is for gaming +
video editing, **Xbox / Game Bar, Media Player, Photos, Snipping Tool, Paint,
Calculator, Terminal, Store and all user-installed apps are kept.** What it does:

- **Removes AppX bloat:** Bing News/Weather, Solitaire, Candy Crush, To Do,
  Office Hub, new Outlook, Maps, People, Feedback Hub, Get Help, Tips, Mixed
  Reality Portal, 3D Viewer, Power Automate, Dev Home, Cortana, consumer Teams,
  Clipchamp, and assorted preinstalled third-party junk.
- **QoL:** show file extensions + hidden files, dark mode, hide Widgets / Chat /
  Task View / taskbar search box, restore the Win11 classic right-click menu.
- **Privacy:** disable advertising ID, tailored experiences, background UWP apps,
  and the "suggested content" ads in Start / Settings / lock screen. Run elevated
  (the bootstrap is) to also lower telemetry and disable activity-history upload.

It restarts Explorer at the end so the taskbar/theme changes apply immediately.
Re-run by bumping the `version:` comment then `chezmoi apply -v`. To undo a
specific tweak, flip its registry value back (or reinstall an app from the Store).

> Deliberately **not** included: power-plan / GPU-scheduling changes, and any
> dev tooling or WSL. Revisit if this machine ever becomes a dev box.

## Elgato

Stream Deck and Wave Link install via winget during bootstrap. Import your
profiles/backups afterward — see `docs/elgato.md` and `elgato/README.md`.

## Known gaps / validate on first run

- winget package IDs occasionally change — if one fails, `winget search <name>`
  and update the ID in `run_once_install-packages-windows.ps1.tmpl`.
- **"The system cannot find the path specified." / chezmoi points at
  `~/.local/share/chezmoi`**: chezmoi lost track of the source dir (e.g. the repo
  isn't in your home folder, or `init --source` didn't persist). Re-run apply with
  an explicit source once to rewrite the config:
  ```powershell
  cd $HOME\dotfiles
  chezmoi apply --source "$HOME\dotfiles\home" -v
  chezmoi source-path   # should now print C:\Users\<you>\dotfiles\home
  ```
- komorebi keybindings mirror AeroSpace (alt+hjkl, alt+1-9); confirm they don't
  collide with anything you run.
- **komorebi ignores the config / whkd won't start (config-home bug):** both
  komorebi and whkd default to looking in `~` for their config, but this repo
  keeps `komorebi.json` + `whkdrc` under `~/.config/komorebi/`. If the
  `KOMOREBI_CONFIG_HOME` / `WHKD_CONFIG_HOME` env vars aren't set, komorebi
  silently runs on **built-in defaults** (windows tile over the YASB bar, wrong
  workspaces) and whkd crashes ("could not load whkdrc"). The installer sets both
  to `~/.config/komorebi`. Verify with `komorebic check` (should say
  "KOMOREBI_CONFIG_HOME detected" and find both files). The autostart shortcut
  bakes the path in: `komorebic enable-autostart --config <path>\komorebi.json --whkd`.
- **komorebi won't start from a script/automation shell** (`failed call to
  AllowSetForegroundWindow`): it needs an interactive foreground session. Start it
  from your own terminal (`komorebic start --config ~/.config/komorebi/komorebi.json --whkd`)
  or just let the login autostart handle it.
- After editing `komorebi.json`, reload with `komorebic reload-configuration`
  (bound to `alt+shift+r`); some changes (work-area offset) need a full
  `komorebic stop --whkd` + `start ... --whkd`.
- WSL profile in Windows Terminal assumes a WSL distro is installed.
