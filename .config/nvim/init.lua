-- Initialize rbenv before loading anything else
if vim.fn.executable("rbenv") == 1 then
  vim.env.PATH = vim.fn.expand("~/.rbenv/shims") .. ":" .. vim.env.PATH
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
