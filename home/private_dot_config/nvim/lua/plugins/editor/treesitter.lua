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

    -- nvim-treesitter's Python query includes "except*" (PEP 654 exception
    -- groups) but the installed parser binary doesn't recognise that token yet.
    -- Neovim 0.12 validates string literals against the grammar and crashes.
    -- Patch the query at startup by stripping that line so the validator passes.
    vim.schedule(function()
      if pcall(vim.treesitter.query.get, "python", "highlights") then return end
      local files = vim.api.nvim_get_runtime_file("queries/python/highlights.scm", true)
      local parts = {}
      for _, f in ipairs(files) do
        local lines = vim.fn.readfile(f)
        lines = vim.tbl_filter(function(l) return not l:match('"except%*"') end, lines)
        parts[#parts + 1] = table.concat(lines, "\n")
      end
      pcall(vim.treesitter.query.set, "python", "highlights", table.concat(parts, "\n"))
    end)
  end,
}
