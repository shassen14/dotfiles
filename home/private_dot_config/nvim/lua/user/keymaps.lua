-- ~/.config/nvim/lua/user/keymaps.lua
-- Custom key mappings for Neovim

-- Use vim.keymap.set for modern mapping approach
local map = vim.keymap.set
-- Default options for mappings: non-recursive, silent
local opts = { noremap = true, silent = true }

-- Set leader key (<Space> is common and recommended)
-- Must be set BEFORE any mappings that use <leader>
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Indicate that keymaps are being loaded (for debugging)
print("Loading user/keymaps.lua...")

-- --- Normal Mode Mappings ---

-- Window Navigation and Management
map("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
map("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
map("n", "<leader>sx", ":close<CR>", { desc = "Close current split" }) -- <leader> s x = Split Close

-- Use Ctrl + hjkl to navigate between windows
map("n", "<C-h>", "<C-w>h", { desc = "Move focus to left window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move focus to right window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move focus to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move focus to upper window" })

-- Tab Management
map("n", "<leader>to", ":tabnew<CR>", { desc = "Open new tab" })         -- <leader> t o = Tab Open
map("n", "<leader>tx", ":tabclose<CR>", { desc = "Close current tab" })    -- <leader> t x = Tab Close
map("n", "<leader>tn", ":tabn<CR>", { desc = "Go to next tab" })         -- <leader> t n = Tab Next
map("n", "<leader>tp", ":tabp<CR>", { desc = "Go to previous tab" })     -- <leader> t p = Tab Previous
map("n", "<leader>tf", ":tabfirst<CR>", { desc = "Go to first tab" })   -- <leader> t f = Tab First
map("n", "<leader>tl", ":tablast<CR>", { desc = "Go to last tab" })     -- <leader> t l = Tab Last

-- File Management (Example - Replace with your file explorer toggle later)
-- map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })

-- Telescope Fuzzy Finder Mappings
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })      -- <leader> f f = Find Files
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })       -- <leader> f g = Find Grep (Live)
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })      -- <leader> f b = Find Buffers
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Find help tags" })   -- <leader> f h = Find Help
map("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", { desc = "Find oldfiles (history)" }) -- <leader> f o = Find Oldfiles

-- LSP (Language Server Protocol) Mappings
-- These require an LSP server to be attached to the buffer
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" }) -- <leader> r n = Rename
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" }) -- <leader> c a = Code Action
map("n", "gr", vim.lsp.buf.references, { desc = "Go to references" }) -- gr = Go References
map("n", "<leader>fm", function() vim.lsp.buf.format { async = true } end, { desc = "Format code" }) -- <leader> f m = Format
map("n", "<leader>ds", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "Document symbols" }) -- <leader> d s = Document Symbols
map("n", "<leader>ws", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", { desc = "Workspace symbols" }) -- <leader> w s = Workspace Symbols

-- Diagnostics (LSP Errors/Warnings)
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
map("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Show line diagnostics" }) -- <leader> d l = Diagnostic Line
map("n", "<leader>dq", vim.diagnostic.setloclist, { desc = "Set diagnostic quickfix list" }) -- <leader> d q = Diagnostic Quickfix

-- Basic Editing / Movement Convenience
map("n", "<Esc><Esc>", ":nohlsearch<CR>", { desc = "Clear search highlight" }) -- Double Escape clears search highlight
map("n", "<leader>w", ":w<CR>", { desc = "Write (save) file" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit window" })

-- --- Insert Mode Mappings ---
-- Example: jk to escape insert mode
-- map("i", "jk", "<ESC>", opts)
-- map("i", "kj", "<ESC>", opts)

-- --- Visual Mode Mappings ---
-- Example: Stay in indent mode
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- Example: Paste without losing yanked text
-- map("v", "<leader>p", '"_dP', opts)

-- --- Terminal Mode Mappings ---
-- Example: Escape from terminal mode easily
-- map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = "Escape terminal mode" })


-- Indicate that keymaps finished loading
print("Loaded user/keymaps.lua")