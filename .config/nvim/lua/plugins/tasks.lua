return {
  -- Task runner for Bun commands (matching your Zed tasks)
  {
    "stevearc/overseer.nvim",
    opts = {
      templates = {
        "builtin",
      },
    },
    keys = {
      { "<leader>tr", "<cmd>OverseerRun<cr>", desc = "Run Task" },
      { "<leader>tt", "<cmd>OverseerToggle<cr>", desc = "Toggle Tasks" },
      { "<leader>ta", "<cmd>OverseerTaskAction<cr>", desc = "Task Actions" },
    },
    config = function(_, opts)
      local overseer = require("overseer")
      overseer.setup(opts)
    end,
  },
}
