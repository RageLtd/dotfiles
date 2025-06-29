# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview
This is a comprehensive dotfiles repository for cross-platform development environments (macOS, Linux distributions). It focuses on modern development workflows with AI integration, sophisticated automation, and robust multi-platform support.

## Key Commands

### Setup and Installation
```bash
# Full setup (packages + dotfiles)
./setup.sh

# Host-specific setup (includes GUI apps like Zed, 1Password)
./setup.sh --host

# Dry run to see what would be installed
./setup.sh --dry-run
```

### Development Tools
- **Primary Editor**: Zed (configured in `.config/zed/`)
- **Terminal**: Ghostty (configured in `.config/ghostty/`)
- **Shell**: Zsh with Znap plugin manager (`.zshrc`)
- **Prompt**: Starship (cross-platform)

## Architecture and Structure

### Core Components
- `setup.sh`: Main installation script (550+ lines) with multi-platform package manager detection
- `.zshrc`: Modern Zsh configuration with plugin management via Znap
- `.config/`: XDG Base Directory compliant configurations
- `.claude/`: Claude AI assistant configuration with MCP servers

### Package Management Strategy
The setup script uses intelligent package manager detection:
1. **Homebrew** (preferred): Auto-installs on macOS/Linux with proper PATH configuration
2. **Fallback managers**: APT (Debian/Ubuntu), DNF (Fedora), Pacman (Arch), APK (Alpine)
3. **Immutable systems**: Special handling for Fedora Silverblue/Kinoite with rpm-ostree
4. **Host detection**: Conditional installation of GUI applications vs server tools

### Configuration Management
- **Symlink-based**: Configurations are symlinked from this repo to their expected locations
- **Loop prevention**: Smart symlink creation with existing file backup
- **Template system**: Some configs use 1Password CLI for secret injection
- **Modular design**: Each component can function independently

### AI Integration Stack
- **Claude Code**: Custom MCP servers (Serena for memory, GitHub, NX)
- **Continue.dev**: Multi-model setup with OpenAI, Ollama, and local embeddings
- **Zed Integration**: Claude plugin with API key management via 1Password
- **Agent profiles**: Custom AI assistant configurations in `.claude/agent_profiles/`

### Development Environment
- **Language Servers**: Biome (JS/TS/JSON/CSS), Solargraph (Ruby), comprehensive LSP setup
- **Runtime Management**: Bun (preferred), Node.js, Ruby (rbenv)
- **Remote Development**: SSH configurations with port forwarding for tunneled connections
- **Version Control**: Enhanced git integration with visual status indicators

### Cross-Platform Considerations
- **PATH Management**: Handles different shell initialization files and PATH priorities
- **Package Availability**: Graceful fallback when packages aren't available on certain platforms
- **Container Support**: Detects containerized environments and adjusts installation accordingly
- **Desktop vs Server**: Conditional installation based on system capabilities

## Important Patterns
- Always check if tools are already installed before attempting installation
- Use `command -v` for command existence checks, not `which`
- Respect XDG Base Directory specification for configuration placement
- Maintain compatibility with both GNU and BSD utilities (prefix with `u` when using uutils-coreutils)
- Template configurations should use 1Password CLI for secret management where applicable