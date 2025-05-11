-- ~/.config/nvim/lua/user/options.lua
-- Basic Neovim options

local opt = vim.opt -- For convenience
local g = vim.g     -- For global variables

-- Make line numbers default
opt.number = true
opt.relativenumber = true

-- Enable mouse mode
opt.mouse = 'a'

-- Don't show the mode, since it's already in status line
opt.showmode = false

-- Sync clipboard between OS and Neovim. Requires "+clipboard" feature.
opt.clipboard = 'unnamedplus'

-- Enable break indent
opt.breakindent = true

-- Save undo history
opt.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
opt.ignorecase = true
opt.smartcase = true

-- Decrease update time
opt.updatetime = 250
-- opt.timeoutlen = 300 # Consider lowering if needed

-- Configure autocompletion behavior
opt.completeopt = 'menuone,noselect'

-- Set termguicolors to enable Neovim respecting definition of vim colorschemes
opt.termguicolors = true
opt.background = 'dark' -- Or 'light'

-- Indentation
opt.expandtab = true    -- Use spaces instead of tabs
opt.shiftwidth = 2      -- Size of an indent
opt.tabstop = 2         -- Number of spaces tabs count for
opt.softtabstop = 2     -- Number of spaces tabs count for in insert mode

-- Line wrapping
opt.wrap = false

-- Appearance
opt.signcolumn = 'yes'  -- Always show the sign column
opt.scrolloff = 8       -- Minimum number of screen lines to keep above and below the cursor
opt.sidescrolloff = 8

-- Split behavior
opt.splitright = true   -- Vertical splits open to the right
opt.splitbelow = true   -- Horizontal splits open below

print("Loaded user/options.lua") -- Debug message