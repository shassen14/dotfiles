return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      lua        = { "stylua" },
      python     = { "black", "isort" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      rust       = { "rustfmt" },
      sh         = { "shfmt" },
      yaml       = { "prettier" },
      json       = { "prettier" },
    },
    format_on_save = { timeout_ms = 500, lsp_fallback = true },
  },
}
