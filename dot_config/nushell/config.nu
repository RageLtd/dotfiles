# config.nu
#
# Installed by:
# version = "0.113.1"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings,
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R

$env.PATH = ($env.PATH | prepend [
    ($nu.home-dir | path join '.cargo/bin')
    ($nu.home-dir | path join '.bun/bin')
    ($nu.home-dir | path join '.local/bin')
    ($nu.home-dir | path join '.opencode/bin')
    '/opt/homebrew/bin'
    '/opt/homebrew/opt/rustup/bin'
])

# 1Password SSH agent (Linux socket first, then macOS)
let op_sock = ([
    ($nu.home-dir | path join ".1password/agent.sock")
    ($nu.home-dir | path join "Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock")
] | where {|it| $it | path exists } | get 0?)
if $op_sock != null {
    $env.SSH_AUTH_SOCK = $op_sock
}

$env.config.highlight_resolved_externals = true
$env.config.buffer_editor = "zed"
$env.config.show_banner = "short"
$env.EDITOR = "nvim"
$env.VISUAL = "zed"

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
