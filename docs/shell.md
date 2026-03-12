# Shell Cheatsheet

## Navigation
| Alias | Command | Description |
|-------|---------|-------------|
| `..` | `cd ..` | Up one directory |
| `...` | `cd ../..` | Up two directories |
| `....` | `cd ../../..` | Up three directories |
| `~` | `cd ~` | Go home |
| `z <name>` | `zoxide` | Jump to a frecently-used dir (e.g. `z nvim`, `z dots`) |
| `cd <name>` | `z` | Same as above (`cd` is aliased to `z`) |
| `zi` | — | Interactive zoxide picker |

> **zoxide** learns directories you visit. The more you visit, the shorter the name needed.

---

## File Listing
| Alias | Flags | Description |
|-------|-------|-------------|
| `ls` | — | Color listing (OS-aware) |
| `l` | `-lF` | Long list |
| `ll` | `-lhF` | Long list, human-readable sizes |
| `la` | `-laF` | Long list, including hidden |
| `lla` | `-lhaF` | Long list, human-readable, hidden |

---

## Safety Aliases
| Alias | Behavior |
|-------|----------|
| `cp` | Prompts before overwrite (`-iv`) |
| `mv` | Prompts before overwrite (`-iv`) |
| `rm` | Prompts before delete (`-i`) |
| `mkdir` | Creates parent dirs automatically (`-pv`) |

---

## fzf — Fuzzy Finder
> Install: `brew install fzf`

| Shortcut | Action |
|----------|--------|
| `Ctrl+R` | Fuzzy search shell history |
| `Ctrl+T` | Fuzzy find files, insert path at cursor |
| `Alt+C` | Fuzzy cd into a subdirectory |

In any fzf popup:
- Type to filter
- `↑/↓` or `Ctrl+P/N` to move
- `Enter` to select
- `Esc` or `Ctrl+C` to cancel

---

## Dotfiles Sync
| Alias | Action |
|-------|--------|
| `dots-push` | `chezmoi re-add` → commit → push to remote |
| `dots-pull` | Pull latest from remote and apply |
| `dots-diff` | Preview what chezmoi would change |
| `dots-status` | Show which managed files differ from source |

---

## Git Aliases
| Alias | Git Command |
|-------|-------------|
| `g` | `git` |
| `ga` | `git add` |
| `gaa` | `git add --all` |
| `gap` | `git add --patch` (interactive staging) |
| `gb` | `git branch` |
| `gba` | `git branch -a` (all branches) |
| `gc 'msg'` | `git commit -m 'msg'` |
| `gc!` | `git commit --amend -m` |
| `gca` | `git commit --amend --no-edit` |
| `gco` | `git checkout` |
| `gcb` | `git checkout -b` (new branch) |
| `gd` | `git diff` |
| `gdc` | `git diff --cached` (staged changes) |
| `gdw` | `git diff --word-diff` |
| `gf` | `git fetch --all --prune` |
| `gl` | Pretty graph log |
| `glog` | `git log --oneline --decorate --graph` |
| `gp` | `git push` |
| `gpf` | `git push --force-with-lease` (safer force) |
| `gpu` | Push current branch and set upstream |
| `gr` | `git rebase` |
| `gri` | `git rebase -i` (interactive) |
| `gs` | `git status -sb` (short) |
| `gst` | `git status` |

---

## System
| Alias | Action |
|-------|--------|
| `update` | Update all packages (brew/apt/dnf/pacman, OS-aware) |
| `reload` | Reload `~/.zshrc` |
| `k` | `kubectl` |
| `tf` | `terraform` |
| `py` | `python3` |

---

## zsh History Settings
- `HISTSIZE=10000` — commands kept in memory
- `SAVEHIST=20000` — commands saved to disk
- Up/Down arrow = **prefix search** (type `git` then ↑ to scroll only git commands)
- `HIST_IGNORE_SPACE` — prefix command with space to keep it out of history
