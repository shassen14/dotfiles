-- ~/.config/nvim/lua/user/lazy.lua
-- Plugin specifications for lazy.nvim

local lazy = require("lazy")

lazy.setup({
  -- Specify plugins here using standard formats
  -- See lazy.nvim documentation for details

  -- Colorscheme Example (Dracula)
  { "Mofiqul/dracula.nvim", name = "dracula", lazy = false, priority = 1000 },

  -- Status Line Example (Lualine)
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }, -- Optional icons
    opts = {
      options = {
        theme = 'auto', -- Or specify theme like 'dracula'
        icons_enabled = true,
        -- ... other lualine options
      }
    }
  },

  -- Essential: Better UI elements
  { 'nvim-lua/plenary.nvim', lazy = true }, -- Often a required dependency

  -- Add Tree-sitter configuration HERE
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate', -- Command to install/update parsers
    config = function()
      require('nvim-treesitter.configs').setup({
        -- Ensure these language parsers are installed
        ensure_installed = { "python", "lua", "vim", "vimdoc", "bash", "markdown", "json", "yaml", "toml" },

        -- Install parsers synchronously (blocks startup until installed)
        sync_install = false,

        -- Automatically install missing parsers when entering buffer
        -- Recommendation: set to false if you prefer managing parsers manually with :TSInstall
        auto_install = true,

        -- Enable highlighting
        highlight = {
          enable = true,
          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
          -- Using this option may slow down your editor, and you may see some duplicate highlights.
          -- Instead of true it can also be a list of languages
          additional_vim_regex_highlighting = false,
        },

        -- Enable indentation based on tree-sitter (experimental but often good)
        indent = {
          enable = true,
        },

        -- You can add other modules like textobjects, incremental selection etc. later
      })
      print("nvim-treesitter configured") -- Debug
    end
  },

  -- Future Plugins to Consider Adding:
  -- { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' }, -- Syntax highlighting/parsing
  -- { 'neovim/nvim-lspconfig' }, -- Language Server Protocol configuration
  -- { 'hrsh7th/nvim-cmp' }, -- Autocompletion engine
  -- { 'hrsh7th/cmp-nvim-lsp' }, -- LSP source for nvim-cmp
  -- { 'L3MON4D3/LuaSnip' }, -- Snippet engine
  -- { 'nvim-telescope/telescope.nvim', dependencies = { 'nvim-lua/plenary.nvim' } }, -- Fuzzy finder
  -- { 'nvim-tree/nvim-tree.lua' }, -- File explorer

}, {
  -- Lazy.nvim options
  checker = { enabled = true }, -- Check for updates daily
})

print("Loaded user/lazy.lua and ran lazy.setup()") -- Debug message