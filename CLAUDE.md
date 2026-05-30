# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Personal dotfiles repo targeting macOS and Linux (including immutable distros like Bazzite/Aurora/Silverblue, plus Arch and Fedora). Everything is symlinked from `~/dotfiles` into `$HOME` via `setup.sh`.

## Key Commands

```bash
./setup.sh              # Full install: detect OS, install packages, symlink everything, configure git signing
```

There is no build step, no test suite, no linter. The only executable artifact is `setup.sh`.

## Architecture

### setup.sh — The Only Entry Point

`setup.sh` does everything in sequence: `detect_system` → `install_packages` → `install_bun` → `set_default_shell` → `link_dotfiles` → `link_ghostty` → `setup_git_signing`. Understanding the flow matters because order is significant — packages must be installed before config is linked, and 1Password must exist before git signing is configured.

**System detection** (`detect_system`) returns one of: `macos`, `immutable`, `arch`, `fedora`, `unknown`. This string drives all platform-conditional logic.

**Package installation** uses Homebrew on macOS and immutable Linux, pacman/paru on Arch, and dnf on Fedora. The base package set is: `git zsh starship micro delta`. GUI apps (1Password, Tidal, Discord, Signal, Zed, Hack Nerd Font) are installed via platform-appropriate methods.

**Symlink strategy** (`link_dotfiles`): walks every file under the repo with `find`, skips `.git/`, `setup.sh`, `README.md`, `LICENSE`, `*.new`, `*.sample`, `*_backup*`, and `ghostty/*` (ghostty has its own linker). For each remaining file, it creates a symlink at the equivalent `$HOME` path. The `link_file` helper has safety guards against circular links and missing sources. Ghostty config gets special handling via `link_ghostty` because macOS uses `~/Library/Application Support/com.mitchellh.ghostty/` while Linux uses `~/.config/ghostty/`.

**Git signing** (`setup_git_signing`): finds the 1Password `op-ssh-sign` binary across known platform paths and sets `gpg.ssh.program` globally.

### Shell Config (.zshrc)

Uses **Znap** as plugin manager (auto-installs on first launch). Plugins: zephyr (color, completion, directory, editor, environment, history, utility), fast-syntax-highlighting, zsh-completions, zsh-autosuggestions. Prompt is **Starship**, initialized through Znap. The SSH agent socket is hardcoded to `~/.1password/agent.sock`.

### Git Config (.gitconfig)

SSH signing via 1Password is on by default (`gpgsign = true`, `format = ssh`). Uses **delta** as pager with side-by-side disabled, OneHalfDark theme. All `https://github.com/` URLs are rewritten to `ssh://git@github.com/`. Pull strategy is rebase. Push auto-sets upstream.

### Editor Configs

- **Ghostty**: Hack Nerd Font Mono, bearded-monokai-black theme. Custom themes stored in `.config/ghostty/themes/`.
- **Zed**: Bearded Theme Monokai Black, VSCode keybindings, biome as formatter for JS/TS/HTML/CSS/JSON/YAML/Markdown, solargraph for Ruby. Agent configured with Mimir ACP server.
- **Neovim**: LazyVim-based config at `.config/nvim/`. Uses lazy.nvim for plugin management.

### 1Password SSH

Agent config at `.config/1Password/ssh/agent.toml` — enables the `rageltd@pm.me` key from the Private vault.

## Critical Rules

1. **NO GIT COMMITS/PUSHES**: Never run `git commit` or `git push`. The human handles all commits.
2. **Read before modifying**: Always read a file before proposing changes to it.
3. **Plan first**: Present a plan and wait for approval before multi-step changes.
4. **Minimal changes**: Keep edits focused on exactly what was asked for.
5. **Match existing style**: No refactoring working code without approval.
6. **No assumptions**: Verify before acting — this repo targets multiple platforms and a wrong change can break setup on any of them.

## Gotchas

- The `.claude/CLAUDE.md` is a symlink to `../CLAUDE.md` — there's only one copy.
- `link_dotfiles` excludes ghostty paths from the general linker — ghostty is handled separately because of the macOS `~/Library/Application Support/` path difference.
- On immutable distros, 1Password installs via `rpm-ostree` which requires a reboot to complete.
- The `.gitconfig` rewrites all GitHub HTTPS URLs to SSH — this means HTTPS clone URLs silently become SSH. Keep this in mind if debugging clone/push failures.
- `SSH_AUTH_SOCK` in `.zshrc` points to `~/.1password/agent.sock`, which only works when 1Password is running with SSH agent enabled.
