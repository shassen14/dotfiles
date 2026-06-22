# Dotfiles

Cross-platform dotfiles for macOS and Linux managed entirely with **Chezmoi**.

## How it works

| File/Dir                                    | Purpose                                                                         |
| ------------------------------------------- | ------------------------------------------------------------------------------- |
| `bootstrap.sh`                              | Fresh-machine setup: installs Homebrew (macOS) + chezmoi, then applies dotfiles |
| `home/`                                     | Chezmoi source — everything here gets applied to `~`                            |
| `home/private_dot_config/homebrew/Brewfile` | macOS packages (`brew bundle`)                                                  |
| `home/run_once_install-packages-darwin.sh`  | Runs `brew bundle` once on macOS                                                |
| `home/run_once_install-packages-linux.sh`   | Installs packages via apt/dnf/pacman on Linux                                   |

## Fresh machine

Clone the repo and run bootstrap — the working copy becomes the chezmoi source directly (no separate clone):

```bash
git clone https://github.com/shassen14/dotfiles.git ~/dotfiles
~/dotfiles/bootstrap.sh
```

Or pipe directly (chezmoi clones from the remote instead):

```bash
curl -fsSL https://raw.githubusercontent.com/shassen14/dotfiles/main/bootstrap.sh | bash
```

### Windows

From an **elevated** PowerShell prompt (Run as administrator). Clone into your
home folder (`C:\Users\<you>`) — *not* the Desktop — since chezmoi's `sourceDir`
is hardcoded to `~/dotfiles/home`:

```powershell
winget install --id Git.Git --exact
cd $HOME
git clone https://github.com/shassen14/dotfiles.git
cd dotfiles
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\bootstrap.ps1
```

This installs chezmoi, points it at the local `home/` source, and runs `chezmoi apply` — which installs winget packages and lays down the PowerShell profile, Windows Terminal, and komorebi/whkd configs. See **[`docs/windows.md`](docs/windows.md)** for the full runbook and troubleshooting.

## Day-to-day

A `Makefile` is included for common workflows:

```bash
make help     # list all targets
make apply    # chezmoi apply -v
make update   # pull remote changes and apply
make push     # re-add changed files, commit, and push
make diff     # preview pending changes
make install  # full bootstrap (./bootstrap.sh)
```

Or use chezmoi directly:

```bash
# Edit a dotfile and re-apply
chezmoi edit ~/.zshrc
chezmoi apply

# Add a new package (macOS)
# 1. Edit home/private_dot_config/homebrew/Brewfile
# 2. Bump the version comment in home/run_once_install-packages-darwin.sh
# 3. chezmoi apply
```

## Platforms

- **macOS**: AeroSpace (tiling WM) + SketchyBar + Homebrew
- **Linux**: i3wm + apt/dnf/pacman (Debian, Fedora, Arch)
- **Windows**: komorebi + whkd (tiling WM) + winget + Windows Terminal — see [`docs/windows.md`](docs/windows.md)

## Structure

```
home/
  dot_zshrc.tmpl                          → ~/.zshrc
  dot_aliases.tmpl                        → ~/.aliases
  private_dot_config/
    nvim/                                 → ~/.config/nvim/   (LazyVim)
    alacritty/alacritty.toml.tmpl         → ~/.config/alacritty/alacritty.toml
    sketchybar/                           → ~/.config/sketchybar/   (macOS)
    aerospace/                            → ~/.config/aerospace/    (macOS)
    i3/                                   → ~/.config/i3/           (Linux)
    homebrew/Brewfile                     → ~/.config/homebrew/Brewfile
    chezmoi/chezmoi.toml.tmpl             → ~/.config/chezmoi/chezmoi.toml
```
