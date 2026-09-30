# dotfiles

Personal dotfiles for macOS and Linux (including immutable distros like Bazzite/Aurora), managed with [chezmoi](https://www.chezmoi.io/). The shared toolchain comes from [Homebrew](https://brew.sh/) on every OS via a single `Brewfile`. Setup also provisions the 1Password CLI (`op`) on every supported system and `paru-bin` on Arch.

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

Cross-platform config handling lives in the source state:

- `dot_config/*` → `~/.config/*` on every OS
- `dot_gitconfig.tmpl` → picks the right 1Password `op-ssh-sign` path per OS
- `Brewfile` → formulae install everywhere; casks (GUI apps, fonts,
  `1password-cli`) and macOS-only formulae sit in an `if OS.mac?` block that
  Linux skips

Linux provisioning exceptions live in `setup.sh`: 1Password CLI uses native
packages, and Arch also gets the `paru-bin` AUR helper.

## What's Included

- **zsh** - Shell config with Znap plugin manager, zsh-patina highlighting, myship/starship prompt
- **git** - Config with delta diff viewer, SSH signing via 1Password
- **ghostty** - Terminal config and themes
- **zed** - Editor settings and keymaps
- **nvim** - LazyVim-based config
- **1Password** - SSH agent config

## Supported Systems

| Platform | Shared Toolchain | 1Password CLI | 1Password Desktop App |
|----------|------------------|---------------|-----------------------|
| macOS | Homebrew | brew cask | brew cask |
| Bazzite/Aurora/Silverblue | Homebrew | signed RPM repo + rpm-ostree | signed RPM repo + rpm-ostree |
| Arch/Manjaro | Homebrew (pacman for build deps) | AUR via paru | not installed by setup |
| Fedora/RHEL | Homebrew (dnf for build deps) | signed RPM repo + dnf | not installed by setup |
| Ubuntu/Debian | Homebrew (apt for build deps) | signed APT repo | not installed by setup |

Arch setup bootstraps `paru-bin` from its AUR build files with `makepkg -si`
if the package is missing, even when `op` is already installed. Run setup as
your normal user, not root. It displays the PKGBUILD and asks for approval;
Paru's own review/install prompts remain enabled for `1password-cli`.
Setup imports the vendor's signing key if needed for the AUR package's
signature verification; it does not disable package checks.
An incompatible `paru-bin` fails setup rather than silently switching helpers.

## Packages

The shared toolchain is in `Brewfile`. Language toolchains (`bun`, `node`, `rustup`,
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

Linux `op` updates follow the native package manager: APT, DNF,
`rpm-ostree upgrade`, or `paru -S --needed 1password-cli` on Arch. Setup skips
CLI installation when `op` is already available and verifies it with
`op --version`. Immutable systems queue missing packages idempotently and
require a reboot before newly installed binaries are available; installation
failures still stop setup.

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
3. On immutable distros: reboot to activate queued 1Password packages, then check `op --version`
4. Where the desktop app is installed, sign into 1Password and enable its SSH agent and CLI integration

CLI installation does not sign into your account. Without a local desktop
app, authenticate manually when you need vault access:

```bash
op account add
eval "$(op signin)"
```

Do not put account credentials or session tokens in this repo or shell startup
files. SSH agent forwarding provides SSH authentication, not `op read` access.
See [1Password's installation guide](https://developer.1password.com/docs/cli/get-started/)
and [manual sign-in guide](https://www.1password.dev/cli/sign-in-manually).

## Checking Setup Changes

With ShellCheck installed:

```bash
bash -n setup.sh
shellcheck setup.sh
python3 -B -m unittest discover -s tests -v
```

The tests mock package managers, downloads, and privileged commands; they do
not install packages, configure system repositories, or contact 1Password.
