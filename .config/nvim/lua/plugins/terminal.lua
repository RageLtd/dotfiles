return {
  -- Configure Snacks terminal (modern LazyVim terminal)
  {
    "folke/snacks.nvim",
    opts = {
      terminal = {
        win = {
          position = "bottom",
          border = "enabled",
          width = 0.8,
          height = 0.25,
          backdrop = 60,
        },
      },
    },
  },

  -- Disable ToggleTerm to avoid conflicts
  {
    "akinsho/toggleterm.nvim",
    enabled = false,
  },
}
