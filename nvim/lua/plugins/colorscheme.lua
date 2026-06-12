return {
  -- Bearded theme
  {
    "Ferouk/bearded-nvim",
    name = "bearded",
    priority = 1000,
    build = function()
      local doc = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy", "bearded", "doc")
      pcall(vim.cmd, "helptags " .. doc)
    end,
    config = function()
      require("bearded").setup({
        flavor = "monokai-black",
      })
      vim.cmd.colorscheme("bearded")
    end,
  },
}
