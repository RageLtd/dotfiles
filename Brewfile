# Brewfile — the shared toolchain, macOS and Linux (linuxbrew).
#
#   brew bundle --file ~/dotfiles/Brewfile            # install everything listed
#   brew bundle check --file ~/dotfiles/Brewfile      # what's missing
#   brew bundle cleanup --file ~/dotfiles/Brewfile    # installed but unlisted (--force removes)
#
# brew tracks current stable; where a specific major matters, use a versioned
# formula (node@24). Casks sit in the OS.mac? block at the bottom — Linux
# machines skip it.

# --- Shells & dotfiles -------------------------------------------------------
brew "zsh"
brew "chezmoi"
brew "zsh-patina"

# --- Language toolchains -----------------------------------------------------
brew "bun"
brew "node"
brew "rustup" if OS.mac? # keg-only: $HOMEBREW_PREFIX/opt/rustup/bin is on PATH in each shell rc; Arch gets rustup from pacman in setup.sh
brew "rust-analyzer"
brew "go"
brew "erlang"
brew "elixir"
brew "dotnet"
brew "ruby"
brew "python"
brew "uv"

# --- Language servers / dev tooling -----------------------------------------
brew "gopls"
brew "golang-migrate"
brew "typescript-language-server"
brew "actions-languageserver"
brew "biome"
brew "tree-sitter-cli"

# --- Git ---------------------------------------------------------------------
brew "git"
brew "gh"
brew "git-delta"
brew "git-filter-repo"
brew "lazygit"

# --- CLI utilities -----------------------------------------------------------
brew "fd"
brew "ripgrep"
brew "fzf"
brew "jq"
brew "just"
brew "hyperfine"
brew "micro"
brew "neovim"
brew "actionlint"
brew "mkcert"
brew "caddy"
brew "gawk"
brew "grep"
brew "watch"
brew "ncdu"
brew "fswatch"
brew "microsocks"
brew "uutils-coreutils"
brew "uutils-diffutils"

# --- Cloud / containers ------------------------------------------------------
brew "lazydocker"
brew "lazyssh"
brew "railway"
brew "opencode"

# --- Libraries ---------------------------------------------------------------
brew "cmake"
brew "ffmpeg"

# =============================================================================
# macOS only — casks, fonts, and formulae with no Linux build
# =============================================================================
if OS.mac?
  cask "1password-cli"    # op — setup.sh installs the native Linux package

  cask "1password"
  cask "codex"
  cask "ghostty"
  cask "notion"
  cask "opencode-desktop"
  cask "puremac"
  cask "raycast"
  cask "signal"
  cask "zed"
  cask "zulip"

  cask "font-hack-nerd-font"
end
