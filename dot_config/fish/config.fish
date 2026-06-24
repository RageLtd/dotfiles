# Fish shell configuration — ported from Nushell config.nu

# PATH
fish_add_path -p "$HOME/.cargo/bin"
fish_add_path -p "$HOME/.bun/bin"
fish_add_path -p "$HOME/.local/bin"
fish_add_path -p "$HOME/.opencode/bin"
fish_add_path -p /opt/homebrew/bin
fish_add_path -p /opt/homebrew/opt/rustup/bin

# 1Password SSH agent (Linux socket first, then macOS)
if test -S "$HOME/.1password/agent.sock"
    set -gx SSH_AUTH_SOCK "$HOME/.1password/agent.sock"
else if test -S "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    set -gx SSH_AUTH_SOCK "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
end

# Editors
set -gx EDITOR nvim
set -gx VISUAL zed

# Misc
set -gx APOLLO_TELEMETRY_DISABLED true

set fish_greeting

# Cursor — blinking block default (Ghostty can't control this; fish overrides it)
if string match -q -- '*ghostty*' $TERM
    set -g fish_vi_force_cursor 1
end
set fish_cursor_default block blink

# Syntax highlighting — aligned with Bearded Monokai Black
set fish_color_command a9dc76          # green — valid commands
set fish_color_error fc6a67            # red — invalid commands
set fish_color_param c7c7c7            # foreground — arguments
set fish_color_option ffd866           # yellow — flags/options
set fish_color_quote ffd866            # yellow — quoted strings
set fish_color_redirection 78dce8      # blue — pipes and redirects
set fish_color_end e991e3              # magenta — statement terminators (;, &&)
set fish_color_comment 444444          # dim — comments
set fish_color_autosuggestion 444444   # dim — autosuggestions
set fish_color_operator 78e8c6         # cyan — operators
set fish_color_escape 78e8c6           # cyan — escape sequences
set fish_color_valid_path --underline  # underline existing paths
set fish_color_search_match --background=444444

# Starship prompt
starship init fish | source
