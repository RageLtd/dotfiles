
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

alias claude="$HOME/.claude/local/claude"

znap eval starship 'starship init zsh --print-full-init'
znap prompt

export PATH="$HOME/.bun/bin:$PATH"

znap eval rbenv 'rbenv init -'


# bun completions
[ -s "/Users/NathanDeVuono/.bun/_bun" ] && source "/Users/NathanDeVuono/.bun/_bun"
