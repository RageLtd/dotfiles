-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- VSCode-like keybindings (matching your Zed base_keymap: "VSCode")
-- File operations
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
map({ "n", "i" }, "<C-z>", "<cmd>undo<cr>", { desc = "Undo" })
map({ "n", "i" }, "<C-y>", "<cmd>redo<cr>", { desc = "Redo" })

-- Quick navigation
map("n", "<C-p>", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
map("n", "<C-S-p>", "<cmd>Telescope commands<cr>", { desc = "Command Palette" })
map("n", "<C-S-f>", "<cmd>Telescope live_grep<cr>", { desc = "Search in Files" })
map("n", "<C-S-e>", function() Snacks.explorer() end, { desc = "Toggle Explorer" })

-- Terminal toggle (using Snacks.terminal - modern LazyVim)
map("n", "<C-`>", function() Snacks.terminal() end, { desc = "Terminal" })
map("t", "<C-`>", "<cmd>close<cr>", { desc = "Hide Terminal" })
map("n", "<C-\\>", function() Snacks.terminal() end, { desc = "Terminal" })
map("t", "<C-\\>", "<cmd>close<cr>", { desc = "Hide Terminal" })

-- Line number toggles (handy for different editing modes)
map("n", "<leader>ln", "<cmd>set number!<cr>", { desc = "Toggle Line Numbers" })
map("n", "<leader>lr", "<cmd>set relativenumber!<cr>", { desc = "Toggle Relative Numbers" })
map("n", "<leader>ll", function()
  if vim.opt.relativenumber:get() then
    vim.opt.relativenumber = false
    vim.opt.number = true
  else
    vim.opt.relativenumber = true
    vim.opt.number = true
  end
end, { desc = "Toggle Relative/Absolute Numbers" })

-- Comment toggle (VSCode-like)
map({ "n", "v" }, "<C-/>", "gcc", { desc = "Toggle Comment", remap = true })
map("i", "<C-/>", "<esc>gcci", { desc = "Toggle Comment", remap = true })

-- LSP mappings (VSCode-like)
map("n", "<F12>", vim.lsp.buf.definition, { desc = "Go to Definition" })
map("n", "<C-S-o>", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "Go to Symbol" })
map("n", "<C-S-r>", "<cmd>Telescope lsp_references<cr>", { desc = "Find References" })
map("n", "<F2>", vim.lsp.buf.rename, { desc = "Rename Symbol" })
map("n", "<C-S-k>", vim.lsp.buf.hover, { desc = "Hover Documentation" })

-- Panel toggles
map("n", "<leader>e", function() Snacks.explorer() end, { desc = "Explorer" })

-- Explorer file visibility toggles (Snacks explorer)
map("n", "<leader>eh", function() Snacks.explorer() end, { desc = "Toggle Explorer" })
map("n", "<leader>ei", function() 
  -- Toggle gitignored files visibility in explorer
  vim.notify("Use 'I' key inside explorer to toggle ignored files", vim.log.levels.INFO)
  Snacks.explorer()
end, { desc = "Explorer - Toggle Ignored Files" })

-- Git integration (using modern Snacks.lazygit)
map("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "LazyGit" })

-- Terminal alternatives (using leader key)
map("n", "<leader>tt", function() Snacks.terminal() end, { desc = "Terminal" })
map("n", "<leader>tf", function() Snacks.terminal() end, { desc = "Terminal Float" })

-- Bun tasks (matching your Zed tasks)
map("n", "<leader>br", "<cmd>!bun run<cr>", { desc = "Bun Run" })
map("n", "<leader>bt", "<cmd>!bun test<cr>", { desc = "Bun Test" })
map("n", "<leader>bi", "<cmd>!bun install<cr>", { desc = "Bun Install" })
map("n", "<leader>bd", "<cmd>!bun run dev<cr>", { desc = "Bun Dev" })

-- Note: <leader>cc is used by Claude Code plugin
