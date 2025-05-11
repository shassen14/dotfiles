-- ~/.config/nvim/lua/plugins/lsp_completion.lua (Managed by Chezmoi)
-- Specifications for LSP, Mason, and Completion plugins

return { -- Start with 'return {'

  -- LSP Configuration & Autocompletion using LSP-Zero
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    lazy = false, -- Standard lazy-loading
    event = { "BufReadPre", "BufNewFile" }, -- Trigger on file open
    dependencies = {
       -- Dependencies listed here
      {'neovim/nvim-lspconfig'},
      {'williamboman/mason.nvim'},
      {'williamboman/mason-lspconfig.nvim'},
      {'hrsh7th/nvim-cmp'},
      {'hrsh7th/cmp-nvim-lsp'},
      {'L3MON4D3/LuaSnip'},
      {'saadparwaiz1/cmp_luasnip'},
      {'hrsh7th/cmp-buffer'},
      {'hrsh7th/cmp-path'},
      -- {'rafamadriz/friendly-snippets'}, -- Optional snippets
      -- {'onsails/lspkind.nvim'}, -- Optional icons for completion (Add this if you want icons)
    },
    config = function()
      print("Configuring LSP-Zero preset...")
      local lsp_zero = require('lsp-zero')
      -- If you DON'T use the preset, ensure lsp_zero.on_attach and capabilities are set up correctly below.
      -- lsp_zero.preset('recommended') -- Keep commented if explicit setup below works better for you

      print("Configuring Mason...")
      require('mason').setup({}) -- Basic setup is usually sufficient

      print("Configuring Mason-LSPConfig with explicit handlers...")
      local lspconfig = require('lspconfig')
      local cmp_nvim_lsp = require('cmp_nvim_lsp')
      -- Use LSP Zero to get capabilities and on_attach handler
      local capabilities = cmp_nvim_lsp.default_capabilities(lsp_zero.get_capabilities())
      local lsp_zero_on_attach = lsp_zero.on_attach -- Use LSP Zero's on_attach

      require('mason-lspconfig').setup({
        ensure_installed = {
            'pyright', 'lua_ls', 'bashls', 'clangd', 'rust_analyzer',
            'ts_ls',
            'html', 'cssls', 'yamlls', 'jsonls',
            'marksman', 'dockerls', 'docker_compose_language_service'
        },
        handlers = {
          function(server_name) -- Default handler
            print("Setting up LSP Server: " .. server_name)
            lspconfig[server_name].setup({
              capabilities = capabilities,
              on_attach = lsp_zero_on_attach, -- Use LSP Zero's handler
            })
          end,
          lua_ls = function() -- Custom lua_ls handler (LSP Zero often provides good defaults)
             print("Setting up lua_ls via custom handler...")
             -- Use lsp-zero's recommended settings for lua_ls
             local lua_opts = lsp_zero.nvim_lua_ls()
             lspconfig.lua_ls.setup(vim.tbl_deep_extend('force', lua_opts, {
                capabilities = capabilities,
                on_attach = lsp_zero_on_attach,
             }))
          end,
        }
      })

      -- Configure nvim-cmp
      print("Configuring nvim-cmp...")
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      local cmp_select = {behavior = cmp.SelectBehavior.Select}

      -- Optional: If you installed lspkind.nvim, uncomment this
      -- local lspkind = require('lspkind')

      cmp.setup({
             snippet = {
               expand = function(args)
                 luasnip.lsp_expand(args.body)
               end,
             },
             sources = cmp.config.sources({
                 { name = 'nvim_lsp' },
                 { name = 'luasnip' },
                 { name = 'buffer' },
                 { name = 'path' },
             }),

            -- V V V TEMPORARY SIMPLIFICATION V V V
            formatting = {
              -- Use a very basic default format function for testing
              format = function(entry, vim_item)
                -- You can add icons or basic formatting here if needed later
                vim_item.kind = string.format('%s', vim_item.kind) -- Basic kind display
                return vim_item
              end
            },
            -- ^ ^ ^ TEMPORARY SIMPLIFICATION ^ ^ ^
            --  -- v v v CORRECTED STRUCTURE v v v
            --  formatting = {
            --    format = require('lsp-zero').cmp_format() -- Assign the function to the 'format' sub-key
            --  },
            --  -- ^ ^ ^ CORRECTED STRUCTURE ^ ^ ^
             mapping = cmp.mapping.preset.insert({
                 ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                 ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                 ['<C-y>'] = cmp.mapping.confirm({ select = true }), -- Confirm selection
                 ['<C-Space>'] = cmp.mapping.complete(), -- Trigger completion
                 ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Confirm selection with Enter
                 ['<Tab>'] = cmp.mapping(function(fallback) -- Tab completion / snippet navigation
                     if cmp.visible() then
                         cmp.select_next_item()
                     elseif luasnip.expand_or_jumpable() then
                         luasnip.expand_or_jump()
                     else
                         fallback()
                     end
                 end, { "i", "s" }), -- i=insert mode, s=select mode
                 ['<S-Tab>'] = cmp.mapping(function(fallback) -- Shift+Tab navigation
                     if cmp.visible() then
                         cmp.select_prev_item()
                     elseif luasnip.jumpable(-1) then
                         luasnip.jump(-1)
                     else
                         fallback()
                     end
                 end, { "i", "s" }),
             }),
             -- Ensure cmp_select is defined if you use it in mappings (it was defined earlier in the file)
             -- local cmp_select = {behavior = cmp.SelectBehavior.Select} -- Make sure this is defined before cmp.setup if used
          })

      print("LSP/CMP config function finished.")
    end
  },

  -- Add other LSP/completion related plugins if any

} -- End with '}'