-- ~/.config/nvim/init.lua
-- Entry point for Neovim configuration

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  print("Bootstraping lazy.nvim...")
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
  print("lazy.nvim bootstrap complete.")
end
vim.opt.rtp:prepend(lazypath) -- Add lazy to runtime path

-- Load configurations AFTER bootstrap and rtp update
require("user.options")   -- Load basic editor options
require("user.keymaps")   -- Load custom key mappings
require("user.lazy")      -- Load plugin specifications for lazy.nvim

vim.cmd.colorscheme("dracula")

print("init.lua loaded successfully") -- For debugging