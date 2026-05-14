return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false, -- must be in rtp at startup so its query .scm files are visible
  build = ":TSUpdate", -- keep parser binaries in sync with query files
  opts = {
    ensure_installed = { "haskell" },
    auto_install = true,
  },
  config = function(_, opts)
    -- Neovim 0.12 changed match capture format: captures can now be a table
    -- of nodes instead of a single TSNode. nvim-treesitter's query_predicates
    -- still expect a single node, so they crash when they get a table.
    -- Patch get_range to unwrap array captures and guard against nil.
    local orig = vim.treesitter.get_range
    vim.treesitter.get_range = function(node, source, metadata)
      if type(node) == "table" then node = node[1] end
      if node == nil then return 0, 0, 0, 0 end
      return orig(node, source, metadata)
    end
    require("nvim-treesitter.configs").setup(opts)
  end,
}
