return {
  "williamboman/mason-lspconfig.nvim",
  opts = {
    ensure_installed = {
      "lua_ls",
      "ts_ls",
      "pyright",
      "clangd",
      "rust_analyzer",
      "bashls",
      "yamlls",
      "jsonls",
      "taplo",
    },
  },
}
