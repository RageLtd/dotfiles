-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

-- Line number configuration
opt.number = true         -- Show absolute line numbers
opt.relativenumber = false -- Disable relative line numbers (Zed-like)

-- Editor settings to match Zed config
opt.tabstop = 2          -- Tab size: 2 (matching Zed)
opt.shiftwidth = 2       -- Indent size: 2
opt.softtabstop = 2      -- Soft tab size: 2
opt.expandtab = true     -- Use spaces instead of tabs

-- Show whitespaces (boundary equivalent)
opt.listchars = {
  tab = "→ ",
  trail = "·",
  extends = "›",
  precedes = "‹",
  nbsp = "␣",
}
opt.list = true

-- Ensure final newline on save
opt.fixendofline = true

-- Terminal title configuration
opt.title = true                    -- Enable terminal title
opt.titlelen = 0                    -- No length limit
opt.titlestring = "%{v:progname} - %{substitute(getcwd(), $HOME, \"~\", \"\")}"

-- Additional editor improvements
opt.scrolloff = 8        -- Keep 8 lines above/below cursor
opt.sidescrolloff = 8    -- Keep 8 columns left/right of cursor
opt.wrap = false         -- Don\`t wrap lines
opt.linebreak = true     -- Break lines at word boundaries if wrap is enabled
