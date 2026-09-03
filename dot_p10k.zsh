# ~/.p10k.zsh — Powerlevel10k. Defaults are sensible; this only overrides
# what matters. `p10k configure` will overwrite this if you ever run it.

typeset -g POWERLEVEL9K_MODE=nerdfont-v3   # Hack Nerd Font

typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs newline prompt_char)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  status command_execution_time direnv
  node_version rust_version go_version virtualenv
  context
)

# Lean look: no segment backgrounds or powerline separators.
typeset -g POWERLEVEL9K_BACKGROUND=
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '

# Clearing the background leaves the dir segment's per-class default
# foregrounds behind, and the HOME class disappears on a black terminal.
# One colour for every class.
typeset -g POWERLEVEL9K_DIR_{DEFAULT,HOME,HOME_SUBFOLDER,ETC,NOT_WRITABLE}_FOREGROUND=31
typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true

# Language segments only in directories that look like that kind of project
# (the Starship detect_files equivalent). Without this they run everywhere.
typeset -g POWERLEVEL9K_{NODE,RUST,GO}_VERSION_PROJECT_ONLY=true

# Don't run gitstatusd against $HOME itself.
typeset -g POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN='~'

(( ! $+functions[p10k] )) || p10k reload
