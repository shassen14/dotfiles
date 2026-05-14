local JS_LANGS = { "javascript", "typescript" }
local C_LANGS  = { "c", "cpp" }

-- Builds a path inside the mason data directory
local function mason_pkg(pkg, ...)
  local parts = { vim.fn.stdpath("data"), "mason", "packages", pkg, ... }
  return table.concat(parts, "/")
end

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
      "mfussenegger/nvim-dap-python",
      "leoluz/nvim-dap-go",
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle breakpoint" },
      { "<leader>dc", function() require("dap").continue() end,          desc = "Debug: Continue" },
      { "<leader>di", function() require("dap").step_into() end,         desc = "Debug: Step into" },
      { "<leader>do", function() require("dap").step_over() end,         desc = "Debug: Step over" },
      { "<leader>dO", function() require("dap").step_out() end,          desc = "Debug: Step out" },
      { "<leader>du", function() require("dapui").toggle() end,          desc = "Debug: Toggle UI" },
    },
    config = function()
      local dap    = require("dap")
      local dapui  = require("dapui")

      require("dapui").setup()
      require("nvim-dap-virtual-text").setup()
      require("dap-python").setup("python")
      require("dap-go").setup()

      -- Node / TypeScript
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            mason_pkg("js-debug-adapter", "js-debug", "src", "dapDebugServer.js"),
            "${port}",
          },
        },
      }
      for _, lang in ipairs(JS_LANGS) do
        dap.configurations[lang] = {
          {
            type    = "pwa-node",
            request = "launch",
            name    = "Launch file",
            program = "${file}",
            cwd     = "${workspaceFolder}",
          },
        }
      end

      -- C / C++
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = mason_pkg("codelldb", "extension", "adapter", "codelldb"),
          args    = { "--port", "${port}" },
        },
      }
      for _, lang in ipairs(C_LANGS) do
        dap.configurations[lang] = {
          {
            type         = "codelldb",
            request      = "launch",
            name         = "Launch",
            program      = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd          = "${workspaceFolder}",
            stopOnEntry  = false,
          },
        }
      end

      -- Auto open/close dapui with debug sessions
      dap.listeners.after.event_initialized["dapui_config"]  = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end
    end,
  },
}
