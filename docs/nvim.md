# Neovim / LazyVim Cheatsheet

**Leader key: `Space`**

> `<leader>` = Space. `g` prefix = go-to. `]`/`[` prefix = next/prev.

---

## Modes
| Key | Mode |
|-----|------|
| `i` | Insert mode |
| `Esc` or `Ctrl+[` | Back to Normal mode |
| `v` | Visual (character) |
| `V` | Visual (line) |
| `Ctrl+v` | Visual (block) |
| `:` | Command mode |

---

## File / Buffer
| Key | Action |
|-----|--------|
| `<leader>ff` | Find files (fuzzy) |
| `<leader>fg` or `<leader>/` | Live grep (search text in project) |
| `<leader>fb` | Find open buffers |
| `<leader>fr` | Recent files |
| `<leader>e` | Toggle file explorer (Neo-tree) |
| `<leader>bd` | Close/delete buffer |
| `<leader>bb` | Switch to other buffer |
| `[b` / `]b` | Previous / next buffer |
| `<leader>,` | Switch buffer (picker) |

---

## Window / Split Navigation
| Key | Action |
|-----|--------|
| `Ctrl+h/j/k/l` | Move between splits (works across tmux too) |
| `<leader>wv` | Split vertically |
| `<leader>ws` | Split horizontally |
| `<leader>ww` | Switch to other window |
| `<leader>wd` | Close window |

---

## LSP (Language Server)
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `gI` | Go to implementation |
| `gy` | Go to type definition |
| `gD` | Go to declaration |
| `K` | Hover documentation |
| `gK` | Signature help |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename symbol |
| `<leader>cf` | Format file |
| `]d` / `[d` | Next / prev diagnostic |
| `<leader>cd` | Line diagnostics (float) |
| `<leader>xx` | Diagnostics list (Trouble) |

**LSPs installed:** lua_ls, ts_ls, pyright, clangd, rust_analyzer, bashls, yamlls, jsonls, taplo

---

## Search & Navigation
| Key | Action |
|-----|--------|
| `/` | Search forward |
| `?` | Search backward |
| `n` / `N` | Next / prev match |
| `*` | Search word under cursor |
| `<leader>sr` | Find & replace (spectre) |
| `%` | Jump to matching bracket |
| `Ctrl+o` / `Ctrl+i` | Jump back / forward in jump list |
| `gg` / `G` | Top / bottom of file |
| `{` / `}` | Jump by paragraph |

---

## Editing
| Key | Action |
|-----|--------|
| `u` | Undo |
| `Ctrl+r` | Redo |
| `yy` | Yank (copy) line |
| `dd` | Delete line |
| `p` / `P` | Paste after / before |
| `>>` / `<<` | Indent / dedent line |
| `gc` + motion | Toggle comment (e.g. `gcc` = comment line) |
| `J` | Join line below to current |
| `ciw` | Change inner word |
| `di(` | Delete inside parentheses |
| `va{` | Select around `{}` block |
| `Ctrl+a` / `Ctrl+x` | Increment / decrement number |

**Format on save** is enabled for: lua, python, js/ts, rust, sh, yaml, json, c/cpp, toml.

---

## Debugging (nvim-dap)
| Key | Action |
|-----|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue / start debugging |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>du` | Toggle DAP UI |

**Supported:** Python, Go, Node/TypeScript, C/C++ (via codelldb)

---

## Git (LazyGit + Gitsigns)
| Key | Action |
|-----|--------|
| `<leader>gg` | Open LazyGit (if installed) |
| `<leader>gf` | LazyGit for current file |
| `]h` / `[h` | Next / prev git hunk |
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |
| `<leader>ghb` | Blame line |
| `<leader>ghd` | Diff this file |

---

## LeetCode (leetcode.nvim)
| Key | Action |
|-----|--------|
| `<leader>ll` | LeetCode menu |
| `<leader>lr` | Run test |
| `<leader>ls` | Submit solution |

Solutions auto-sync to `~/Documents/learning/lc_direct` on save.

---

## Miscellaneous
| Key | Action |
|-----|--------|
| `<leader>qq` | Quit all |
| `<leader>un` | Dismiss notifications |
| `<leader>xl` | Location list |
| `<leader>xq` | Quickfix list |
| `Ctrl+/` | Toggle terminal |
| `<leader>fn` | New file |
| `<leader>L` | Lazy plugin manager |
| `<leader>cm` | Mason (LSP/tool manager) |

---

## Tips
- Run `:LazyExtras` to see all available LazyVim extras you can enable
- Run `:Mason` to install/manage LSP servers and formatters
- `<leader>` then wait ~1s — which-key popup shows available bindings
