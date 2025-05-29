return {
  -- Task runner for Bun commands (matching your Zed tasks)
  {
    "stevearc/overseer.nvim",
    opts = {
      templates = {
        "builtin",
        "user.bun_run",
        "user.bun_test", 
        "user.bun_install",
        "user.bun_dev",
      },
    },
    keys = {
      { "<leader>tr", "<cmd>OverseerRun<cr>", desc = "Run Task" },
      { "<leader>tt", "<cmd>OverseerToggle<cr>", desc = "Toggle Tasks" },
      { "<leader>ta", "<cmd>OverseerTaskAction<cr>", desc = "Task Actions" },
      { "<leader>br", "<cmd>OverseerRun bun_run<cr>", desc = "Bun Run" },
      { "<leader>bt", "<cmd>OverseerRun bun_test<cr>", desc = "Bun Test" },
      { "<leader>bi", "<cmd>OverseerRun bun_install<cr>", desc = "Bun Install" },
      { "<leader>bd", "<cmd>OverseerRun bun_dev<cr>", desc = "Bun Dev" },
    },
    config = function(_, opts)
      local overseer = require("overseer")
      overseer.setup(opts)
      
      -- Register custom Bun tasks
      overseer.register_template({
        name = "bun_run",
        builder = function(params)
          return {
            cmd = { "bun", "run" },
            args = params.args and { params.args } or {},
            cwd = vim.fn.getcwd(),
          }
        end,
        desc = "Run bun scripts",
        tags = { overseer.TAG.BUILD },
      })
      
      overseer.register_template({
        name = "bun_test", 
        builder = function()
          return {
            cmd = { "bun", "test" },
            cwd = vim.fn.getcwd(),
          }
        end,
        desc = "Run bun tests",
        tags = { overseer.TAG.TEST },
      })
      
      overseer.register_template({
        name = "bun_install",
        builder = function()
          return {
            cmd = { "bun", "install" },
            cwd = vim.fn.getcwd(),
          }
        end,
        desc = "Install bun dependencies",
        tags = { overseer.TAG.BUILD },
      })
      
      overseer.register_template({
        name = "bun_dev",
        builder = function()
          return {
            cmd = { "bun", "run", "dev" },
            cwd = vim.fn.getcwd(),
          }
        end,
        desc = "Run bun dev server",
        tags = { overseer.TAG.BUILD },
      })
    end,
  },
}
