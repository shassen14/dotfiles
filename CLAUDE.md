# Dotfiles — Claude Context

Cross-platform dotfiles for macOS and Linux managed entirely with **Chezmoi**.

## Architecture

| Layer | Tool | Purpose |
|---|---|---|
| Dotfiles | Chezmoi | Template and manage config files in `home/` |
| Packages (macOS) | Homebrew Bundle | `Brewfile` applied via `run_once_` script |
| Packages (Linux) | apt/dnf/pacman | Installed via `run_once_` script |
| Entry point | `bootstrap.sh` | Installs Homebrew (macOS) + chezmoi → `chezmoi apply` |

**Chezmoi source** lives in `home/` (this repo). After `chezmoi init`, the source sits at `~/.local/share/chezmoi/home`. The `chezmoi.toml.tmpl` sets `sourceDir` to that path so subsequent `chezmoi apply` calls work without flags.

## Key Files

```
bootstrap.sh                                  # Fresh-machine entry point
home/                                         # Chezmoi source directory
  dot_*.tmpl                                  # Shell configs (zshrc, bashrc, aliases, exports)
  private_dot_config/                         # App configs (nvim, alacritty, sketchybar, etc.)
    homebrew/Brewfile                         # macOS packages (brew bundle)
    chezmoi/chezmoi.toml.tmpl                 # Generates ~/.config/chezmoi/chezmoi.toml
  run_once_install-packages-darwin.sh         # Runs brew bundle (macOS, runs once)
  run_once_install-packages-linux.sh          # Installs packages via apt/dnf/pacman (Linux, runs once)
docs/PLAN.md                                  # Full improvement roadmap
```

## Config Locations (Chezmoi managed)

| Source | Destination |
|---|---|
| `home/private_dot_config/nvim/` | `~/.config/nvim/` (LazyVim) |
| `home/private_dot_config/alacritty/alacritty.toml.tmpl` | `~/.config/alacritty/alacritty.toml` |
| `home/private_dot_config/ghostty/config` | `~/.config/ghostty/config` |
| `home/private_dot_config/sketchybar/` | `~/.config/sketchybar/` (macOS only) |
| `home/private_dot_config/aerospace/` | `~/.config/aerospace/` (macOS only) |
| `home/private_dot_config/i3/` | `~/.config/i3/` (Linux only) |
| `home/private_dot_config/homebrew/Brewfile` | `~/.config/homebrew/Brewfile` |
| `home/dot_zshrc.tmpl` | `~/.zshrc` |

## Platforms

- **macOS**: AeroSpace (tiling WM) + SketchyBar (status bar) + Homebrew
- **Linux**: i3wm + polybar (status bar) + apt/dnf/pacman
- **Windows**: komorebi + whkd (tiling WM) + YASB (status bar) + winget; bootstrap via `bootstrap.ps1`. See `docs/windows.md`.
- **Status bars** share one look: **Tokyonight Night** palette + **FiraCode Nerd Font** + matching module set across SketchyBar / polybar / YASB.
- **Terminal**: Ghostty (primary, KGP image support) + Alacritty (fallback); Windows Terminal on Windows
- **Streaming/Elgato**: Stream Deck + Wave Link; shared exports in repo `elgato/`. See `docs/elgato.md`.

## Common Workflows

```bash
# Fresh machine
./bootstrap.sh

# Re-apply dotfiles
chezmoi apply -v

# Preview changes
chezmoi diff

# Add a new macOS package
# 1. Edit home/private_dot_config/homebrew/Brewfile
# 2. Bump version comment in home/run_once_install-packages-darwin.sh
# 3. chezmoi apply

# Push local dotfile changes to remote
chezmoi re-add && chezmoi cd && git add -A && git commit -m "update" && git push

# Reassign workspaces after connecting/disconnecting monitors (macOS)
# Press alt-shift-m in AeroSpace, or run:
~/.config/aerospace/scripts/assign_workspaces.sh
```

## Nvim Stack

LazyVim base with overrides in `home/private_dot_config/nvim/lua/plugins/`.
LSP via mason: lua_ls, tsserver, pyright, clangd, rust-analyzer.

## Known Issues / Active Work

- `run_once_` scripts only re-run when file content changes (bump version comment to force)
- Ghostty on Debian/Ubuntu requires Flatpak (not in apt repos)
- Windows support is scaffolded (`bootstrap.ps1`, winget, komorebi/whkd, Windows Terminal) but **not yet validated on real hardware** — first run may need winget ID fixes
- Elgato: Wave Link presets are not shareable across mac/Windows; Stream Deck profiles are mostly shareable but launch/command buttons are OS-specific

## Guidelines for AI Work

- Chezmoi templates use `{{ .chezmoi.os }}` for OS conditionals (`"darwin"` / `"linux"`)
- Add new packages to `home/private_dot_config/homebrew/Brewfile` (macOS) or the linux `run_once_` script
- Don't make files big — prefer separate files with clear names over monoliths
- See `docs/PLAN.md` for the full improvement roadmap before adding new features
