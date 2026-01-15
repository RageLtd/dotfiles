# .zshrc - Interactive shell configuration

# =============================================================================
# PATH Configuration (consolidated)
# =============================================================================
typeset -U PATH  # Deduplicate PATH entries

# Homebrew (macOS or Linux)
if [[ -x "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -x "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# User paths
path=(
    $HOME/.bun/bin
    $HOME/.cache/.bun/bin
    $HOME/.local/bin
    $HOME/.opencode/bin
    $HOME/.lmstudio/bin
    $HOME/.moose/bin
    $HOME/bin
    $path
)

# =============================================================================
# Znap Plugin Manager
# =============================================================================
[[ -r ~/.znap/znap.zsh ]] ||
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git ~/.znap
source ~/.znap/znap.zsh
zstyle ':znap:*' repos-dir ~/.znap/repos

znap source mattmc3/zephyr plugins/{color,completion,directory,editor,environment,history,utility}
znap source zdharma-continuum/fast-syntax-highlighting
znap source zsh-users/zsh-completions
znap source zsh-users/zsh-autosuggestions

# =============================================================================
# Tool Initialization (only if installed)
# =============================================================================
command -v rbenv &>/dev/null && znap eval rbenv 'rbenv init -'
command -v starship &>/dev/null && { znap eval starship 'starship init zsh --print-full-init'; znap prompt; }

# Bun completions
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# =============================================================================
# Environment Variables
# =============================================================================
export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
export APOLLO_TELEMETRY_DISABLED=true
export CLICKHOUSE_DATABASE=data_services
