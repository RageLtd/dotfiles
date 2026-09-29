# dotfiles

Personal dotfiles for macOS and Linux (including immutable distros like Bazzite/Aurora), managed with [chezmoi](https://www.chezmoi.io/). Packages come from [Homebrew](https://brew.sh/) on every OS via a single `Brewfile`.

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
- `dot_gitconfig.tmpl` → picks the right 1Password `op-ssh-sign` path per OS
- `Brewfile` → formulae install everywhere; casks (GUI apps, fonts,
  `1password-cli`) and macOS-only formulae sit in an `if OS.mac?` block that
  Linux skips

## What's Included

- **zsh** - Shell config with Znap plugin manager, zsh-patina highlighting, myship/starship prompt
- **git** - Config with delta diff viewer, SSH signing via 1Password
- **ghostty** - Terminal config and themes
- **zed** - Editor settings and keymaps
- **nvim** - LazyVim-based config
- **1Password** - SSH agent config

## Supported Systems

| Platform | Package Manager | 1Password |
|----------|-----------------|-----------|
| macOS | Homebrew | brew cask |
| Bazzite/Aurora/Silverblue | Homebrew | rpm-ostree |
| Arch/Manjaro | Homebrew (pacman for build deps) | skipped (SSH agent forwarding) |
| Fedora/RHEL | Homebrew (dnf for build deps) | skipped (SSH agent forwarding) |
| Ubuntu/Debian | Homebrew (apt for build deps) | skipped (SSH agent forwarding) |

## Packages

Everything is in `Brewfile`. Language toolchains (`bun`, `node`, `rustup`,
`go`, `erlang`/`elixir`, `dotnet`, `ruby`, `python`, `uv`) track brew's
current stable — there is no per-project version manager. Use a versioned
formula (`node@24`) where a specific major matters.

```bash
brew bundle --file ~/dotfiles/Brewfile            # install everything listed
brew bundle check --file ~/dotfiles/Brewfile      # what's missing
brew bundle cleanup --file ~/dotfiles/Brewfile    # installed but unlisted (--force removes)
```

`rustup` is keg-only; each shell rc puts `$HOMEBREW_PREFIX/opt/rustup/bin`
on PATH. Run `rustup default stable` once after a fresh install.

## Structure

```
dotfiles/                          # chezmoi source directory
├── .chezmoi.toml.tmpl             # chezmoi config (symlink mode)
├── .chezmoiignore                 # files kept in the repo but never deployed
├── Brewfile                       # every package, all platforms
├── dot_config/
│   ├── 1Password/                 # SSH agent config
│   ├── ghostty/                   # Terminal config + themes
│   ├── nvim/                      # Editor config
│   └── zed/                       # Editor settings
├── dot_gitconfig.tmpl             # Git configuration (templated per OS)
├── dot_zshrc                      # Shell configuration
└── setup.sh                       # Installation script
```

## Day-to-Day

- Edit a symlinked config (zed, nvim, …): changes land in the repo
  immediately — just commit.
- Edit a template (`dot_gitconfig.tmpl`): run `chezmoi apply` to re-render.
- `chezmoi status` shows drift (e.g. an app replaced a symlink with a real
  file on save); `chezmoi re-add <file>` absorbs it back into the repo.
- Add a package: put it in `Brewfile`, run `brew bundle`.

## Post-Install

1. Restart your terminal
2. `rustup default stable`
3. On immutable distros: reboot to complete 1Password install
4. Sign into 1Password to enable SSH agent
