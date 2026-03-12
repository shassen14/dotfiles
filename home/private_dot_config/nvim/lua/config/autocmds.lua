-- ~/.config/nvim/lua/config/autocmds.lua
-- This file is automatically loaded by LazyVim if it exists.

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Optional: A general group for your custom autocommands
local _MY_CUSTOM_AUTOCMDS = augroup("MyCustomAutocmds", { clear = true })

-- Force wrap in leetcode description window (image_support disables it)
autocmd("FileType", {
  pattern = "leetcode.nvim",
  callback = function()
    local win = vim.api.nvim_get_current_win()
    vim.defer_fn(function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_set_option(win, "wrap", true)
      end
    end, 10)
  end,
})
autocmd("WinEnter", {
  callback = function()
    if vim.bo.filetype == "leetcode.nvim" then
      vim.wo.wrap = true
    end
  end,
})

autocmd("VimEnter", {
  group = _MY_CUSTOM_AUTOCMDS, 
  pattern = "*",
  once = true,
  callback = function()
    local lc_sync_ok, lc_sync = pcall(require, "custom.leetcode-sync")

    if lc_sync_ok then
      if lc_sync and lc_sync.setup then
        vim.schedule(function()
            lc_sync.setup({
              -- !! REQUIRED: ADJUST THESE PATHS !!
              leetcode_nvim_solution_dir = vim.fn.expand("~/.local/share/nvim/leetcode"),
              github_repo_path = vim.fn.expand("~/Documents/learning/lc_direct"),
              flat_leetcode_nvim_structure = true,
              verbose = false,
              debug_mode = false, -- Keep true while testing

              -- ***** CHOOSE YOUR ACCEPTANCE STRATEGY HERE *****
              -- Option A: Sync any saved file from the leetcode dir without checking for "Runtime:" or UI "Accepted"
              -- skip_acceptance_check = true,

              -- Option B (Default behavior if you omit the line above):
              --   - On save: Only syncs if "// Runtime:" (or similar) is in the .cpp file.
              --   - On :LeetCodeSyncNow: Syncs if "// Runtime:" is in .cpp file OR if "Accepted"/"Runtime:" text is in current UI buffer.
              skip_acceptance_check = true, -- Explicitly setting to false (this is the default if omitted)
              -- ***************************************************
            })
        end)
      else
        vim.notify("LeetCode Sync module loaded but setup function not found.", vim.log.levels.ERROR, { title = "Config Error" })
      end
    else
      vim.notify("Failed to load LeetCode GitHub Sync module: " .. tostring(lc_sync), vim.log.levels.ERROR, { title = "Config Error" })
      print("Error loading leetcode-sync module:", lc_sync)
    end
  end,
  desc = "Setup custom LeetCode GitHub Sync after Neovim starts.",
})