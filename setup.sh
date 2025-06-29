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
    local packages="git zsh starship micro"
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
    
    # Install bun separately (not available in Homebrew)
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
    else
        echo "bun is already installed"
    fi
}

# Install packages
echo "Attempting to install and use Homebrew..."
if install_homebrew; then
    echo "Homebrew installation successful, using Homebrew for package management"
    install_packages_brew
else
    echo "Homebrew installation failed, continuing with dotfiles setup"
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"

echo "Setting up dotfiles from $DOTFILES_DIR"

# CRITICAL SAFETY CHECK: Never create symlinks that could overwrite dotfiles
if [[ "$HOME" == "$DOTFILES_DIR"* ]]; then
    echo "FATAL ERROR: This script is running from within the home directory"
    echo "This would create circular symlinks. Move the dotfiles to a separate directory."
    exit 1
fi

# Function to create a symlink - with absolute safety checks
create_file_symlink() {
    local source_file="$1"
    local target_file="$2"
    
    # SAFETY CHECK 1: Source must be absolute and inside dotfiles directory
    if [[ ! "$source_file" = "$DOTFILES_DIR"/* ]]; then
        echo "ERROR: Source file $source_file is not inside dotfiles directory"
        return 1
    fi
    
    # SAFETY CHECK 2: Target must be absolute and OUTSIDE dotfiles directory
    if [[ "$target_file" = "$DOTFILES_DIR"* ]]; then
        echo "ERROR: Target $target_file is inside dotfiles directory - would create circular symlink"
        return 1
    fi
    
    # SAFETY CHECK 3: Target must be in home directory
    if [[ ! "$target_file" = "$HOME"/* ]]; then
        echo "ERROR: Target $target_file is not in home directory"
        return 1
    fi
    
    # SAFETY CHECK 4: Source file must exist and be a regular file (not a symlink)
    if [[ ! -f "$source_file" ]] || [[ -L "$source_file" ]]; then
        echo "ERROR: Source file $source_file does not exist, is not a regular file, or is a symlink"
        return 1
    fi
    
    # SAFETY CHECK 5: Prevent any symlink creation that could affect dotfiles
    local source_realpath="$(realpath "$source_file")"
    local target_realpath="$(realpath "$(dirname "$target_file")")/$(basename "$target_file")"
    
    if [[ "$source_realpath" == "$target_realpath" ]]; then
        echo "ERROR: Source and target resolve to the same file"
        return 1
    fi
    
    # Create target directory if it doesn't exist
    local target_dir="$(dirname "$target_file")"
    if [[ ! -d "$target_dir" ]]; then
        echo "Creating directory: $target_dir"
        mkdir -p "$target_dir"
    fi
    
    # Check if symlink already exists and points to correct location
    if [[ -L "$target_file" ]] && [[ "$(readlink "$target_file")" == "$source_file" ]]; then
        echo "Already linked: $target_file -> $source_file"
        return 0
    fi
    
    # Remove existing file/symlink if it exists
    if [[ -e "$target_file" ]] || [[ -L "$target_file" ]]; then
        echo "Removing existing: $target_file"
        rm -rf "$target_file"
    fi
    
    # Create the symlink
    echo "Linking: $source_file -> $target_file"
    ln -s "$source_file" "$target_file"
}

# Generate list of all files FIRST, then process them
# This prevents the script from processing files it creates during execution
echo "Scanning for files to symlink..."
temp_file_list=$(mktemp)

# Find all files and write to temp file
find "$DOTFILES_DIR" -type f -print0 | while IFS= read -r -d '' file; do
    # Skip excluded files
    case "$file" in
        */.git/*|*/.git|*/.config/git/*|*/setup.sh|*/README.md|*/LICENSE)
            echo "Excluded: $file" >&2
            ;;
        *)
            echo "$file" >> "$temp_file_list"
            ;;
    esac
done

echo "Creating symlinks for all dotfiles..."
while IFS= read -r source_file; do
    [[ -z "$source_file" ]] && continue
    
    # Calculate relative path from dotfiles directory
    relative_path="${source_file#$DOTFILES_DIR/}"
    target_file="$HOME/$relative_path"
    
    # Create symlink with safety checks
    create_file_symlink "$source_file" "$target_file"
done < "$temp_file_list"

# Clean up temp file
rm -f "$temp_file_list"

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