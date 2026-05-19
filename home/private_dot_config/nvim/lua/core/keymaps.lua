local map = vim.keymap.set

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Resize windows with arrows
map("n", "<C-Up>",    "<cmd>resize +2<cr>",          { desc = "Increase window height" })
map("n", "<C-Down>",  "<cmd>resize -2<cr>",          { desc = "Decrease window height" })
map("n", "<C-Left>",  "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Buffer navigation
map("n", "<S-l>", "<cmd>bnext<cr>",     { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<leader>bd", function()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  if #bufs > 1 then
    vim.cmd("bprevious")
  end
  vim.cmd("bdelete #")
end, { desc = "Delete buffer" })

-- Move selected lines up/down
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })
map("n", "<A-j>", "<cmd>m .+1<cr>==",  { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==",  { desc = "Move line up" })

-- Better indenting (stay in visual mode)
map("v", "<", "<gv", { desc = "Outdent selection" })
map("v", ">", ">gv", { desc = "Indent selection" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Diagnostic navigation (built into nvim, explicit here for which-key visibility)
map("n", "[d", vim.diagnostic.goto_prev,  { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next,  { desc = "Next diagnostic" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic float" })

-- Terminal mode: jk exits to normal mode (mirrors insert-mode habit)
map("t", "jk", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Terminal mode: navigate to adjacent nvim splits without leaving the keyboard row
map("t", "<C-h>", [[<C-\><C-n><C-w>h]], { desc = "Terminal: move to left window" })
map("t", "<C-j>", [[<C-\><C-n><C-w>j]], { desc = "Terminal: move to lower window" })
map("t", "<C-k>", [[<C-\><C-n><C-w>k]], { desc = "Terminal: move to upper window" })
map("t", "<C-l>", [[<C-\><C-n><C-w>l]], { desc = "Terminal: move to right window" })
