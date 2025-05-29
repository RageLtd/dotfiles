return {
  -- Custom commands for project management
  {
    "folke/snacks.nvim",
    config = function(_, opts)
      require("snacks").setup(opts)
      
      -- Add custom command to refresh terminal title
      vim.api.nvim_create_user_command("RefreshTitle", function()
        local project_name = vim.fs.basename(vim.loop.cwd() or "")
        local current_file = vim.fn.expand("%:t")
        
        if current_file ~= "" then
          vim.opt.titlestring = string.format("nvim: %s - %s", project_name, current_file)
        else
          vim.opt.titlestring = string.format("nvim: %s", project_name)
        end
        
        print("Terminal title updated: " .. vim.o.titlestring)
      end, { desc = "Refresh terminal title" })
      
      -- Add command to show current project info
      vim.api.nvim_create_user_command("ProjectInfo", function()
        local cwd = vim.loop.cwd()
        local project_name = vim.fs.basename(cwd or "")
        local git_root = vim.fs.find(".git", { upward = true, path = cwd })[1]
        
        print("Project: " .. project_name)
        print("Path: " .. (cwd or "unknown"))
        if git_root then
          print("Git root: " .. vim.fs.dirname(git_root))
        else
          print("Not in a git repository")
        end
      end, { desc = "Show project information" })
    end,
  },
}
