return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 900,
  init = function()
    -- Snacks auto-detects Ghostty's image protocol and enables image rendering,
    -- which crashes on nvim 0.12.1 due to a treesitter API change. Setting this
    -- global before setup prevents the image module from initializing at all.
    vim.g.snacks_image_enabled = false
  end,
  opts = {
    picker = {
      sources = {
        files = { hidden = false },
        grep  = { hidden = false },
      },
    },
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    bigfile      = { enabled = true },
    image        = { enabled = false },
    statuscolumn = { enabled = false },
    words        = { enabled = false },
  },
  keys = {
    { "<leader>ff", function() require("snacks").picker.files() end,   desc = "Find files" },
    { "<leader>sg", function() require("snacks").picker.grep() end,    desc = "Search grep" },
    { "<leader>fb", function() require("snacks").picker.buffers() end, desc = "Find buffers" },
    { "<leader>fh", function() require("snacks").picker.help() end,    desc = "Find help" },
    { "<leader>fr", function() require("snacks").picker.recent() end,      desc = "Recent files" },
    { "<leader>xd", function() require("snacks").picker.diagnostics() end,   desc = "Diagnostics: picker" },
    { "<leader>fs", function() require("snacks").picker.lsp_symbols() end,   desc = "Find LSP symbols" },
  },
}
