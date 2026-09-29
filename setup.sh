#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# Colors
red() { echo -e "\033[0;31m$1\033[0m"; }
green() { echo -e "\033[0;32m$1\033[0m"; }

# Detect package manager and system type
detect_system() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif command -v rpm-ostree &>/dev/null; then
        echo "immutable"  # Bazzite, Aurora, Silverblue
    elif command -v pacman &>/dev/null; then
        echo "arch"
    elif command -v dnf &>/dev/null; then
        echo "fedora"
    elif command -v apt-get &>/dev/null; then
        echo "debian"  # Ubuntu, DGX OS
    else
        echo "unknown"
    fi
}

# Install Homebrew (macOS or Linux)
install_brew() {
    command -v brew &>/dev/null && return 0
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    elif [[ -x "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

# Homebrew on Linux needs the distro's build tools before it can bootstrap
# (https://docs.brew.sh/Homebrew-on-Linux#requirements)
install_brew_prereqs() {
    case "$1" in
        arch)   sudo pacman -S --needed --noconfirm base-devel procps-ng curl file git ;;
        fedora) sudo dnf group install -y development-tools
                sudo dnf install -y procps-ng curl file git ;;
        debian) sudo apt-get update
                sudo apt-get install -y build-essential procps curl file git ;;
        *)      ;;  # macOS has Xcode CLT via the brew installer; immutable images ship the toolchain
    esac
}

# Everything comes from the Brewfile. Linux gets the formulae only — casks
# (GUI apps, fonts, 1Password) are guarded by OS.mac? in the Brewfile, and
# 1Password auth on Linux boxes goes through SSH agent forwarding.
install_packages() {
    local system="$1"

    [[ "$system" == "unknown" ]] && { red "Unknown system type"; return 1; }

    install_brew_prereqs "$system"
    install_brew
    brew bundle --file "$SCRIPT_DIR/Brewfile"

    if [[ "$system" == "immutable" ]] && ! rpm -q 1password &>/dev/null; then
        echo "Installing 1Password via rpm-ostree (requires reboot)..."
        sudo rpm-ostree install 1password || echo "1Password install queued - reboot to complete"
    fi
}

# Set zsh as default shell
set_default_shell() {
    local zsh_path=$(which zsh)

    [[ "$SHELL" == *"zsh"* ]] && { green "zsh is already default shell"; return 0; }
    [[ -z "$zsh_path" ]] && { red "zsh not found"; return 1; }

    echo "Setting zsh as default shell..."

    if [[ -f /etc/shells ]]; then
        grep -q "$zsh_path" /etc/shells || echo "$zsh_path" | sudo tee -a /etc/shells
    fi

    if command -v chsh &>/dev/null; then
        chsh -s "$zsh_path"
    elif command -v lchsh &>/dev/null; then
        echo "$zsh_path" | sudo lchsh "$USER"
    elif command -v usermod &>/dev/null; then
        sudo usermod --shell "$zsh_path" "$USER"
    else
        red "No method available to change shell"
        echo "Configure your terminal emulator to launch zsh instead"
        return 1
    fi

    green "Default shell changed to zsh (restart terminal to apply)"
}

# Remove symlinks created by the pre-chezmoi version of this script
cleanup_legacy_links() {
    local links=(
        "$HOME/.zshrc"
        "$HOME/.gitconfig"
        "$XDG_CONFIG_HOME/1Password"
        "$XDG_CONFIG_HOME/ghostty"
        "$XDG_CONFIG_HOME/nvim"
        "$XDG_CONFIG_HOME/zed"
    )

    for l in "${links[@]}"; do
        if [[ -L "$l" && "$(readlink "$l")" == "$SCRIPT_DIR"* ]]; then
            rm "$l"
            echo "Removed legacy symlink: $l"
        fi
    done
}

apply_dotfiles() {
    echo "Applying dotfiles with chezmoi..."
    chezmoi init --source "$SCRIPT_DIR" --apply
}

# Remove macOS Library configs that shadow XDG paths
cleanup_macos_shadows() {
    [[ "$OSTYPE" != "darwin"* ]] && return 0

    local shadows=(
        "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
        "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty"
    )

    for f in "${shadows[@]}"; do
        if [[ -f "$f" ]]; then
            rm -f "$f"
            echo "Removed macOS shadow config: $f"
        fi
    done
}

main() {
    local system=$(detect_system)
    echo "Detected system: $system"

    install_packages "$system"
    set_default_shell
    cleanup_legacy_links
    cleanup_macos_shadows
    apply_dotfiles

    green "Setup complete!"
}

main
