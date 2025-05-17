-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")


local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Optional: A general group for your custom autocommands
local _MY_CUSTOM_AUTOCMDS = augroup("MyCustomAutocmds", { clear = true })

autocmd("VimEnter", {
  group = _MY_CUSTOM_AUTOCMDS, -- Assign to your custom group (optional but good practice)
  pattern = "*",
  once = true,
  callback = function()
    -- pcall is important to prevent Neovim from failing to start if there's an error in your module
    local lc_sync_ok, lc_sync = pcall(require, "custom.leetcode-sync") -- Note the path change

    if lc_sync_ok then
      if lc_sync and lc_sync.setup then -- Extra check to ensure module loaded correctly
        vim.schedule(function() -- Defer setup slightly, can sometimes help with race conditions
            lc_sync.setup({
              -- !! REQUIRED: ADJUST THESE PATHS !!
              leetcode_nvim_solution_dir = vim.fn.expand("~/.local/share/nvim/leetcode"),
              github_repo_path = vim.fn.expand("~/Documents/learning/lc_direct"),
              flat_leetcode_nvim_structure = true,
              verbose = true,
              debug_mode = true, -- Keep for testing
            })
        end)
      else
        vim.notify("LeetCode Sync module loaded but setup function not found.", vim.log.levels.ERROR, { title = "Config Error" })
      end
    else
      -- lc_sync here contains the error message from pcall
      vim.notify("Failed to load LeetCode GitHub Sync module: " .. tostring(lc_sync), vim.log.levels.ERROR, { title = "Config Error" })
      print("Error loading leetcode-sync module:", lc_sync) -- Also print to messages
    end
  end,
  desc = "Setup custom LeetCode GitHub Sync after Neovim starts.",
})