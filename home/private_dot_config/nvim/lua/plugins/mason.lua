return {
  {
    "mason-org/mason-lspconfig.nvim",
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
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "black",
        "isort",
        "prettier",
        "shfmt",
        "taplo",
      },
    },
  },
}
