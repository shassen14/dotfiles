-- ~/.config/nvim/lua/user/keymaps.lua
-- Custom key mappings

local map = vim.keymap.set
local opts = { noremap = true, silent = true } -- Default options for mappings

-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- --- Normal Mode Mappings ---
-- Window management
map("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
map("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
map("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
map("n", "<leader>sx", ":close<CR>", { desc = "Close current split" })

-- Tab management
map("n", "<leader>to", ":tabnew<CR>", { desc = "Open new tab" })
map("n", "<leader>tx", ":tabclose<CR>", { desc = "Close current tab" })
map("n", "<leader>tn", ":tabn<CR>", { desc = "Go to next tab" })
map("n", "<leader>tp", ":tabp<CR>", { desc = "Go to previous tab" })

-- File management (Example - Needs plugin like nvim-tree or telescope later)
-- map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })

-- Navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move focus to left window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move focus to right window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move focus to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move focus to upper window" })

-- --- Insert Mode Mappings ---
-- Example: map("i", "jk", "<ESC>", opts) -- Press jk fast to exit insert mode

-- --- Visual Mode Mappings ---
-- Example: map("v", "<leader>p", '"_dP', opts) -- Paste without yanking

print("Loaded user/keymaps.lua") -- Debug message