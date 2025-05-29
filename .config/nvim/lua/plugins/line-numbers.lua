return {
  -- Override LazyVim line number defaults
  {
    "LazyVim/LazyVim",
    opts = {
      -- Ensure our line number preferences override LazyVim defaults
      defaults = {
        autocmds = false, -- Disable LazyVim autocmds that might change line numbers
      },
    },
  },

  -- Additional line number configuration
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      -- Ensure line numbers are set correctly on startup
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          vim.opt.number = true
          vim.opt.relativenumber = false
        end,
      })
      return opts
    end,
  },
}
