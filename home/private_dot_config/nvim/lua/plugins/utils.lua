-- ~/.config/nvim/lua/plugins/utils.lua (Managed by Chezmoi)

return {
  -- Essential dependency
  { 'nvim-lua/plenary.nvim', lazy = true },

  -- Fuzzy Finder
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.6', -- Use correct stable tag
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup {
        defaults = {
          path_display = { "smart" },
          -- Add mappings or other telescope config here if needed
        }
      }
      print("Telescope configured")
    end
  },

  -- Syntax Highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { "BufReadPre", "BufNewFile" }, -- Load early for highlighting
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          "python", "lua", "vim", "vimdoc", "bash", "markdown", "json",
          "yaml", "toml", "rust", "cpp", "c", "html", "css", "javascript", "typescript",
        },
        sync_install = false,
        auto_install = true,
        highlight = { enable = true, additional_vim_regex_highlighting = false },
        indent = { enable = true },
      }
      print("nvim-treesitter configured")
    end
  },

  -- Git Signs
  {
    'lewis6991/gitsigns.nvim',
    event = { "BufReadPre", "BufNewFile" }, -- Load when opening files in git repos
    config = function()
      require('gitsigns').setup()
      print("gitsigns configured")
    end
  },

}