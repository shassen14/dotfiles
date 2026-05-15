local LEETCODE_LANG = "cpp"

local SYNC_CONFIG = {
  leetcode_nvim_solution_dir   = vim.fn.expand("~/.local/share/nvim/leetcode"),
  github_repo_path             = vim.fn.expand("~/Documents/learning/lc_direct"),
  flat_leetcode_nvim_structure = true,
  verbose                      = false,
  debug_mode                   = false,
  skip_acceptance_check        = true,
}

return {
  "kawre/leetcode.nvim",
  lazy = false,
  cond = function()
    return vim.fn.argc(-1) == 1 and vim.fn.argv(0) == "leetcode.nvim"
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    lang          = LEETCODE_LANG,
    image_support = true,
  },
  config = function(_, opts)
    -- Load image.nvim after leetcode UI is ready so its terminal probing
    -- doesn't interfere with the initial render.
    require("lazy").load({ plugins = { "image.nvim" } })
    require("leetcode").setup(opts)

    -- Force line wrapping in the problem description pane
    local wrap_group = vim.api.nvim_create_augroup("LeetCodeWrap", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group   = wrap_group,
      pattern = "leetcode.nvim",
      callback = function()
        local win = vim.api.nvim_get_current_win()
        vim.defer_fn(function()
          if vim.api.nvim_win_is_valid(win) then
            vim.wo[win].wrap     = true
            vim.wo[win].scrolloff = 0
          end
        end, 10)
      end,
    })
    vim.api.nvim_create_autocmd("WinEnter", {
      group = wrap_group,
      callback = function()
        if vim.bo.filetype == "leetcode.nvim" then
          vim.wo.wrap     = true
          vim.wo.scrolloff = 0
        end
      end,
    })

    -- Wire up the GitHub sync module
    local ok, lc_sync = pcall(require, "custom.leetcode-sync")
    if ok and lc_sync and lc_sync.setup then
      vim.schedule(function()
        lc_sync.setup(SYNC_CONFIG)
      end)
    end
  end,
}
