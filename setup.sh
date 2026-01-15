#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

    # Add to PATH
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
    local base_pkgs="git zsh starship micro delta"

    case "$system" in
        macos)
            install_brew
            brew install $base_pkgs
            brew install --cask 1password tidal discord signal zed font-hack-nerd-font
            ;;
        immutable)
            # Bazzite/Aurora/Silverblue - use rpm-ostree for 1password, brew for tools
            install_brew
            brew install $base_pkgs tidal discord signal zed font-hack-nerd-font
            
            # Install 1Password via rpm-ostree if not present
            if ! rpm -q 1password &>/dev/null; then
                echo "Installing 1Password via rpm-ostree (requires reboot)..."
                sudo rpm-ostree install 1password || echo "1Password install queued - reboot to complete"
            fi
            ;;
        arch)
            sudo pacman -S --needed --noconfirm $base_pkgs
            
            # Install paru if not present
            if ! command -v paru &>/dev/null; then
                echo "Installing paru..."
                sudo pacman -S --needed --noconfirm base-devel git
                git clone https://aur.archlinux.org/paru-bin.git /tmp/paru-bin
                cd /tmp/paru-bin && makepkg -si --noconfirm
                cd - && rm -rf /tmp/paru-bin
            fi
            
            # Install AUR packages
            paru -S --needed --noconfirm 1password tidal-hifi discord signal-desktop zed ttf-hack-nerd
            ;;
        fedora)
            sudo dnf install -y $base_pkgs
            echo "Install 1password, tidal, discord, signal manually or via Flatpak"
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

# Set zsh as default shell
set_default_shell() {
    local zsh_path=$(which zsh)

    [[ "$SHELL" == *"zsh"* ]] && { green "zsh is already default shell"; return 0; }
    [[ -z "$zsh_path" ]] && { red "zsh not found"; return 1; }

    echo "Setting zsh as default shell..."

    # Add to /etc/shells if not present (Linux)
    if [[ "$OSTYPE" == "linux-gnu"* ]] && [[ -f /etc/shells ]]; then
        grep -q "$zsh_path" /etc/shells || echo "$zsh_path" | sudo tee -a /etc/shells
    fi

    # Use appropriate method based on system
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

# Create symlink safely
link_file() {
    local src="$1" dst="$2"

    [[ "$src" != "$SCRIPT_DIR"/* ]] && { red "Bad source: $src"; return 1; }
    [[ "$dst" == "$SCRIPT_DIR"* ]] && { red "Circular link: $dst"; return 1; }
    [[ ! -e "$src" ]] && { red "Missing: $src"; return 1; }

    mkdir -p "$(dirname "$dst")"

    [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]] && return 0

    rm -rf "$dst"
    ln -s "$src" "$dst"
    echo "Linked: ${dst#$HOME/}"
}

# Symlink all dotfiles
link_dotfiles() {
    echo "Linking dotfiles..."

    while IFS= read -r -d '' src; do
        case "$src" in
            */.git/*|*/setup.sh|*/README.md|*/LICENSE|*.new|*.sample|*_backup*|*/ghostty/*) continue ;;
        esac
        local rel="${src#$SCRIPT_DIR/}"
        link_file "$src" "$HOME/$rel"
    done < <(find "$SCRIPT_DIR" -type f -print0)
}

# Link ghostty config (different path on macOS)
link_ghostty() {
    local src_dir="$SCRIPT_DIR/.config/ghostty"
    local dst_dir=""

    if [[ "$OSTYPE" == "darwin"* ]]; then
        dst_dir="$HOME/Library/Application Support/com.mitchellh.ghostty"
    else
        dst_dir="$HOME/.config/ghostty"
    fi

    [[ ! -d "$src_dir" ]] && return 0

    mkdir -p "$dst_dir"

    if [[ -f "$src_dir/config" ]]; then
        rm -f "$dst_dir/config"
        ln -s "$src_dir/config" "$dst_dir/config"
        echo "Linked: ghostty config"
    fi

    if [[ -d "$src_dir/themes" ]]; then
        rm -rf "$dst_dir/themes"
        ln -s "$src_dir/themes" "$dst_dir/themes"
        echo "Linked: ghostty themes"
    fi
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

# Main
main() {
    [[ "$HOME" == "$SCRIPT_DIR"* ]] && { red "Cannot run from inside HOME"; exit 1; }

    local system=$(detect_system)
    echo "Detected system: $system"

    install_packages "$system"
    install_bun
    set_default_shell
    link_dotfiles
    link_ghostty
    setup_git_signing

    green "Setup complete! Run 'source ~/.zshrc' to apply changes."
}

main
