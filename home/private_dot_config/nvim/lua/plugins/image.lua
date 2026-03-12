return {
  "3rd/image.nvim",
  build = false,
  opts = {
    backend = "kitty",
    processor = "magick_cli",
    integrations = { markdown = { enabled = true } },
  },
}
