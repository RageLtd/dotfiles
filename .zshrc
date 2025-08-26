
# .zshrc is sourced in interactive shells.
# It should contain commands to set up aliases,
# functions, options, key bindings, etc.
#

# Download Znap, if it's not there yet.
[[ -r ~/.znap/znap.zsh ]] ||
    git clone --depth 1 -- \
        https://github.com/marlonrichert/zsh-snap.git ~/.znap
source ~/.znap/znap.zsh  # Start Znap
zstyle ':znap:*' repos-dir ~/.znap/repos

znap source mattmc3/zephyr plugins/{color,completion,directory,editor,environment,history,utility}

znap source zdharma-continuum/fast-syntax-highlighting
znap source zsh-users/zsh-completions
znap source zsh-users/zsh-autosuggestions

znap eval rbenv 'rbenv init -'

znap eval starship 'starship init zsh --print-full-init'
znap prompt

export PATH="$HOME/.bun/bin:$PATH"
export PATH="/opt/homebrew/bin/:$PATH"

export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"

# bun completions
[ -s "/Users/NathanDeVuono/.bun/_bun" ] && source "/Users/NathanDeVuono/.bun/_bun"
export PATH="/Users/rageltd/.cache/.bun/bin:$PATH"
export PATH="/Users/rageltd/.local/bin:$PATH"

export COMPOSE_BAKE=true

# opencode
export PATH=/Users/rageltd/.opencode/bin:$PATH

# opencode
export PATH=/Users/rageltd/bin:$PATH

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/rageltd/.lmstudio/bin"
# End of LM Studio CLI section
