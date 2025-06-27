# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Formatting and Linting
- **Check Neovim health**: `:checkhealth` (run inside Neovim)
- **Format on save**: Configured via conform.nvim in LazyVim

### Task Management
- **Bun commands**: Access via `<leader>br` (run), `<leader>bt` (test), `<leader>bi` (install), `<leader>bd` (dev)
- **Task runner**: `<leader>tr` to run tasks, `<leader>tt` to toggle task panel

### Development Workflow
- **Start Neovim**: `nvim`
- **Configuration directory**: `~/.config/nvim/`
- **Plugin management**: LazyVim handles plugin installation and updates automatically

## Architecture Overview

This is a **LazyVim-based Neovim configuration** that replicates Zed editor functionality with VSCode-style keybindings.

### Core Structure
- **Entry point**: `init.lua` → `lua/config/lazy.lua` (LazyVim bootstrap)
- **Base configuration**: `lua/config/` directory
  - `options.lua`: Editor settings (2-space indentation, line numbers, whitespace display)
  - `keymaps.lua`: VSCode-style keyboard shortcuts
  - `autocmds.lua`: Automatic commands
- **Plugin configurations**: `lua/plugins/` directory (each plugin in separate file)

### Key Integrations

#### Claude Code Integration (claudecode.nvim)
- **Provider**: WebSocket protocol compatible with VS Code extension
- **Activation**: `<leader>cc` to toggle Claude Code terminal
- **Selection**: `<leader>cs` to send selected text to Claude
- **Diff Management**: `<leader>ca` accept changes, `<leader>cr` reject changes
- **Requirements**: Claude Code CLI installed and accessible
- **Configuration**: `lua/plugins/claudecode.lua`

#### Code Formatting (Biome)
- **Auto-format**: Enabled on save for JS/TS/JSON files
- **Actions**: Fix all + organize imports on save
- **Configuration**: `lua/plugins/biome.lua`

#### Terminal Integration
- **Access**: `<C-\>` or `<C-`>` for terminal toggle
- **Implementation**: Uses Snacks.terminal (modern LazyVim component)

#### Git Integration
- **LazyGit**: `<leader>gg` to open LazyGit interface
- **Modern**: Uses Snacks.lazygit

### VSCode-Style Features
- **File operations**: `<C-s>` save, `<C-z>` undo, `<C-y>` redo
- **Navigation**: `<C-p>` find files, `<C-S-p>` command palette, `<C-S-f>` search
- **Explorer**: `<C-S-e>` toggle file tree (Neo-tree)
- **Comments**: `<C-/>` toggle comments
- **LSP**: `<F12>` go to definition, `<F2>` rename, `<C-S-r>` find references

### Plugin Management Philosophy
- **LazyVim base**: Provides sensible defaults and plugin ecosystem
- **Selective overrides**: Custom plugins extend/override LazyVim defaults
- **Performance**: Lazy loading enabled, minimal startup impact
- **Modularity**: Each plugin configuration is isolated in `lua/plugins/`

### Editor Behavior
- **Indentation**: 2 spaces (matching Zed configuration)
- **Line numbers**: Absolute numbers only (Zed-like, not relative)
- **Whitespace**: Visible with custom listchars
- **Terminal title**: Shows current directory and Neovim
- **Scrolling**: 8-line offset for better context

### Development Notes
- Configuration migrated from Zed editor to maintain familiar workflow
- Biome is the primary formatter/linter (configured for JS/TS ecosystem)
- Task system supports Bun-based development workflows
- Claude Code integration provides VS Code-like AI assistance with native Neovim integration