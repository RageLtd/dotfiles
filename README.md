# dotfiles

Personal dotfiles for macOS and Linux (including immutable distros like Bazzite/Aurora), managed with [chezmoi](https://www.chezmoi.io/).

## Quick Start

```bash
git clone https://github.com/RageLtd/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

## How It Works

chezmoi uses this repo as its source directory (`sourceDir` is pinned by
`.chezmoi.toml.tmpl` on init) and runs in **symlink mode**: plain files are
symlinked into place, so editing a live config edits the repo directly.
Templates (`*.tmpl`) are rendered to real files — re-run `chezmoi apply`
after editing those.

Cross-platform handling lives in the source state, not in scripts:

- `dot_config/*` → `~/.config/*` on every OS
- `Library/Application Support/symlink_nushell.tmpl` → on macOS, points
  nushell's native config/data dir at `~/.config/nushell` (ignored on Linux
  via `.chezmoiignore`)
- `dot_gitconfig.tmpl` → picks the right 1Password `op-ssh-sign` path per OS

## What's Included

- **nushell** - Shell config, Starship prompt
- **zsh** - Fallback shell config with Znap plugin manager
- **git** - Config with delta diff viewer, SSH signing via 1Password
- **ghostty** - Terminal config and themes
- **zed** - Editor settings and keymaps
- **nvim** - LazyVim-based config
- **1Password** - SSH agent config

## Supported Systems

| Platform | Package Manager | 1Password |
|----------|-----------------|-----------|
| macOS | Homebrew | brew cask |
| Bazzite/Aurora/Silverblue | Homebrew + rpm-ostree | rpm-ostree |
| Arch/Manjaro | pacman | AUR |
| Fedora/RHEL | dnf | manual |

## Installed Packages

`git`, `zsh`, `nushell`, `starship`, `micro`, `delta`, `chezmoi`, `bun`, `1password`, `signal`, `zed`, `font-hack-nerd-font`

## Structure

```
dotfiles/                          # chezmoi source directory
├── .chezmoi.toml.tmpl             # chezmoi config (symlink mode)
├── .chezmoiignore                 # per-OS exclusions
├── dot_config/
│   ├── 1Password/                 # SSH agent config
│   ├── ghostty/                   # Terminal config + themes
│   ├── nushell/                   # Shell config
│   ├── nvim/                      # Editor config
│   └── zed/                       # Editor settings
├── Library/Application Support/   # macOS-only nushell symlink
├── dot_gitconfig.tmpl             # Git configuration (templated per OS)
├── dot_zshrc                      # Fallback shell configuration
└── setup.sh                       # Installation script
```

## Day-to-Day

- Edit a symlinked config (zed, nushell, nvim, …): changes land in the repo
  immediately — just commit.
- Edit a template (`dot_gitconfig.tmpl`): run `chezmoi apply` to re-render.
- `chezmoi status` shows drift (e.g. an app replaced a symlink with a real
  file on save); `chezmoi re-add <file>` absorbs it back into the repo.

## Post-Install

1. Restart your terminal
2. On immutable distros: reboot to complete 1Password install
3. Sign into 1Password to enable SSH agent
