# dotfiles

Personal dotfiles for macOS and Linux (including immutable distros like Bazzite/Aurora).

## Quick Start

```bash
git clone https://github.com/RageLtd/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

## What's Included

- **zsh** - Shell config with Znap plugin manager, Starship prompt
- **git** - Config with delta diff viewer, SSH signing via 1Password
- **ghostty** - Terminal config and themes
- **zed** - Editor settings and keymaps
- **claude code** - CLAUDE.md instructions and settings

## Supported Systems

| Platform | Package Manager | 1Password |
|----------|-----------------|-----------|
| macOS | Homebrew | brew cask |
| Bazzite/Aurora/Silverblue | Homebrew + rpm-ostree | rpm-ostree |
| Arch/Manjaro | pacman | AUR |
| Fedora/RHEL | dnf | manual |

## Installed Packages

`git`, `zsh`, `starship`, `micro`, `delta`, `bun`, `1password`, `tidal`, `discord`, `signal`, `zed`, `font-hack-nerd-font`

## Structure

```
dotfiles/
├── .claude/           # Claude Code config
├── .config/
│   ├── ghostty/       # Terminal config + themes
│   ├── zed/           # Editor settings
│   └── 1Password/     # SSH agent config
├── .gitconfig         # Git configuration
├── .zshrc             # Shell configuration
├── CLAUDE.md          # Claude Code instructions
└── setup.sh           # Installation script
```

## Post-Install

1. Restart your terminal (or `source ~/.zshrc`)
2. On immutable distros: reboot to complete 1Password install
3. Znap will auto-install plugins on first shell launch
4. Sign into 1Password to enable SSH agent
