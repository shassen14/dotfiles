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

## Keybindings: switching tabs vs. workspaces

Two different layers, easy to confuse:

- **Windows Terminal tabs** (built-in WT shortcuts):
  - `Ctrl+Shift+T` — new tab · `Ctrl+Shift+W` — close tab
  - `Ctrl+Tab` / `Ctrl+Shift+Tab` — next / previous tab
  - `Ctrl+Alt+1..9` — jump straight to tab N
- **komorebi workspaces** (the tiling WM, handled by **whkd**):
  - `alt+1..9` — focus workspace · `alt+shift+1..9` — move window there
  - `alt+h/j/k/l` — focus window · `alt+shift+h/j/k/l` — move window
  - `alt+shift+b` — Brave · `alt+shift+t` — terminal · `alt+f` — toggle float

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
- **No keybindings work / whkd won't start:** whkd only reads
  `$Env:WHKD_CONFIG_HOME\whkdrc` (default `~/.config`), but this repo keeps
  `whkdrc` under `~/.config/komorebi/`. The installer sets
  `WHKD_CONFIG_HOME=~/.config/komorebi` for this reason — if whkd crashes with
  "could not load whkdrc", that env var is missing. Set it, then
  `komorebic enable-autostart --whkd` and restart komorebi.
- WSL profile in Windows Terminal assumes a WSL distro is installed.
