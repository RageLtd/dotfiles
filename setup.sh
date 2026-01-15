#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IS_HOST=false
[[ "$1" == "--host" ]] && IS_HOST=true

# Colors
red() { echo -e "\033[0;31m$1\033[0m"; }
green() { echo -e "\033[0;32m$1\033[0m"; }

# Detect package manager
detect_pm() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "brew"
    elif command -v brew &>/dev/null; then
        echo "brew"  # Immutable distro with brew
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    else
        echo "none"
    fi
}

# Install Homebrew (macOS or Linux immutable)
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

# Install packages based on package manager
install_packages() {
    local pm="$1"
    local base_pkgs="git zsh starship micro delta"
    
    case "$pm" in
        brew)
            install_brew
            brew install $base_pkgs
            if $IS_HOST && [[ "$OSTYPE" == "darwin"* ]]; then
                brew install --cask zed 1password
                brew install 1password-cli
            fi
            ;;
        pacman)
            sudo pacman -S --needed --noconfirm $base_pkgs
            if $IS_HOST; then
                echo "Install zed, 1password from AUR manually if needed"
            fi
            ;;
        dnf)
            sudo dnf install -y $base_pkgs
            if $IS_HOST; then
                echo "Install zed, 1password manually if needed"
            fi
            ;;
        *)
            red "No supported package manager found"
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

# Create symlink safely
link_file() {
    local src="$1" dst="$2"
    
    # Safety: src must be in dotfiles, dst must be in $HOME but not dotfiles
    [[ "$src" != "$SCRIPT_DIR"/* ]] && { red "Bad source: $src"; return 1; }
    [[ "$dst" == "$SCRIPT_DIR"* ]] && { red "Circular link: $dst"; return 1; }
    [[ ! -e "$src" ]] && { red "Missing: $src"; return 1; }
    
    mkdir -p "$(dirname "$dst")"
    
    # Already correctly linked
    [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]] && return 0
    
    # Remove existing and link
    rm -rf "$dst"
    ln -s "$src" "$dst"
    echo "Linked: ${dst#$HOME/}"
}

# Symlink all dotfiles
link_dotfiles() {
    echo "Linking dotfiles..."
    
    while IFS= read -r -d '' src; do
        case "$src" in
            */.git/*|*/setup.sh|*/README.md|*/LICENSE|*.new|*.sample|*_backup*) continue ;;
        esac
        local rel="${src#$SCRIPT_DIR/}"
        link_file "$src" "$HOME/$rel"
    done < <(find "$SCRIPT_DIR" -type f -print0)
}

# Set zsh as default shell
set_default_shell() {
    local zsh_path=$(which zsh)

    # Already using zsh
    [[ "$SHELL" == *"zsh"* ]] && { green "zsh is already default shell"; return 0; }

    # Verify zsh is installed
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
        # Immutable distros (Bazzite, Aurora, Silverblue)
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


# Host-specific setup (1Password injection)

# Configure 1Password SSH signing for git
setup_git_signing() {
    local op_ssh_sign=""
    
    # Find op-ssh-sign binary
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
setup_host() {
    $IS_HOST || return 0
    command -v op &>/dev/null || { echo "1Password CLI not found"; return 0; }
    
    echo "Setting up host config..."
    op signin
}

# Main
main() {
    [[ "$HOME" == "$SCRIPT_DIR"* ]] && { red "Cannot run from inside HOME"; exit 1; }
    
    local pm=$(detect_pm)
    echo "Detected package manager: $pm"
    
    install_packages "$pm"
    install_bun
    set_default_shell
    link_dotfiles
    setup_git_signing
    setup_host
    
    green "Setup complete! Run 'source ~/.zshrc' to apply changes."
}

main
