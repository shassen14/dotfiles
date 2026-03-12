return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      lua        = { "stylua" },
      python     = { "black", "isort" },
      javascript = { "prettier" },
      typescript = { "prettier" },
      c          = { "clang_format" },
      cpp        = { "clang_format" },
      rust       = { "rustfmt" },
      sh         = { "shfmt" },
      yaml       = { "prettier" },
      json       = { "prettier" },
      toml       = { "taplo" },
    },
    format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
  },
}
