# Dotfiles Improvement Plan

Ordered by impact and dependency. Each phase is independently deployable.

---

## Recently Completed

- **NVIDIA suspend/resume fix (Linux)** — `run_once_configure-nvidia-suspend-linux.sh` writes `/etc/modprobe.d/nvidia-power.conf` (`NVreg_PreserveVideoMemoryAllocations=1`), rebuilds initramfs, and enables `nvidia-suspend/resume/hibernate.service`. Fixes black-screen-on-wake on NVIDIA-proprietary desktops. Gated on `nvidia-smi`/`/proc/driver/nvidia` so it no-ops on non-NVIDIA machines.

- **Chezmoi-only migration** — Ansible + 27 playbooks replaced by `run_once_` shell scripts and a Brewfile
- **Bootstrap simplified** — `bootstrap.sh` is now 22 lines: Homebrew → chezmoi → apply
- **Brewfile** — all macOS packages in `home/private_dot_config/homebrew/Brewfile`
- **`run_once_` scripts** — package install happens automatically on `chezmoi apply`
- **CI updated** — workflow now tests `chezmoi apply` directly, no Ansible
- **Ghostty (Phase 5)** — added as primary terminal with KGP image support; macOS via Homebrew cask, Arch/Fedora via native packages, Debian/Ubuntu via Flatpak; config at `home/private_dot_config/ghostty/config`
- **Neovim Enhancement (Phase 4)** — LSP fixed (`ts_ls`, added `bashls`/`yamlls`/`jsonls`/`taplo`); formatting via `conform.nvim` (lua, python, js/ts, rust, sh, yaml, json, c/cpp); debugging via `nvim-dap` (Python, Go, Node/TS, C/C++ via codelldb); `image.nvim` with Kitty backend; LazyVim extras for TypeScript, Python, Rust, DAP
- **Code Quality (Phase 6)** — ShellCheck + yamllint CI in `.github/workflows/lint.yml`; `.pre-commit-config.yaml` with shellcheck and yamllint hooks; fixed bash line-continuation bug in `executable_lock.sh`; added SC2034 disable in `variables.sh` (sourced file)
- **Shell QoL tools** — `fzf` (fuzzy history/file/cd), `zoxide` (frecency cd), `zsh-autosuggestions`, `zsh-syntax-highlighting` added to Brewfile and Linux scripts; wired up in `.zshrc`
- **Phase 2 — Sync aliases** — `dots-push`, `dots-pull`, `dots-diff`, `dots-status` added to `.aliases.sh`
- **Cheatsheets** — `docs/shell.md`, `docs/tmux.md`, `docs/nvim.md`, `docs/aerospace.md`, `docs/sketchybar.md`
- **Phase 7 — Windows Support** — `bootstrap.ps1` (winget → chezmoi → apply); `run_once_install-packages-windows.ps1` (winget bundle); Windows Terminal config with Tokyonight theme; komorebi + whkd config mirroring AeroSpace bindings; `dot_gitconfig.tmpl` Windows `autocrlf` conditional; `chezmoi.toml.tmpl` Windows data vars

---

## Quick Wins (Do Next)

1. **Add Rust** to Brewfile + `run_once_install-packages-linux.sh` (was a commented-out Ansible playbook)
2. **Fix sketchybar `notch_width`** with display detection ✓ DONE (Phase 3)
3. **Add ShellCheck to CI** for the `run_once_` scripts

---

## Phase 1 — Bootstrap Hardening ✓ DONE

### 1.1 — Makefile ✓
`Makefile` at repo root with `install`, `update`, `push`, `apply`, `diff`, `help` targets.

### 1.2 — Source Unification ✓
`bootstrap.sh` now uses `chezmoi init --source "$SCRIPT_DIR/home"` when run from the repo — the working copy IS the chezmoi source. Falls back to cloning from the remote URL when run on a machine without the repo.

---

## Phase 2 — Bidirectional Dotfile Sync ✓ DONE

Sync aliases added to `.aliases.sh`: `dots-push`, `dots-pull`, `dots-diff`, `dots-status`.

---

## Phase 3 — SketchyBar Multi-Monitor Fix ✓ DONE

**Problem**: `notch_width=200` was hardcoded for MacBook notch. External monitors got a blank gap.

### 3.1 — Dynamic Notch Detection ✓

`executable_sketchybarrc.tmpl` now detects the built-in display at startup:
- Built-in display present (lid open) → `notch_width=200`
- Clamshell / external-only → `notch_width=0`

### 3.2 — AeroSpace Display Assignment ✓

`assign_workspaces.sh` dynamically assigns workspaces based on connected monitor count:
- 1 monitor → all workspaces on monitor 1
- 2 monitors → workspaces 1–4 on primary, 5–9 on secondary
- 3+ monitors → workspaces 1–3 / 4–6 / 7–9 across all three

Runs automatically at AeroSpace startup. Press **`alt-shift-m`** any time after connecting or disconnecting monitors to reassign. Polling automation (LaunchAgent) is a future option if hands-free is preferred.

---

## Phase 4 — Neovim Enhancement ✓ DONE

All sub-tasks complete. See "Recently Completed" above for details.

---

## Phase 5 — Terminal Image Support ✓ DONE

Ghostty is now the primary terminal with Kitty Graphics Protocol support. Alacritty kept as fallback.

| Terminal  | Image Protocol | Status                  |
| --------- | -------------- | ----------------------- |
| Alacritty | None           | Kept as fallback        |
| Ghostty   | KGP            | Installed (primary)     |
| WezTerm   | KGP + sixel    | Not needed              |

