local FORMAT_TIMEOUT_MS = 500

local FORMATTERS_BY_FT = {
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
  haskell    = { "fourmolu" },
}

return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  opts = {
    formatters_by_ft = FORMATTERS_BY_FT,
    format_on_save = {
      timeout_ms = FORMAT_TIMEOUT_MS,
      lsp_format = "fallback",
    },
  },
}
