# Dotfiles

Cross-platform dotfiles for macOS and Linux managed entirely with **Chezmoi**.

## How it works

| File/Dir | Purpose |
|---|---|
| `bootstrap.sh` | Fresh-machine setup: installs Homebrew (macOS) + chezmoi, then applies dotfiles |
| `home/` | Chezmoi source — everything here gets applied to `~` |
| `home/private_dot_config/homebrew/Brewfile` | macOS packages (`brew bundle`) |
| `home/run_once_install-packages-darwin.sh` | Runs `brew bundle` once on macOS |
| `home/run_once_install-packages-linux.sh` | Installs packages via apt/dnf/pacman on Linux |

## Fresh machine

```bash
curl -fsSL https://raw.githubusercontent.com/shassen14/dotfiles/main/bootstrap.sh | bash
```

Or clone first:

```bash
git clone https://github.com/shassen14/dotfiles.git ~/dotfiles
~/dotfiles/bootstrap.sh
```

## Day-to-day

```bash
# Pull and apply latest dotfiles
chezmoi update

# Preview changes before applying
chezmoi diff

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
