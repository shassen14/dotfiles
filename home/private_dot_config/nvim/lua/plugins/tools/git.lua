local GITSIGNS = {
  add          = { text = "+" },
  change       = { text = "~" },
  delete       = { text = "_" },
  topdelete    = { text = "‾" },
  changedelete = { text = "~" },
  untracked    = { text = "┆" },
}

return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = GITSIGNS,
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local map = vim.keymap.set
        local opts = { buffer = bufnr }
        local function bmap(lhs, rhs, desc)
          map("n", lhs, rhs, vim.tbl_extend("force", opts, { desc = desc }))
        end

        -- Hunk navigation
        bmap("]h", gs.next_hunk,  "Git: Next hunk")
        bmap("[h", gs.prev_hunk,  "Git: Previous hunk")

        -- Staging
        bmap("<leader>hs", gs.stage_hunk,        "Git: Stage hunk")
        bmap("<leader>hS", gs.stage_buffer,      "Git: Stage buffer")
        bmap("<leader>hu", gs.undo_stage_hunk,   "Git: Undo stage hunk")
        bmap("<leader>hr", gs.reset_hunk,        "Git: Reset hunk")
        bmap("<leader>hR", gs.reset_buffer,      "Git: Reset buffer")

        -- Inspection
        bmap("<leader>hp", gs.preview_hunk,                              "Git: Preview hunk")
        bmap("<leader>hb", function() gs.blame_line({ full = true }) end, "Git: Blame line")
        bmap("<leader>hd", gs.diffthis,                                  "Git: Diff this")
      end,
    },
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>",                              desc = "Git: Open Neogit" },
      { "<leader>gd", "<cmd>DiffviewOpen<cr>",                       desc = "Git: Diff view" },
      { "<leader>gc", "<cmd>Neogit commit<cr>",                      desc = "Git: Commit" },
      { "<leader>gp", "<cmd>Neogit pull<cr>",                        desc = "Git: Pull" },
      { "<leader>gP", "<cmd>Neogit push<cr>",                        desc = "Git: Push" },
    },
    opts = {
      integrations = { diffview = true },
    },
  },
}
