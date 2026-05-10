local M = {}

local api = vim.api
local fn  = vim.fn
local cache_dir = fn.stdpath("cache") .. "/mermaid"
local active = {}  -- bufnr -> list of img handles

local function get_mermaid_blocks(bufnr)
  local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local blocks = {}
  local i = 1
  while i <= #lines do
    if lines[i]:match("^%s*```+%s*mermaid%s*$") then
      local content_lines = {}
      i = i + 1
      while i <= #lines and not lines[i]:match("^%s*```+%s*$") do
        table.insert(content_lines, lines[i])
        i = i + 1
      end
      table.insert(blocks, {
        content = table.concat(content_lines, "\n"),
        buf_row = i,  -- 0-indexed row after closing fence
      })
    end
    i = i + 1
  end
  return blocks
end

local mmdc_bin = nil
local function find_mmdc()
  if mmdc_bin then return mmdc_bin end
  local r = vim.system({ "sh", "-c", "which mmdc" }, { text = true }):wait()
  if r.code == 0 then mmdc_bin = r.stdout:gsub("%s+$", "") end
  return mmdc_bin
end

-- image.nvim with KGP uses screen coordinates, so we pass a window-relative
-- row. Rendering outside the viewport causes the image to appear at the top.
local function place_image(bufnr, winnr, png, buf_row)
  local ok, image_api = pcall(require, "image")
  if not ok then return end
  if not api.nvim_win_is_valid(winnr) then return end
  if not api.nvim_buf_is_valid(bufnr) then return end
  if api.nvim_win_get_buf(winnr) ~= bufnr then return end

  local win_top = api.nvim_win_call(winnr, function() return fn.line("w0") - 1 end)
  local win_h   = api.nvim_win_get_height(winnr)
  local win_row = buf_row - win_top

  if win_row < 0 or win_row >= win_h then return end  -- not in viewport

  local img = image_api.from_file(png, {
    id     = "mermaid_" .. bufnr .. "_" .. buf_row,
    window = winnr,
    row    = win_row,
    col    = 0,
    with_virtual_padding = true,
  })
  if not img then return end
  img:render()
  active[bufnr] = active[bufnr] or {}
  table.insert(active[bufnr], img)
end

local function render_block(bufnr, winnr, block)
  local mmdc = find_mmdc()
  if not mmdc then
    vim.notify("mermaid: mmdc not found — run: npm install -g @mermaid-js/mermaid-cli", vim.log.levels.WARN)
    return
  end
  fn.mkdir(cache_dir, "p")
  local hash   = fn.sha256(block.content)
  local input  = cache_dir .. "/" .. hash .. ".mmd"
  local output = cache_dir .. "/" .. hash .. ".png"

  local function place() place_image(bufnr, winnr, output, block.buf_row) end

  if fn.filereadable(output) == 1 then
    vim.schedule(place)
  else
    fn.writefile(vim.split(block.content, "\n"), input)
    vim.system(
      { mmdc, "-i", input, "-o", output, "-b", "transparent", "-t", "dark", "-s", "2" },
      {},
      vim.schedule_wrap(function(r)
        if r.code == 0 then place() end
      end)
    )
  end
end

function M.clear(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  for _, img in ipairs(active[bufnr] or {}) do
    pcall(function() img:clear() end)
  end
  active[bufnr] = {}
end

function M.clear_all()
  for bufnr in pairs(active) do M.clear(bufnr) end
end

function M.render(bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  local winnr = api.nvim_get_current_win()
  M.clear(bufnr)
  for _, block in ipairs(get_mermaid_blocks(bufnr)) do
    render_block(bufnr, winnr, block)
  end
end

return M
