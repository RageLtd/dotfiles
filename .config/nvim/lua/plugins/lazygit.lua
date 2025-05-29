return {
  -- Use built-in Snacks LazyGit (more reliable)
  {
    "folke/snacks.nvim",
    opts = {
      lazygit = {
        configure = true,
        config = {
          floating_window_winblend = 0,
          floating_window_scaling_factor = 0.9,
          floating_window_border_chars = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"},
          floating_window_use_plenary = 0,
          use_neovim_remote = 1,
        },
      },
    },
  },
  
  -- Disable the separate lazygit plugin to avoid conflicts
  {
    "kdheepak/lazygit.nvim",
    enabled = false,
  },
}
