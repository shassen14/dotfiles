return {
  "echasnovski/mini.surround",
  version = "*",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    mappings = {
      add            = "gsa",
      delete         = "gsd",
      find           = "gsf",
      find_left      = "gsF",
      highlight      = "gsh",
      replace        = "gsr",
      update_n_lines = "gsn",
    },
  },
}
