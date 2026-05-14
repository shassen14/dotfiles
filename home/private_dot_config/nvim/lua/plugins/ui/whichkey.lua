return {
  "folke/which-key.nvim",
  lazy = false,
  opts = {
    preset = "modern",
    delay  = 500,
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    wk.add({
      { "<leader>b", group = "buffer" },
      { "<leader>d", group = "debug" },
      { "<leader>e", desc  = "Show diagnostic float" },
      { "<leader>f", group = "find" },
      { "<leader>g", group = "git" },
      { "<leader>h", group = "hunk" },
      { "<leader>l", group = "lsp" },
      { "<leader>x", group = "diagnostics" },
    })
  end,
}
