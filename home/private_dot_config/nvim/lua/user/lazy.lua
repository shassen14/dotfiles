-- ~/.config/nvim/lua/user/lazy.lua
-- TEST VERSION: Minimal LSP/Completion setup using LSP-Zero
-- Fix: Use explicit mason-lspconfig handlers with lsp-zero on_attach

local lazy = require("lazy")

lazy.setup({
  -- Essential dependency for many plugins (keep uncommented)
  { 'nvim-lua/plenary.nvim', lazy = true },

  -- Icons (keep uncommented, needed by lspkind, possibly cmp formatting)
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- LSP Configuration & Autocompletion using LSP-Zero (ACTIVE FOR TEST)
  {
    'VonHeikemen/lsp-zero.nvim', -- Helper preset simplifies LSP setup
    branch = 'v3.x',
    -- Set lazy=false TEMPORARILY for this test to force it loading early.
    -- Change back to lazy=true later if this test works.
    -- lazy = false,
    event = { "BufReadPre", "BufNewFile" }, -- Load when opening/creating files
    dependencies = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},
      {'williamboman/mason.nvim'},             -- Installs LSPs easily
      {'williamboman/mason-lspconfig.nvim'}, -- Bridges mason & lspconfig

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},          -- Completion engine
      {'hrsh7th/cmp-nvim-lsp'},      -- LSP completion source
      {'L3MON4D3/LuaSnip'},          -- Snippet engine
      {'saadparwaiz1/cmp_luasnip'},  -- Snippet completion source
      {'hrsh7th/cmp-buffer'},        -- Buffer word completion source
      {'hrsh7th/cmp-path'},          -- File path completion source

      -- Optional nice completion additions
      -- {'rafamadriz/friendly-snippets'}, -- Useful snippet collection (load AFTER LuaSnip)
      -- {'onsails/lspkind.nvim'} -- Add icons to completion items (requires nvim-web-devicons)
    },
    config = function()
      -- Note: lsp_zero.preset() can often be omitted when using explicit handlers
      -- local lsp_zero = require('lsp-zero')
      -- lsp_zero.preset('recommended')

      print("Configuring Mason...") -- Debug msg
      require('mason').setup({}) -- Still need base mason setup

      print("Configuring Mason-LSPConfig with explicit handlers...") -- Debug msg
      local lsp_zero_on_attach = require('lsp-zero').on_attach -- Get the on_attach function
      local lspconfig = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities() -- Get CMP capabilities

      require('mason-lspconfig').setup({
        ensure_installed = { -- List servers Mason should install
             'pyright',
             'lua_ls',
             'bashls',
             'clangd',
             'rust_analyzer', -- Added Rust
             'ts_ls',      -- Added JS/TS
             'html',          -- Added HTML
             'cssls',         -- Added CSS
             'yamlls',        -- Added YAML
             'jsonls',        -- Added JSON
             'marksman',      -- Added Markdown
             'dockerls',      -- Added Dockerfile
             'docker_compose_language_service' -- Added Docker Compose
            },
        handlers = {
          -- Default handler: Sets up servers using lspconfig
          -- and applies lsp-zero's on_attach function for keymaps/settings
          function(server_name) -- Default handler function
            print("Setting up LSP Server: " .. server_name) -- Debug
            lspconfig[server_name].setup({
              -- Pass CMP capabilities to the LSP server
              capabilities = capabilities,
              -- Run this function WHEN the LSP server attaches to a buffer
              on_attach = function(client, bufnr)
                print("Running lsp-zero on_attach for: " .. server_name .. " on buffer " .. bufnr) -- Debug
                -- Use LSP Zero's on_attach here to set keymaps etc.
                lsp_zero_on_attach(client, bufnr)
              end,
            })
          end,

          -- Example Custom handler for lua_ls (if needed for specific settings)
          lua_ls = function()
            print("Setting up lua_ls via custom handler (with on_attach)...")
            local lua_opts = require('lsp-zero').nvim_lua_ls() -- Use helper for settings if desired
            lspconfig.lua_ls.setup({
               capabilities = capabilities,
               on_attach = lsp_zero_on_attach,
               settings = lua_opts.settings -- Apply specific settings
            })
         end,
        }
      })

      -- Configure nvim-cmp (keep this section as is from previous working version)
      print("Configuring nvim-cmp...")
      local cmp = require('cmp')
      local cmp_select = {behavior = cmp.SelectBehavior.Select}
      local luasnip = require('luasnip') -- Make sure luasnip is required for snippet mapping

      cmp.setup({
        sources = cmp.config.sources({
          {name = 'nvim_lsp'},
          {name = 'luasnip'}, -- Snippet source
          {name = 'buffer', keyword_length = 3},
          {name = 'path'},
        }),
        formatting = require('lsp-zero').cmp_format(), -- Use lsp-zero helper for formatting
        mapping = cmp.mapping.preset.insert({
          ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
          ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
          ['<C-y>'] = cmp.mapping.confirm({ select = true }), -- Accept suggestion
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept suggestion with Enter too
          ['<C-Space>'] = cmp.mapping.complete(), -- Manually trigger completion
          -- Tab mapping for completion/snippet navigation (optional but common)
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item(cmp_select)
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }), -- Run in insert and select mode
          ['<S-Tab>'] = cmp.mapping(function(fallback)
             if cmp.visible() then
               cmp.select_prev_item(cmp_select)
             elseif luasnip.jumpable(-1) then
               luasnip.jump(-1)
             else
               fallback()
             end
           end, { 'i', 's' }),
        }),
         snippet = { -- Configure snippet expansion engine
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
      })

      print("LSP/CMP config function finished.")
    end
  },

  --- Plugins COMMENTED OUT for this test ---
  { "Mofiqul/dracula.nvim", name = "dracula", lazy = false, priority = 1000 },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = { options = { theme = 'auto', icons_enabled = true, component_separators = { left = '', right = ''}, section_separators = { left = '', right = ''} } }
  },
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.6', -- Use actual stable tag
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function() require('telescope').setup { defaults = { path_display = { "smart" } } } end
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = { "python", "lua", "vim", "vimdoc", "bash", "markdown", "json", "yaml", "toml", "rust", "cpp", "c", "html", "css", "javascript", "typescript" },
        sync_install = false, auto_install = true, highlight = { enable = true }, indent = { enable = true }
      })
    end
  },
  {
    'lewis6991/gitsigns.nvim',
    config = function() require('gitsigns').setup() end
  },


}, {
  -- Lazy.nvim options (keep these)
  checker = { enabled = true },
})

print("Loaded MINIMAL user/lazy.lua") -- Debug message