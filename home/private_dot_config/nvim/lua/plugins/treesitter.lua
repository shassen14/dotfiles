local PARSERS = {
  "bash",
  "c",
  "cpp",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "rust",
  "toml",
  "tsx",
  "typescript",
  "javascript",
  "yaml",
}

return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = PARSERS,
      highlight        = { enable = true },
      indent           = { enable = true },
      incremental_selection = {
        enable  = true,
        keymaps = {
          init_selection   = "<C-space>",
          node_incremental = "<C-space>",
          node_decremental = "<bs>",
        },
      },
    })
  end,
}
