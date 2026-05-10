-- All servers to install (via mason) and enable
local SERVERS = {
  "lua_ls",
  "ts_ls",
  "pyright",
  "clangd",
  "rust_analyzer",
  "bashls",
  "yamlls",
  "jsonls",
  "taplo",
}

-- Per-server settings applied on top of nvim-lspconfig defaults.
-- Most servers need nothing here; only list what differs from defaults.
local SERVER_OVERRIDES = {
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace   = { checkThirdParty = false },
        telemetry   = { enable = false },
      },
    },
  },
}

-- Non-LSP tools for mason to auto-install (formatters, linters)
local TOOLS = {
  "stylua",
  "black",
  "isort",
  "prettier",
  "shfmt",
  "fourmolu",
}

local DIAGNOSTIC_SIGNS = {
  Error = "E",
  Warn  = "W",
  Hint  = "H",
  Info  = "I",
}

local DIAGNOSTIC_CONFIG = {
  virtual_text     = true,
  signs            = true,
  underline        = true,
  update_in_insert = false,
  severity_sort    = true,
  float = {
    border = "rounded",
    source = "always",
  },
}

local function setup_diagnostics()
  for severity, icon in pairs(DIAGNOSTIC_SIGNS) do
    local hl = "DiagnosticSign" .. severity
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
  end
  vim.diagnostic.config(DIAGNOSTIC_CONFIG)
end

-- All LSP keymaps live here so they're visible in one place.
local function setup_lsp_keymaps()
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
    callback = function(event)
      local map = vim.keymap.set
      local buf = event.buf
      local function bmap(lhs, rhs, desc)
        map("n", lhs, rhs, { buffer = buf, desc = desc })
      end

      bmap("gd",         vim.lsp.buf.definition,     "LSP: Go to definition")
      bmap("gD",         vim.lsp.buf.declaration,    "LSP: Go to declaration")
      bmap("gr",         vim.lsp.buf.references,     "LSP: Go to references")
      bmap("gi",         vim.lsp.buf.implementation, "LSP: Go to implementation")
      bmap("K",          vim.lsp.buf.hover,          "LSP: Hover docs")
      bmap("<leader>la", vim.lsp.buf.code_action,    "LSP: Code action")
      bmap("<leader>ln", vim.lsp.buf.rename,         "LSP: Rename symbol")
      bmap("<leader>lr", "<cmd>LspRestart<cr>",      "LSP: Restart server")
      bmap("<leader>li", "<cmd>LspInfo<cr>",         "LSP: Server info")
      bmap("<leader>lh", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
      end, "LSP: Toggle inlay hints")

      -- Enable inlay hints automatically for servers that support them
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client:supports_method("textDocument/inlayHint") then
        vim.lsp.inlay_hint.enable(true, { bufnr = buf })
      end
    end,
  })
end

return {
  {
    "mason-org/mason.nvim",
    lazy = false,
    opts = { ui = { border = "rounded" } },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = false,
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = TOOLS,
      auto_update      = false,
      run_on_start     = true,
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    lazy = false,
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = SERVERS,
    },
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      "mason-org/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      setup_diagnostics()
      setup_lsp_keymaps()

      -- Apply blink.cmp enhanced capabilities to every server via the "*" glob
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      -- Apply per-server overrides (only lua_ls has any right now)
      for server, override in pairs(SERVER_OVERRIDES) do
        vim.lsp.config(server, override)
      end

      -- Enable all servers; nvim-lspconfig provides their default
      -- cmd/filetypes/root_markers so we don't have to repeat them here.
      vim.lsp.enable(SERVERS)
    end,
  },
}
