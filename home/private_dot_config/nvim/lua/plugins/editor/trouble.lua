return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  keys = {
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                        desc = "Diagnostics: workspace" },
    { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",           desc = "Diagnostics: current buffer" },
    { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>",                desc = "Diagnostics: symbols" },
    { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                             desc = "Diagnostics: quickfix list" },
    { "[x",         function() require("trouble").prev({ skip_groups = true, jump = true }) end, desc = "Diagnostics: previous item" },
    { "]x",         function() require("trouble").next({ skip_groups = true, jump = true }) end, desc = "Diagnostics: next item" },
  },
  opts = {
    focus = true,
    modes = {
      diagnostics = {
        sort = { "severity", "filename", "pos" },
      },
    },
  },
}
