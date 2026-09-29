return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        -- show dotfiles (.gitignore, .claude/) but keep git-ignored paths hidden
        explorer = { hidden = true, ignored = false },
        files = { hidden = true },
      },
    },
  },
}
