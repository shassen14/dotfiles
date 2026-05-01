return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false, -- must be in rtp at startup so its query .scm files are visible
  config = function()
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
  end,
}
