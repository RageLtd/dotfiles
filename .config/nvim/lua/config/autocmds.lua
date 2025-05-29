-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Terminal title management
local function get_project_name()
  local cwd = vim.fn.getcwd()
  -- Try to find git root first
  local git_root = vim.fs.find(".git", { upward = true, path = cwd })[1]
  if git_root then
    local project_root = vim.fs.dirname(git_root)
    return vim.fs.basename(project_root)
  end
  
  -- Fall back to current directory name
  return vim.fs.basename(cwd)
end

local function update_terminal_title()
  local project_name = get_project_name()
  local current_file = vim.fn.expand("%:t")
  
  if current_file ~= "" then
    vim.opt.titlestring = string.format("nvim: %s - %s", project_name, current_file)
  else
    vim.opt.titlestring = string.format("nvim: %s", project_name)
  end
end

local title_group = augroup("TerminalTitle", { clear = true })
autocmd({ "BufEnter", "BufWritePost", "DirChanged", "VimEnter" }, {
  group = title_group,
  callback = update_terminal_title,
})

-- Auto-format and organize imports on save (matching Zed code_actions_on_format)
local biome_group = augroup("BiomeFormatting", { clear = true })
autocmd("BufWritePre", {
  group = biome_group,
  pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.json", "*.jsonc" },
  callback = function()
    -- Format with Biome if available
    local clients = vim.lsp.get_active_clients({ bufnr = 0 })
    for _, client in ipairs(clients) do
      if client.name == "biome" then
        vim.lsp.buf.format({ async = false })
        -- Organize imports
        vim.lsp.buf.code_action({
          context = {
            only = { "source.organizeImports.biome" },
            diagnostics = {},
          },
          apply = true,
        })
        break
      end
    end
  end,
})

-- Ensure final newline on save (matching Zed setting)
local newline_group = augroup("EnsureFinalNewline", { clear = true })
autocmd("BufWritePre", {
  group = newline_group,
  pattern = "*",
  callback = function()
    if vim.bo.filetype ~= "diff" then
      local save_cursor = vim.fn.getpos(".")
      vim.cmd([[%s/\s\+$//e]])
      vim.fn.setpos(".", save_cursor)
    end
  end,
})

-- Terminal settings (matching Zed terminal config)
local terminal_group = augroup("TerminalSettings", { clear = true })
autocmd("TermOpen", {
  group = terminal_group,
  pattern = "*",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end,
})

-- Auto-change directory to project root when opening files
local project_group = augroup("ProjectRoot", { clear = true })
autocmd({ "BufRead", "BufNewFile" }, {
  group = project_group,
  callback = function()
    local root_patterns = { ".git", "package.json", "bun.lockb", "node_modules" }
    local root = vim.fs.find(root_patterns, { upward = true })[1]
    if root then
      local root_dir = vim.fs.dirname(root)
      if root_dir and root_dir ~= vim.fn.getcwd() then
        vim.cmd("cd " .. root_dir)
        -- Update title when changing project
        update_terminal_title()
      end
    end
  end,
})
