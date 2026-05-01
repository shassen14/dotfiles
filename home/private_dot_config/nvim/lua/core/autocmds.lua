local function augroup(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

-- Highlight yanked text briefly
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("YankHighlight"),
  callback = function() vim.highlight.on_yank() end,
  desc = "Highlight yanked text",
})

-- Equalize split sizes when the terminal window is resized
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("WindowResize"),
  callback = function() vim.cmd("tabdo wincmd =") end,
  desc = "Equalize split sizes on terminal resize",
})

-- Force-refresh diagnostics when entering a buffer or leaving insert mode.
-- Prevents the stale-diagnostics issue where the LSP stops updating after
-- extended use without a manual LspRestart.
vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
  group = augroup("DiagnosticRefresh"),
  callback = function() vim.diagnostic.show() end,
  desc = "Refresh diagnostics on buffer enter and insert leave",
})

-- Enable treesitter highlighting for filetypes that have installed parsers.
-- Replaces nvim-treesitter's highlight module — Neovim 0.11+ handles this natively.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("TreesitterHighlight"),
  pattern = { "bash", "c", "cpp", "json", "lua", "python", "rust", "toml", "tsx", "typescript", "javascript", "yaml", "html" },
  callback = function(args) pcall(vim.treesitter.start, args.buf) end,
  desc = "Enable built-in treesitter highlighting",
})

-- Strip trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("StripTrailingWhitespace"),
  callback = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[%s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, pos)
  end,
  desc = "Strip trailing whitespace before save",
})
