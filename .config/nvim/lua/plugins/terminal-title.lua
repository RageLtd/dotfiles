return {
  -- Enhanced terminal title with project awareness
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      -- Enhance with project title awareness
      opts.title = {
        enabled = true,
        format = function()
          local project_name = vim.fs.basename(vim.loop.cwd() or "")
          local current_file = vim.fn.expand("%:t")
          
          if current_file ~= "" then
            return string.format("nvim: %s - %s", project_name, current_file)
          else
            return string.format("nvim: %s", project_name)
          end
        end,
      }
      return opts
    end,
  },
}
