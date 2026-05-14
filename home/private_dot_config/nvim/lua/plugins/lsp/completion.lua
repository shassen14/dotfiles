return {
  "saghen/blink.cmp",
  lazy = false,
  version = "1.*",
  opts = {
    keymap = {
      preset = "default",
      -- Tab / Shift-Tab to navigate the menu; Enter to confirm
      ["<Tab>"]   = { "select_next", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },
      ["<CR>"]    = { "accept", "fallback" },
    },
    appearance = {
      nerd_font_variant = "mono",
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    cmdline = {
      -- ":" shows vim command completions; "/" and "?" search the buffer
      sources = function()
        local cmdtype = vim.fn.getcmdtype()
        if cmdtype == ":" then return { "cmdline" } end
        if cmdtype == "/" or cmdtype == "?" then return { "buffer" } end
        return {}
      end,
    },
    completion = {
      documentation = {
        auto_show          = true,
        auto_show_delay_ms = 400,
      },
      menu = {
        border = "rounded",
      },
    },
    signature = {
      enabled = true,
      window  = { border = "rounded" },
    },
  },
}
