# Windows setup

Bringing a Windows PC up to parity with the macOS/Linux dotfiles. The Windows
support already exists in the repo — this is the runbook for *running* it.

## What you get

| macOS/Linux | Windows |
|---|---|
| Homebrew / apt | winget (`run_once_install-packages-windows.ps1`) |
| AeroSpace / i3 | komorebi + whkd (`private_dot_config/komorebi/`) |
| Ghostty / Alacritty | Windows Terminal (`private_dot_config/windows-terminal/`) |
| `.zshrc` | PowerShell profile (`Documents/PowerShell/Microsoft.PowerShell_profile.ps1`) |

## First-time bootstrap

1. Install **Git** and **PowerShell 7** (so you have a clean shell + git):
   ```powershell
   winget install --id Git.Git --exact
   winget install --id Microsoft.PowerShell --exact
   ```
2. Clone the repo:
   ```powershell
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

Start the tiling WM:
```powershell
komorebic start --whkd
```
Add `komorebic start --whkd` to a startup task if you want it on login.

## Elgato

Stream Deck and Wave Link install via winget during bootstrap. Import your
profiles/backups afterward — see `docs/elgato.md` and `elgato/README.md`.

## Known gaps / validate on first run

- winget package IDs occasionally change — if one fails, `winget search <name>`
  and update the ID in `run_once_install-packages-windows.ps1.tmpl`.
- komorebi keybindings mirror AeroSpace (alt+hjkl, alt+1-9); confirm they don't
  collide with anything you run.
- WSL profile in Windows Terminal assumes a WSL distro is installed.
