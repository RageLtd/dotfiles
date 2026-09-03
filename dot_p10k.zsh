# ~/.p10k.zsh — Powerlevel10k. Defaults are sensible; this only overrides
# what matters. `p10k configure` will overwrite this if you ever run it.

typeset -g POWERLEVEL9K_MODE=nerdfont-v3   # Hack Nerd Font

typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs newline prompt_char)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
  status command_execution_time direnv
  bun_version rust_version go_version virtualenv
  context
)

# Lean look: no segment backgrounds or powerline separators.
typeset -g POWERLEVEL9K_BACKGROUND=
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
# No padding at the outer edges of either prompt half, and no terminator
# after ❯, so the cursor sits one space after it.
typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=
typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''

# Colours use ANSI names so they come from the terminal palette (Monokai Black
# in Ghostty) rather than fixed 256-colour indexes, and follow theme changes.
typeset -g POWERLEVEL9K_DIR_{DEFAULT,HOME,HOME_SUBFOLDER,ETC,NOT_WRITABLE}_FOREGROUND=blue
typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=green
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=yellow
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=magenta
typeset -g POWERLEVEL9K_VCS_CONFLICTED_FOREGROUND=red
# Text markers for git counters instead of glyphs: ?untracked !unstaged +staged
typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
typeset -g POWERLEVEL9K_VCS_UNSTAGED_ICON='!'
typeset -g POWERLEVEL9K_VCS_STAGED_ICON='+'
typeset -g POWERLEVEL9K_VCS_STASH_ICON='*'
typeset -g POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON='⇣'
typeset -g POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON='⇡'
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=green
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=red
typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=red
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=yellow

# Collapse previous prompts to a bare ❯ when the directory didn't change, so
# scrollback still shows the path at each cd. Also keeps resize redraw garbage
# to the current prompt (zsh + reflowing terminal, not fixable outright).
typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=same-dir

# No ✓ on success; only show exit status when it's non-zero.
typeset -g POWERLEVEL9K_STATUS_OK=false

# user@host only when root or over ssh.
typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=

# Language segments only in directories that look like that kind of project
# (the Starship detect_files equivalent). Without this they run everywhere.
typeset -g POWERLEVEL9K_{RUST,GO}_VERSION_PROJECT_ONLY=true

# Don't run gitstatusd against $HOME itself.
typeset -g POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN='~'

# p10k has no bun segment. Any prompt_<name> function becomes a segment.
# Shown only where a bun lockfile/config marks the project as bun's.
function prompt_bun_version() {
  [[ -f bun.lock || -f bun.lockb || -f bunfig.toml ]] || return
  local v
  v=$(bun --version 2>/dev/null) || return
  p10k segment -f yellow -i $'\uE76F' -t "$v"
}

(( ! $+functions[p10k] )) || p10k reload
