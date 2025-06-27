#!/bin/bash
set -e

IS_HOST=false
# if host is passed in as an argument, skip some tools
if [ "$1" = "--host" ]; then
    IS_HOST=true
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Homebrew if not present
install_homebrew() {
    if ! command_exists brew; then
        echo "Installing Homebrew..."
        
        # Download and run Homebrew installer
        if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
            echo "Homebrew installation completed"
            
            # Add Homebrew to PATH for current session and future sessions
            if [[ "$OSTYPE" == "linux-gnu"* ]]; then
                # Linux Homebrew paths
                if [[ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
                    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
                    
                    # Add to shell configs
                    for shell_config in ~/.bashrc ~/.zshrc ~/.profile; do
                        if [[ -f "$shell_config" ]] || [[ "$shell_config" == ~/.bashrc ]] || [[ "$shell_config" == ~/.zshrc ]]; then
                            if ! grep -q "linuxbrew" "$shell_config" 2>/dev/null; then
                                echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$shell_config"
                            fi
                        fi
                    done
                else
                    echo "Warning: Homebrew installed but not found at expected location"
                    return 1
                fi
            elif [[ "$OSTYPE" == "darwin"* ]]; then
                # macOS Homebrew paths
                if [[ -x "/opt/homebrew/bin/brew" ]]; then
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                elif [[ -x "/usr/local/bin/brew" ]]; then
                    eval "$(/usr/local/bin/brew shellenv)"
                else
                    echo "Warning: Homebrew installed but not found at expected location"
                    return 1
                fi
            fi
            
            # Verify installation
            if command_exists brew; then
                echo "Homebrew successfully installed and configured"
                return 0
            else
                echo "Homebrew installation appears to have failed"
                return 1
            fi
        else
            echo "Homebrew installation failed"
            return 1
        fi
    else
        echo "Homebrew already installed"
        return 0
    fi
}

# Function to install packages using Homebrew
install_packages_brew() {
    local packages="git zsh starship micro bun"
    local missing_packages=""
    
    echo "Checking which packages need to be installed..."
    for package in $packages; do
        if ! brew list "$package" >/dev/null 2>&1; then
            missing_packages="$missing_packages $package"
        else
            echo "$package is already installed"
        fi
    done
    
    if [[ -n "$missing_packages" ]]; then
        echo "Installing missing packages with Homebrew:$missing_packages"
        brew install $missing_packages
    else
        echo "All packages are already installed"
    fi
    
    if $IS_HOST; then
        echo "Checking host-specific tools..."
        local missing_casks=""
        
        # Check cask applications
        if ! brew list --cask zed >/dev/null 2>&1; then
            missing_casks="$missing_casks zed"
        else
            echo "zed is already installed"
        fi
        
        if ! brew list --cask 1password >/dev/null 2>&1; then
            missing_casks="$missing_casks 1password"
        else
            echo "1password is already installed"
        fi
        
        if ! brew list 1password-cli >/dev/null 2>&1; then
            missing_casks="$missing_casks 1password-cli"
        else
            echo "1password-cli is already installed"
        fi
        
        if [[ -n "$missing_casks" ]]; then
            echo "Installing missing host-specific tools:$missing_casks"
            # Install casks and regular packages separately
            for cask in $missing_casks; do
                if [[ "$cask" == "zed" || "$cask" == "1password" ]]; then
                    brew install --cask "$cask"
                else
                    brew install "$cask"
                fi
            done
        else
            echo "All host-specific tools are already installed"
        fi
    fi
}

# Function to check if system is immutable
is_immutable_system() {
    # Check for rpm-ostree (Fedora Silverblue/Kinoite/etc.)
    command_exists rpm-ostree && return 0
    
    # Check for NixOS
    [[ -f /etc/NIXOS ]] && return 0
    
    # Check for other immutable indicators
    [[ -f /run/ostree-booted ]] && return 0
    
    return 1
}

# Function to install packages with fallback package managers
install_packages_fallback() {
    packages="git zsh starship micro"
    debian_packages="git zsh micro"

    if command_exists apk; then
        echo "Detected Alpine based system. Using APK."
        
        # Check which packages are missing for Alpine
        missing_packages=""
        for package in $packages; do
            if ! apk info -e "$package" >/dev/null 2>&1; then
                missing_packages="$missing_packages $package"
            else
                echo "$package is already installed"
            fi
        done
        
        if [[ -n "$missing_packages" ]]; then
            echo "Installing missing packages with APK:$missing_packages"
            # Check if we're in a container or have limited privileges
            if ! sudo apk update 2>/dev/null; then
                echo "Warning: Cannot update package database. Trying without sudo..."
                apk update && apk add --no-cache $missing_packages
            else
                sudo apk update && sudo apk add --no-cache $missing_packages
            fi
        else
            echo "All packages are already installed"
        fi
        
        # Install starship separately for Alpine
        if ! command_exists starship; then
            echo "Installing starship for Alpine..."
            curl -sS https://starship.rs/install.sh | sh -s -- -y
        else
            echo "starship is already installed"
        fi
        
    elif command_exists apt; then
        echo "Detected Debian-based system. Using APT."
        
        # Check which packages are missing for Debian/Ubuntu
        missing_packages=""
        for package in $debian_packages; do
            if ! dpkg -l | grep -q "^ii  $package "; then
                missing_packages="$missing_packages $package"
            else
                echo "$package is already installed"
            fi
        done
        
        if [[ -n "$missing_packages" ]]; then
            echo "Installing missing packages with APT:$missing_packages"
            sudo apt update && sudo apt install -y $missing_packages
        else
            echo "All packages are already installed"
        fi
        
        # Install starship separately
        if ! command_exists starship; then
            echo "Installing starship..."
            curl -sS https://starship.rs/install.sh | sh -s -- -y
        else
            echo "starship is already installed"
        fi

        if $IS_HOST; then
            if ! command_exists zed; then
                echo "Installing Zed editor..."
                curl -f https://zed.dev/install.sh | sh
            else
                echo "Zed editor is already installed"
            fi
            
            if ! dpkg -l | grep -q "^ii  1password "; then
                echo "Installing 1Password via APT repository..."
                sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0xFBB75451A3A4D1D8
                sudo sh -c 'echo "deb [arch=amd64] https://downloads.1password.com/linux/debian/ stable main" > /etc/apt/sources.list.d/1password.list'
                sudo apt update && sudo apt install -y 1password 1password-cli
            else
                echo "1Password is already installed"
            fi
        fi
        
    elif command_exists dnf || command_exists rpm-ostree; then
        if is_immutable_system; then
            echo "Detected immutable Fedora system (Silverblue/Kinoite/etc.). Using rpm-ostree."
            echo "Installing base packages with rpm-ostree..."
            
            # Check what's already installed to avoid conflicts (excluding starship)
            rpm_packages="git zsh micro"
            installed_packages=""
            for pkg in $rpm_packages; do
                if ! rpm -q "$pkg" >/dev/null 2>&1; then
                    installed_packages="$installed_packages $pkg"
                fi
            done
            
            if [[ -n "$installed_packages" ]]; then
                sudo rpm-ostree install $installed_packages
                echo ""
                echo "====================================================="
                echo "IMPORTANT: System packages have been staged."
                echo "Please reboot your system and re-run this script to"
                echo "complete the installation of remaining components."
                echo "====================================================="
                echo ""
                read -p "Reboot now? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    sudo systemctl reboot
                else
                    echo "Please reboot manually when ready."
                    exit 0
                fi
            else
                echo "All base packages already installed via rpm-ostree."
            fi
            
            # Install starship to user directory (works on immutable systems)
            if ! command_exists starship; then
                echo "Installing starship for immutable Fedora..."
                curl -sS https://starship.rs/install.sh | sh -s -- -y
            else
                echo "starship is already installed"
            fi
            
        else
            echo "Detected mutable Fedora-based system. Using DNF."
            
            # Check which packages are missing for Fedora (excluding starship)
            rpm_packages="git zsh micro"
            missing_packages=""
            for package in $rpm_packages; do
                if ! rpm -q "$package" >/dev/null 2>&1; then
                    missing_packages="$missing_packages $package"
                else
                    echo "$package is already installed"
                fi
            done
            
            if [[ -n "$missing_packages" ]]; then
                echo "Installing missing packages with DNF:$missing_packages"
                sudo dnf install -y $missing_packages
            else
                echo "All packages are already installed"
            fi
            
            # Install starship separately (not available in DNF)
            if ! command_exists starship; then
                echo "Installing starship..."
                curl -sS https://starship.rs/install.sh | sh -s -- -y
            else
                echo "starship is already installed"
            fi
        fi

        if $IS_HOST; then
            if ! command_exists zed; then
                echo "Installing Zed editor..."
                curl -f https://zed.dev/install.sh | sh
            else
                echo "Zed editor is already installed"
            fi
            
            # Check if 1Password is installed
            if is_immutable_system; then
                if ! rpm -q 1password >/dev/null 2>&1 && ! rpm -q 1password-cli >/dev/null 2>&1; then
                    echo "Installing 1Password on immutable system via rpm-ostree..."
                    sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
                    sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
                    sudo rpm-ostree install 1password 1password-cli
                    echo "1Password installation staged. Reboot required to complete installation."
                else
                    echo "1Password is already installed"
                fi
            else
                if ! rpm -q 1password >/dev/null 2>&1; then
                    echo "Installing 1Password via DNF repository..."
                    sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
                    sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
                    sudo dnf check-update -y 1password 1password-cli && sudo dnf install 1password 1password-cli
                else
                    echo "1Password is already installed"
                fi
            fi
        fi

    elif command_exists pacman; then
        echo "Detected Arch Linux-based system. Using pacman."
        
        # Check which packages are missing for Arch
        missing_packages=""
        for package in $packages base-devel; do
            if ! pacman -Qi "$package" >/dev/null 2>&1; then
                missing_packages="$missing_packages $package"
            else
                echo "$package is already installed"
            fi
        done
        
        if [[ -n "$missing_packages" ]]; then
            echo "Installing missing packages with pacman:$missing_packages"
            sudo pacman -Syu --noconfirm --needed $missing_packages
        else
            echo "All packages are already installed"
        fi
        
        # Install paru if not present
        if ! command_exists paru; then
            echo "Installing paru AUR helper..."
            git clone https://aur.archlinux.org/paru-bin.git /tmp/paru-bin
            cd /tmp/paru-bin && makepkg -si --noconfirm && cd - && rm -rf /tmp/paru-bin
        else
            echo "paru is already installed"
        fi

        # Only install ML4W on traditional Arch (not in containers or minimal installs)
        if [[ -z "$CONTAINER" ]] && [[ -d "/usr/share/xsessions" || -d "/usr/share/wayland-sessions" ]]; then
            echo "Installing ML4W dotfiles"
            bash -c "$(curl -s https://raw.githubusercontent.com/mylinuxforwork/dotfiles/main/setup-arch.sh)" || echo "ML4W installation failed, continuing..."
        fi

        if $IS_HOST; then
            # Check which AUR packages are missing
            missing_aur=""
            for package in 1password 1password-cli zed; do
                if ! pacman -Qi "$package" >/dev/null 2>&1; then
                    missing_aur="$missing_aur $package"
                else
                    echo "$package is already installed"
                fi
            done
            
            if [[ -n "$missing_aur" ]]; then
                echo "Installing missing AUR packages via paru:$missing_aur"
                paru -S --noconfirm --needed $missing_aur
            else
                echo "All AUR packages are already installed"
            fi
        fi
        
    else
        echo "Error: No supported package manager found on this system."
        echo "Detected commands:"
        command_exists apt && echo "  - apt (but conditions not met)"
        command_exists dnf && echo "  - dnf (but conditions not met)"
        command_exists pacman && echo "  - pacman (but conditions not met)"
        command_exists apk && echo "  - apk (but conditions not met)"
        exit 1
    fi
    
    # Install bun separately for non-homebrew systems
    if ! command_exists bun; then
        echo "Installing bun runtime..."
        curl -fsSL https://bun.sh/install | bash
        # Add bun to PATH
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
        
        # Add to shell configs if they exist
        for shell_config in ~/.bashrc ~/.zshrc ~/.profile; do
            if [[ -f "$shell_config" ]] || [[ "$shell_config" == ~/.bashrc ]] || [[ "$shell_config" == ~/.zshrc ]]; then
                if ! grep -q "BUN_INSTALL" "$shell_config" 2>/dev/null; then
                    echo 'export BUN_INSTALL="$HOME/.bun"' >> "$shell_config"
                    echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> "$shell_config"
                fi
            fi
        done
    fi
}

# Install packages (prefer Homebrew when possible)
echo "Attempting to install and use Homebrew..."

# Try to install Homebrew first on most systems
should_use_homebrew=true

# Don't use Homebrew on these systems where it's problematic
if command_exists apk && [[ -f /etc/alpine-release ]]; then
    echo "Alpine Linux detected - using native package manager instead of Homebrew"
    should_use_homebrew=false
elif is_immutable_system; then
    echo "Immutable system detected - using native package manager for system packages"
    should_use_homebrew=false
elif [[ -f /etc/arch-release ]] && [[ -z "$FORCE_HOMEBREW" ]]; then
    echo "Arch Linux detected - using native package manager (set FORCE_HOMEBREW=1 to override)"
    should_use_homebrew=false
fi

if $should_use_homebrew; then
    # Try to install Homebrew
    if install_homebrew; then
        echo "Homebrew installation successful, using Homebrew for package management"
        install_packages_brew
    else
        echo "Homebrew installation failed, falling back to native package manager"
        install_packages_fallback
    fi
else
    install_packages_fallback
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_dir="$SCRIPT_DIR"
target_dir="$HOME"

echo "Symlinking dotfiles from $source_dir to $target_dir"

# Function to create symlink with directory creation
create_symlink() {
    local src="$1"
    local dest="$2"
    
    # Skip the setup script itself
    if [[ "$(basename "$src")" == "setup.sh" ]]; then
        return
    fi
    
    # Skip if source doesn't exist
    if [[ ! -e "$src" ]]; then
        echo "Warning: Source does not exist: $src"
        return
    fi
    
    # Check if destination already points to the correct source
    if [[ -L "$dest" ]] && [[ "$(readlink "$dest")" == "$src" ]]; then
        echo "Already linked correctly: $dest -> $src"
        return
    fi
    
    # Create parent directory if it doesn't exist
    local dest_dir="$(dirname "$dest")"
    if [[ ! -d "$dest_dir" ]]; then
        echo "Creating directory: $dest_dir"
        mkdir -p "$dest_dir"
    fi
    
    # Remove existing file/symlink if it exists
    if [[ -e "$dest" ]] || [[ -L "$dest" ]]; then
        echo "Removing existing: $dest"
        rm -rf "$dest"
    fi
    
    # Create symlink
    echo "Linking: $src -> $dest"
    if ! ln -s "$src" "$dest"; then
        echo "Error: Failed to create symlink $src -> $dest"
        return 1
    fi
}

# Find all files and directories in the source directory (excluding .git and the script itself)
# Use a safer approach to avoid symlink loops
while IFS= read -r -d '' file; do
    # Get relative path from source directory
    relative_path="${file#$source_dir/}"
    target_path="$target_dir/$relative_path"
    
    # Skip if this would create a symlink loop
    if [[ "$target_path" -ef "$file" ]]; then
        echo "Skipping potential symlink loop: $file"
        continue
    fi
    
    create_symlink "$file" "$target_path"
done < <(find "$source_dir" -type f -not -path "*/.git/*" -not -name "setup.sh" -print0)

# Also handle directories that should be symlinked entirely
while IFS= read -r -d '' dir; do
    # Skip if this directory contains files we're already linking individually
    if find "$dir" -maxdepth 1 -type f -not -path "*/.git/*" | grep -q .; then
        continue
    fi
    
    relative_path="${dir#$source_dir/}"
    target_path="$target_dir/$relative_path"
    
    # Skip if this would create a symlink loop
    if [[ "$target_path" -ef "$dir" ]]; then
        echo "Skipping potential symlink loop: $dir"
        continue
    fi
    
    create_symlink "$dir" "$target_path"
done < <(find "$source_dir" -type d -not -path "*/.git" -not -path "*/.git/*" -not -path "$source_dir" -print0)

# Host-specific configuration
if $IS_HOST; then
    echo "Setting up host-specific configuration..."
    if command_exists op; then
        op signin
        if [[ -f "$HOME/.continue/config.yaml.sample" ]]; then
            op inject -f -i "$HOME/.continue/config.yaml.sample" -o "$HOME/.continue/config.yaml"
        fi
    else
        echo "Warning: 1Password CLI not found, skipping config injection"
    fi
fi

echo "Setup complete!"
echo "Please restart your shell or run 'source ~/.zshrc' to apply changes."