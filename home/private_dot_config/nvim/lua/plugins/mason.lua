return {
  "williamboman/mason-lspconfig.nvim",
  opts = {
    ensure_installed = {
      "lua_ls",
      "tsserver",
      "pyright",
      "clangd",
      "rust-analyzer",
      -- add any other LSP servers you want
    },
  },
}
