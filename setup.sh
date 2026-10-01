#!/bin/bash
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
ONEPASSWORD_REBOOT_REQUIRED=false

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
        arch)   sudo pacman -S --needed --noconfirm base-devel procps-ng curl file git gnupg ;;
        fedora) sudo dnf group install -y development-tools
                sudo dnf install -y procps-ng curl file git ;;
        debian) sudo apt-get update
                sudo apt-get install -y build-essential procps curl file git ;;
        *)      ;;  # macOS has Xcode CLT via the brew installer; immutable images ship the toolchain
    esac
}

# Homebrew owns the shared toolchain; Linux installs 1Password CLI natively.
install_packages() {
    local system="$1"

    [[ "$system" == "unknown" ]] && { red "Unknown system type"; return 1; }

    install_brew_prereqs "$system"
    install_brew
    brew bundle --file "$SCRIPT_DIR/Brewfile"

    install_1password "$system"
}

install_paru() (
    if [[ "$(id -u)" == "0" ]]; then
        red "Run setup as your normal user; makepkg must not run as root"
        return 1
    fi

    if ! pacman -Q paru &>/dev/null; then
        local build_dir
        build_dir=$(mktemp -d)
        trap 'rm -rf "$build_dir"' EXIT

        # paru's makedepends is the virtual `cargo`; install rustup explicitly so
        # makepkg -s --noconfirm doesn't pick the `rust` provider instead.
        # Arch's rustup ships without a toolchain, so pull stable before building.
        sudo pacman -S --needed --noconfirm rustup
        rustup default stable

        git clone --depth 1 -- https://aur.archlinux.org/paru.git "$build_dir/paru"
        cd "$build_dir/paru"
        makepkg -si --noconfirm
    fi

    # An installed paru can still be incompatible with the current libalpm.
    paru --version
)

configure_1password_apt_repo() {
    local arch
    arch=$(dpkg --print-architecture)
    sudo apt-get install -y ca-certificates gnupg
    curl -fsSL https://downloads.1password.com/linux/keys/1password.asc |
        sudo gpg --dearmor --yes --output /usr/share/keyrings/1password-archive-keyring.gpg
    printf 'deb [arch=%s signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/%s stable main\n' "$arch" "$arch" |
        sudo tee /etc/apt/sources.list.d/1password.list >/dev/null

    sudo install -d -m 755 /etc/debsig/policies/AC2D62742012EA22 /usr/share/debsig/keyrings/AC2D62742012EA22
    curl -fsSL https://downloads.1password.com/linux/debian/debsig/1password.pol |
        sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol >/dev/null
    curl -fsSL https://downloads.1password.com/linux/keys/1password.asc |
        sudo gpg --dearmor --yes --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
}

configure_1password_rpm_repo() {
    # rpm-ostree cannot import keys into the booted, read-only RPM database.
    sudo install -d -m 755 /etc/pki/rpm-gpg
    curl -fsSL https://downloads.1password.com/linux/keys/1password.asc |
        sudo tee /etc/pki/rpm-gpg/RPM-GPG-KEY-1password >/dev/null
    sudo tee /etc/yum.repos.d/1password.repo >/dev/null <<'EOF'
[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-1password
EOF
}

install_1password() {
    local system="$1"

    [[ "$system" != "arch" ]] || install_paru

    if [[ "$system" == "immutable" ]]; then
        local packages=()
        command -v op &>/dev/null || packages+=(1password-cli)
        rpm -q 1password &>/dev/null || packages+=(1password)
        if [[ ${#packages[@]} -gt 0 ]]; then
            configure_1password_rpm_repo
            sudo rpm-ostree install --idempotent "${packages[@]}"
            ONEPASSWORD_REBOOT_REQUIRED=true
            echo "1Password packages queued; reboot to activate them."
        fi
    elif ! command -v op &>/dev/null; then
        case "$system" in
            macos)  red "1Password CLI is missing after brew bundle"; return 1 ;;
            arch)   # The AUR package verifies the vendor signature in its check() step.
                    if ! gpg --list-keys 3FEF9748469ADBE15DA7CA80AC2D62742012EA22 &>/dev/null; then
                        curl -fsSL https://downloads.1password.com/linux/keys/1password.asc | gpg --import
                        gpg --list-keys 3FEF9748469ADBE15DA7CA80AC2D62742012EA22 >/dev/null
                    fi
                    paru -S --needed 1password-cli ;;
            fedora) configure_1password_rpm_repo
                    sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-1password
                    sudo dnf install -y 1password-cli ;;
            debian) configure_1password_apt_repo
                    sudo apt-get update
                    sudo apt-get install -y 1password-cli ;;
            *)      red "Unsupported system for 1Password CLI: $system"; return 1 ;;
        esac
    fi

    if command -v op &>/dev/null; then
        op --version
    elif [[ "$ONEPASSWORD_REBOOT_REQUIRED" != "true" ]]; then
        red "1Password CLI installation did not make op available"
        return 1
    fi
}

# Set zsh as default shell
set_default_shell() {
    local zsh_path
    zsh_path=$(command -v zsh) || { red "zsh not found"; return 1; }

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
    local system
    system=$(detect_system)
    echo "Detected system: $system"

    install_packages "$system"
    set_default_shell
    cleanup_legacy_links
    cleanup_macos_shadows
    apply_dotfiles

    if [[ "$ONEPASSWORD_REBOOT_REQUIRED" == "true" ]]; then
        green "Setup complete — reboot to activate the queued 1Password packages."
    else
        green "Setup complete!"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main
fi