**Config**: `home/private_dot_config/ghostty/config` — Tokyonight theme, FiraCode Nerd Font.

**Linux install**:
- Arch: `ghostty` (official `extra` repo)
- Fedora: `ghostty` (official repos, Fedora 41+)
- Debian/Ubuntu: Flatpak (`com.mitchellh.ghostty` from Flathub)

**Next**: Phase 4.4 (`image.nvim`) can now be enabled — KGP backend is available.

---

## Phase 6 — Code Quality ✓ DONE

### 6.1 — ShellCheck in CI ✓

`.github/workflows/lint.yml` — runs on push/PR to main:
- ShellCheck (warning severity) on all `.sh` files via `ludeeus/action-shellcheck`
- yamllint on all YAML files via `ibiqlik/action-yamllint` (120-char line limit)

### 6.2 — Pre-commit Hooks ✓

`.pre-commit-config.yaml`:
- shellcheck (`koalaman/shellcheck-precommit@v0.10.0`)
- yamllint (`adrienverge/yamllint@v1.35.1`)

---

## Phase 7 — Windows Support ✓ DONE

### 7.1 — Bootstrap ✓

`bootstrap.ps1`: installs chezmoi via winget, then runs `chezmoi init --source` (local clone) or `chezmoi init <repo>` (remote), followed by `chezmoi apply -v`.

### 7.2 — Package Equivalents ✓

| macOS/Linux       | Windows                            |
| ----------------- | ---------------------------------- |
| Homebrew Brewfile | `run_once_install-packages-windows.ps1` (winget) |
| AeroSpace         | komorebi + whkd                    |
| i3                | komorebi + whkd                    |
| Alacritty/Ghostty | Windows Terminal                   |

Installed packages: PowerShell 7, Windows Terminal, Neovim, VS Code, Git, gh, komorebi, whkd, Node LTS, Python, Rustup, Go, fzf, zoxide, bat, eza, ripgrep, jq, tldr, FiraCode Nerd Font.

### 7.3 — Chezmoi Templates ✓

- `dot_gitconfig.tmpl`: `autocrlf = true` on Windows, `input` elsewhere
- `chezmoi.toml.tmpl`: added `terminal_cmd_windows = "wt"`, `browser_cmd_windows = "msedge"`
- `home/private_dot_config/windows-terminal/settings.json.tmpl`: Tokyonight theme, FiraCode Nerd Font, WSL profile
- `home/private_dot_config/komorebi/komorebi.json`: 9 BSP workspaces, Tokyonight border colors, 8px gaps
- `home/private_dot_config/komorebi/whkdrc`: keybindings mirroring AeroSpace (alt+hjkl focus/move, alt+1-9 workspaces)

### 7.4 — Validation (PENDING)

Windows support has never been run on real hardware. On the first Windows machine:
- Run `bootstrap.ps1` elevated; confirm winget IDs resolve (fix any that 404).
- Verify komorebi + whkd start and bindings don't collide.
- Confirm Windows Terminal + PowerShell profile apply cleanly.

Runbook: `docs/windows.md`.

---

## Phase 8 — Elgato (Stream Deck + Wave Link)

Consistent-as-possible Stream Deck + Wave Link across macOS and Windows.

### 8.1 — Install ✓

- macOS: `elgato-stream-deck`, `elgato-wave-link` casks added to Brewfile.
- Windows: `Elgato.StreamDeck`, `Elgato.WaveLink` added to `run_once_install-packages-windows.ps1` (version bumped to 2).

### 8.2 — Config storage ✓

- Top-level `elgato/` dir (outside chezmoi `home/`, since configs are GUI-imported, not symlinked).
- `elgato/stream-deck/profiles/` — shared `.streamDeckProfile` exports.
- `elgato/wave-link/{macos,windows}/` — per-OS `.wavelink` backups (Elgato blocks cross-OS preset sharing).
- `elgato/README.md` (workflow) + `docs/elgato.md` (reference).

### 8.3 — Populate configs (PENDING — needs the device)

Requires the physical Stream Deck + the apps installed:
- Build a profile, **export** it into `elgato/stream-deck/profiles/`, commit.
- Add per-OS variants for launch/command buttons.
- Export Wave Link backups per OS into `elgato/wave-link/<os>/`.

---

## Phase 9 — Unified runtimes (mise) ✓

Replaced per-OS node/go/python installs with [mise](https://mise.jdx.dev) so versions
match across machines.

- `home/private_dot_config/mise/config.toml`: global `node=lts`, `go=latest`, `python=3.13`.
- Installed via Brewfile (`mise`), winget (`jdx.mise`), Linux (`curl https://mise.run`).
- Removed: `brew node`; winget `OpenJS.NodeJS.LTS` / `Python.Python.3.13` / `GoLang.Go`;
  Linux NodeSource block + `nodejs npm` from dnf/pacman. (System `python3` kept on Linux as a base dep.)
- Activated in `.zshrc` (before zoxide), `.bashrc`, and the PowerShell profile.
- **Rust stays on rustup** everywhere (mise's rust just wraps rustup).
- First run after apply: `mise install` to fetch the pinned versions.

### Windows CI ✓

`main.yml` gained a `chezmoi-dry-run-windows` job (windows-latest): installs chezmoi via
choco, runs `chezmoi apply --dry-run` so every template renders for the Windows target
without executing the winget install script. Catches template breakage before real hardware.
