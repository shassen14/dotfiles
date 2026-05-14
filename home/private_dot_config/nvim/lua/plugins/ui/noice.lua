return {
  "folke/noice.nvim",
  lazy = false,
  dependencies = { "MunifTanjim/nui.nvim" },
  opts = {
    presets = {
      command_palette       = true,  -- floating cmdline + completion menu in the center
      bottom_search         = true,  -- "/" and "?" stay at the bottom (less disruptive)
      long_message_to_split = true,  -- long output (e.g. :messages) opens in a split
      lsp_doc_border        = true,  -- border on LSP hover / signature windows
    },
    -- snacks.nvim handles notifications; don't let noice intercept them
    notify = { enabled = false },
    lsp = {
      override = {
        -- Use noice's prettier markdown renderer for LSP hover docs
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"]                = true,
      },
    },
  },
}
