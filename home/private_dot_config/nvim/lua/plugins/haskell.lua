-- Haskell support via haskell-tools.nvim (manages HLS; replaces lspconfig for .hs).
-- Prereq: install GHC + HLS via ghcup → https://www.haskell.org/ghcup/
--   curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
return {
  "mrcjkb/haskell-tools.nvim",
  version = "^4",
  ft = { "haskell", "lhaskell", "cabal" },
  config = function()
    vim.g.haskell_tools = {
      hls = {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
        settings = {
          haskell = {
            formattingProvider = "fourmolu",
          },
        },
      },
      tools = {
        repl = {
          -- Use cabal repl when a .cabal file is present, otherwise ghci
          prefer_cabal = true,
        },
      },
    }
  end,
  keys = {
    { "<leader>hr", function() vim.cmd("HaskellRepl") end,         ft = "haskell", desc = "Haskell: open REPL" },
    { "<leader>hR", function() vim.cmd("HaskellRepl expand") end,  ft = "haskell", desc = "Haskell: REPL for file" },
    { "<leader>hh", function() require("haskell-tools").hoogle.hoogle_signature() end, ft = "haskell", desc = "Haskell: Hoogle search" },
    { "<leader>he", function() require("haskell-tools").lsp.buf_eval_all() end,        ft = "haskell", desc = "Haskell: eval all snippets" },
  },
}
