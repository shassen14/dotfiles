-- Floating terminal that persists across toggles.
-- The shell keeps running when the window is hidden; it's only killed on exit
-- or explicit :bd!.
local M = {}

M.buf       = nil
M.win       = nil
M.last_mode = nil   -- 't' = terminal-job, 'n' = terminal-normal
M.last_view = nil
M.caller_win    = nil
M.caller_pos    = nil
M.caller_insert = false

function M.open()
  local w = math.floor(vim.o.columns * 0.75)
  local h = math.floor(vim.o.lines * 0.85)
  local fresh = not (M.buf and vim.api.nvim_buf_is_valid(M.buf))
  if fresh then
    M.buf = vim.api.nvim_create_buf(false, true)
  end
  M.win = vim.api.nvim_open_win(M.buf, true, {
    relative = "editor",
    width    = w,
    height   = h,
    row      = math.floor((vim.o.lines - h) / 2),
    col      = math.floor((vim.o.columns - w) / 2),
    border   = "single",
  })
  if fresh or vim.bo[M.buf].buftype ~= "terminal" then
    vim.fn.termopen(vim.o.shell, {
      on_exit = function()
        vim.schedule(function()
          if M.win and vim.api.nvim_win_is_valid(M.win) then
            vim.api.nvim_win_close(M.win, true)
            M.win = nil
          end
          M.buf = nil
        end)
      end,
    })
    vim.cmd("startinsert")
    return
  end
  vim.api.nvim_set_current_win(M.win)
  -- When focus moves to a terminal buffer, Neovim auto-enters terminal-job
  -- mode which forces the view to the bottom. stopinsert first so winrestview
  -- can set the scroll position, then re-enter terminal mode if needed.
  if M.last_mode ~= "t" then vim.cmd("stopinsert") end
  if M.last_view then vim.fn.winrestview(M.last_view) end
  if M.last_mode == "t" then vim.cmd("startinsert") end
end

function M.hide()
  if M.win and vim.api.nvim_win_is_valid(M.win) then
    vim.api.nvim_set_current_win(M.win)
    M.last_mode = vim.api.nvim_get_mode().mode == "t" and "t" or "n"
    M.last_view = vim.fn.winsaveview()
    vim.api.nvim_win_close(M.win, true)
    M.win = nil
  end
end

function M.toggle()
  if M.win and vim.api.nvim_win_is_valid(M.win) then
    local resume_insert = M.caller_insert
    local caller_win    = M.caller_win
    local caller_pos    = M.caller_pos
    M.hide()
    if resume_insert then
      vim.defer_fn(function()
        if caller_win and vim.api.nvim_win_is_valid(caller_win) then
          vim.api.nvim_set_current_win(caller_win)
        end
        if vim.bo.buftype ~= "" then return end
        if caller_pos then
          local row  = caller_pos[1]
          local col  = caller_pos[2]
          local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""
          local at_eol = col >= #line
          if at_eol then
            pcall(vim.api.nvim_win_set_cursor, 0, { row, math.max(0, #line - 1) })
            vim.cmd("startinsert!")
          else
            pcall(vim.api.nvim_win_set_cursor, 0, caller_pos)
            vim.cmd("startinsert")
          end
        else
          vim.cmd("startinsert")
        end
      end, 10)
    end
  else
    local mode = vim.api.nvim_get_mode().mode
    M.caller_insert = mode:sub(1, 1) == "i"
    M.caller_win    = vim.api.nvim_get_current_win()
    M.caller_pos    = vim.api.nvim_win_get_cursor(0)
    if mode == "n" then
      M.open()
    else
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false
      )
      vim.schedule(M.open)
    end
  end
end

-- Toggle binding: <C-Space> in normal, insert, and terminal modes.
for _, key in ipairs({ "<C-Space>", "<C-@>", "<NUL>" }) do
  vim.keymap.set({ "n", "i", "t" }, key, M.toggle, { desc = "Toggle floating terminal" })
end

-- In a terminal buffer, `gf` opens the file under the cursor in the main
-- (non-floating) window.
vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("FloatTermGf", { clear = true }),
  callback = function(ev)
    vim.keymap.set("n", "gf", function()
      local line = vim.api.nvim_get_current_line()
      local col  = vim.api.nvim_win_get_cursor(0)[2] + 1

      local s, e = col, col
      while s > 1 and not line:sub(s - 1, s - 1):match("%s") do s = s - 1 end
      while e <= #line and not line:sub(e, e):match("%s") do e = e + 1 end
      local token = line:sub(s, e - 1)
      token = token:gsub("^[%(%[%{'`\"]+", ""):gsub("[%)%]%}'\",;:%.]+$", "")

      local path, lnum, cnum
      path, lnum, cnum = token:match("^(.-):(%d+):(%d+)$")
      if not path then path, lnum = token:match("^(.-):(%d+)%-%d+$") end
      if not path then path, lnum = token:match("^(.-):(%d+)$") end
      if not path then path = token end
      lnum = tonumber(lnum)
      cnum = tonumber(cnum)

      if path:sub(1, 1) == "~" then path = vim.fn.expand(path) end
      if path:sub(1, 1) ~= "/" then path = vim.fn.getcwd() .. "/" .. path end
      path = vim.fn.fnamemodify(path, ":p")
      if vim.fn.filereadable(path) ~= 1 then
        vim.notify("Not a file: " .. path, vim.log.levels.WARN)
        return
      end

      local target
      for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if (vim.api.nvim_win_get_config(w).relative or "") == "" then
          target = w
          break
        end
      end

      M.hide()
      if target and vim.api.nvim_win_is_valid(target) then
        vim.api.nvim_set_current_win(target)
      end
      vim.cmd("edit " .. vim.fn.fnameescape(path))
      if lnum then
        pcall(vim.api.nvim_win_set_cursor, 0, { lnum, math.max(0, (cnum or 1) - 1) })
        vim.cmd("normal! zz")
      end
    end, { buffer = ev.buf, desc = "Open file under cursor in main window" })
  end,
})

return M
