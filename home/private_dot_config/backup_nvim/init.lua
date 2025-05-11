-- ~/.config/nvim/init.lua (Managed by Chezmoi from source: private_dot_config/nvim/init.lua)
print("Loading init.lua...")

-- Apply core config: options and keymaps EARLY
print("Applying core config: options and keymaps...")
require("user.options") -- Load your options file BEFORE lazy setup
require("user.keymaps") -- Load your keymaps file BEFORE lazy setup
print("Core config applied.")

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
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim and tell it to load plugin specs from the 'lua/plugins' directory
print("Running lazy.setup...")
require("lazy").setup( "plugins", { -- Passing "plugins" loads specs from lua/plugins/*.lua
  -- Optional lazy.nvim config options here if needed
   checker = { enabled = true }, -- Example: check for updates
  -- performance = { rtp = { disabled = true } } -- Example: Faster startup
})

-- Set colorscheme (ensure the theme plugin spec in lua/plugins/ui.lua has lazy=false or high priority)
print("Setting colorscheme...")
vim.cmd.colorscheme("dracula") -- Make sure 'dracula' is the name specified in its plugin spec

print("init.lua finished.")