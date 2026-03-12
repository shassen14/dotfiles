return {
  "3rd/image.nvim",
  build = "make",
  opts = {
    backend = "kitty",
    processor = "magick_cli",
    integrations = { markdown = { enabled = true } },
  },
}
