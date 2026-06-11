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

# Cargo
. "$HOME/.cargo/env"

# User paths
path=(
    $HOME/.bun/bin
    $HOME/.cache/.bun/bin
    $HOME/.local/bin
    $HOME/.opencode/bin
    $HOME/bin
    $path
)

# =============================================================================
# Znap Plugin Manager
# =============================================================================
[[ -r ~/.znap/znap.zsh ]] ||
    git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git ~/.znap
source $HOME/.znap/znap.zsh
zstyle ':znap:*' repos-dir ~/.znap/repos

znap source mattmc3/zephyr plugins/{color,completion,directory,editor,environment,history,utility}
znap source zdharma-continuum/fast-syntax-highlighting
znap source zsh-users/zsh-completions
znap source zsh-users/zsh-autosuggestions

# After the znap source line
zle-line-init() { print -Pn '\e[1 q'; }
zle -N zle-line-init

zle-keymap-select() {
  case $KEYMAP in
    vicmd|visual) print -Pn '\e[1 q' ;;
    *)            print -Pn '\e[1 q' ;;
  esac
}

# =============================================================================
# Tool Initialization (only if installed)
# =============================================================================
command -v starship &>/dev/null && { znap eval starship 'starship init zsh --print-full-init'; znap prompt; }

# Bun completions
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# =============================================================================
# Environment Variables
# =============================================================================
export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
export APOLLO_TELEMETRY_DISABLED=true
export HOMEBREW_NO_ENV_HINTS=1

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# opencode
export PATH=$HOME/.opencode/bin:$PATH


# >>> railway initialize >>>
source "$HOME/.railway/env"
# <<< railway initialize <<<
