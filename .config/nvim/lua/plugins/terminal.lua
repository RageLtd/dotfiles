return {
  -- Configure Snacks terminal (modern LazyVim terminal)
  {
    "folke/snacks.nvim",
    opts = {
      terminal = {
        win = {
          position = "float",
          border = "rounded",
          width = 0.8,
          height = 0.8,
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
