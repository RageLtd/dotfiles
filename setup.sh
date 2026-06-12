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

# Install packages based on system type
install_packages() {
    local system="$1"
    local base_pkgs="git zsh nushell starship micro delta"

    case "$system" in
        macos)
            install_brew
            brew install $base_pkgs
            brew install --cask 1password signal zed font-hack-nerd-font
            ;;
        immutable)
            install_brew
            brew install $base_pkgs signal zed font-hack-nerd-font

            if ! rpm -q 1password &>/dev/null; then
                echo "Installing 1Password via rpm-ostree (requires reboot)..."
                sudo rpm-ostree install 1password || echo "1Password install queued - reboot to complete"
            fi
            ;;
        arch)
            sudo pacman -S --needed --noconfirm $base_pkgs

            if ! command -v paru &>/dev/null; then
                echo "Installing paru..."
                sudo pacman -S --needed --noconfirm base-devel git
                git clone https://aur.archlinux.org/paru-bin.git /tmp/paru-bin
                cd /tmp/paru-bin && makepkg -si --noconfirm
                cd - && rm -rf /tmp/paru-bin
            fi

            paru -S --needed --noconfirm 1password signal-desktop zed ttf-hack-nerd
            ;;
        fedora)
            sudo dnf install -y $base_pkgs
            echo "Install 1password and signal manually or via Flatpak"
            ;;
        *)
            red "Unknown system type"
            return 1
            ;;
    esac
}

# Install bun
install_bun() {
    command -v bun &>/dev/null && { green "bun already installed"; return 0; }
    echo "Installing bun..."
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"
}

# Set nushell as default shell
set_default_shell() {
    local nu_path=$(which nu)

    [[ "$SHELL" == *"nu"* ]] && { green "nushell is already default shell"; return 0; }
    [[ -z "$nu_path" ]] && { red "nushell not found"; return 1; }

    echo "Setting nushell as default shell..."

    if [[ -f /etc/shells ]]; then
        grep -q "$nu_path" /etc/shells || echo "$nu_path" | sudo tee -a /etc/shells
    fi

    if command -v chsh &>/dev/null; then
        chsh -s "$nu_path"
    elif command -v lchsh &>/dev/null; then
        echo "$nu_path" | sudo lchsh "$USER"
    elif command -v usermod &>/dev/null; then
        sudo usermod --shell "$nu_path" "$USER"
    else
        red "No method available to change shell"
        echo "Configure your terminal emulator to launch nu instead"
        return 1
    fi

    green "Default shell changed to nushell (restart terminal to apply)"
}

# Convention: directories → XDG_CONFIG_HOME, root files → HOME
link_dotfiles() {
    echo "Linking dotfiles..."

    local skip=("setup.sh" "README.md" "LICENSE" ".git" ".gitignore")

    for item in "$SCRIPT_DIR"/* "$SCRIPT_DIR"/.[!.]*; do
        [[ ! -e "$item" ]] && continue
        local name="$(basename "$item")"

        local should_skip=false
        for s in "${skip[@]}"; do
            [[ "$name" == "$s" ]] && { should_skip=true; break; }
        done
        $should_skip && continue

        if [[ -d "$item" ]]; then
            local dst="$XDG_CONFIG_HOME/$name"
            [[ -L "$dst" && "$(readlink "$dst")" == "$item" ]] && continue
            mkdir -p "$XDG_CONFIG_HOME"
            rm -rf "$dst"
            ln -s "$item" "$dst"
            echo "Linked: $name → $dst"
        elif [[ -f "$item" ]]; then
            local dst="$HOME/$name"
            [[ -L "$dst" && "$(readlink "$dst")" == "$item" ]] && continue
            rm -f "$dst"
            ln -s "$item" "$dst"
            echo "Linked: $name → $dst"
        fi
    done
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

# Configure 1Password SSH signing for git
setup_git_signing() {
    local op_ssh_sign=""

    if [[ -x "/Applications/1Password.app/Contents/MacOS/op-ssh-sign" ]]; then
        op_ssh_sign="/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    elif [[ -x "/opt/1Password/op-ssh-sign" ]]; then
        op_ssh_sign="/opt/1Password/op-ssh-sign"
    elif command -v op-ssh-sign &>/dev/null; then
        op_ssh_sign="$(which op-ssh-sign)"
    fi

    if [[ -n "$op_ssh_sign" ]]; then
        git config --global gpg.ssh.program "$op_ssh_sign"
        green "Git SSH signing configured: $op_ssh_sign"
    else
        echo "1Password SSH signing not found - skipping git signing setup"
    fi
}

main() {
    local system=$(detect_system)
    echo "Detected system: $system"

    install_packages "$system"
    install_bun
    set_default_shell
    link_dotfiles
    cleanup_macos_shadows
    setup_git_signing

    green "Setup complete!"
}

main
