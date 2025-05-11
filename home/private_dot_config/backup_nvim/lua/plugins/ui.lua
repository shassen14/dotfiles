-- ~/.config/nvim/lua/plugins/ui.lua (Managed by Chezmoi)

return {
  -- Colorscheme
  {
    "Mofiqul/dracula.nvim",
    name = "dracula",
    lazy = false, -- Load theme early
    priority = 1000 -- Ensure it loads before other UI elements potentially
  },

  -- Status Line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }, -- Icons dependency
    opts = { -- Configure lualine using opts table
      options = {
        theme = 'dracula', -- Match colorscheme
        icons_enabled = true,
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
      }
      -- Add sections = { ... } here to customize statusline content
    }
  },

  -- Icons (can also be defined just as dependency)
  { "nvim-tree/nvim-web-devicons", lazy = true },

}