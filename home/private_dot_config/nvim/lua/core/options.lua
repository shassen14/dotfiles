local o = vim.opt

local INDENT_WIDTH = 4
local SCROLL_PADDING = 8
local UPDATE_MS = 250
local TIMEOUT_MS = 300

-- Indentation
o.tabstop    = INDENT_WIDTH
o.shiftwidth = INDENT_WIDTH
o.expandtab  = true
o.smartindent = true

-- Line numbers
o.number         = true
o.relativenumber = true

-- UI
o.signcolumn   = "yes"
o.cursorline   = true
o.scrolloff    = SCROLL_PADDING
o.wrap         = true
o.linebreak    = true
o.termguicolors = true
o.showmode     = false
o.splitright   = true
o.splitbelow   = true

-- Search
o.ignorecase = true
o.smartcase  = true
o.hlsearch   = false
o.incsearch  = true

-- Files
o.undofile = true
o.swapfile = false
o.backup   = false

-- Completion popup
o.completeopt = { "menuone", "noselect" }

-- Responsiveness
o.updatetime = UPDATE_MS
o.timeoutlen = TIMEOUT_MS

-- Clipboard (sync with system)
o.clipboard = "unnamedplus"

-- Project-local config: auto-source .nvim.lua/.nvimrc from cwd (trust-gated)
o.exrc = true
