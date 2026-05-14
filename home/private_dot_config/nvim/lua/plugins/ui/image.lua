return {
  "3rd/image.nvim",
  lazy = true,
  opts = {
    backend  = "kitty",
    processor = "magick_cli",  -- uses ImageMagick CLI, no luarocks needed
    integrations = {},         -- mermaid rendering handled in custom/mermaid.lua
    max_width_window_percentage  = 80,
    max_height_window_percentage = 40,
    window_overlap_clear_enabled = true,
  },
  config = function(_, opts)
    require("image").setup(opts)

    local api = vim.api
    local group = api.nvim_create_augroup("MermaidRender", { clear = true })

    api.nvim_create_autocmd("BufLeave", {
      group   = group,
      pattern = "*.md",
      callback = function(args) require("custom.mermaid").clear(args.buf) end,
    })

    api.nvim_create_autocmd({ "TabLeave", "VimLeave" }, {
      group = group,
      callback = function() require("custom.mermaid").clear_all() end,
    })

    -- Re-render on scroll: KGP needs window-relative coords so we must
    -- recalculate position after every scroll. PNGs are cached so this is fast.
    api.nvim_create_autocmd("WinScrolled", {
      group = group,
      callback = function()
        local bufnr = api.nvim_get_current_buf()
        if vim.bo[bufnr].filetype == "markdown" then
          require("custom.mermaid").render(bufnr)
        end
      end,
    })

    vim.keymap.set("n", "<leader>mr", function()
      require("custom.mermaid").render()
    end, { desc = "Re-render mermaid diagrams" })
  end,
}
