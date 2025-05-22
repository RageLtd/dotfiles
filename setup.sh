#!/bin/sh
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

# Determine if sudo is needed and set sudo_cmd accordingly
sudo_cmd=""
if [ "$(id -u)" -ne 0 ]; then # If not root
    # If 'brew' is not the package manager being used by this script for these operations,
    # and we are not root, then 'sudo' is required.
    if ! command_exists brew; then
        if command_exists sudo; then
            sudo_cmd="sudo"
        else
            echo "Error: This script is not running as root, 'sudo' command is not found, and 'brew' is not available for package management as per this script's logic."
            echo "Please run as root or ensure 'sudo' is installed and in PATH."
            exit 1
        fi
    # If 'brew' exists, sudo_cmd remains empty, as 'brew' commands in this script are not prefixed with sudo.
    fi
fi

# Function to install packages
install_packages() {
    packages="git starship zsh micro"

    if command_exists apk; then
        echo "Detected Alpine based system. Using APK."
        $sudo_cmd apk update && $sudo_cmd apk add --no-cache $packages
    elif command_exists apt; then
        echo "Detected Debian-based system. Using APT."
        $sudo_cmd apt update && $sudo_cmd apt install -y $packages

        if ! command_exists op && $IS_HOST; then
            curl -f https://zed.dev/install.sh | sh
            $sudo_cmd apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0xFBB75451A3A4D1D8
            $sudo_cmd sh -c 'echo "deb [arch=amd64] https://downloads.1password.com/linux/debian/ stable main" > /etc/apt/sources.list.d/1password.list'
            $sudo_cmd apt update && $sudo_cmd apt install -y 1password 1password-cli
        fi
    elif command_exists dnf; then
        echo "Detected Fedora-based system. Using DNF."
        $sudo_cmd dnf install -y $packages

        if ! command_exists op && $IS_HOST; then
            curl -f https://zed.dev/install.sh | sh
            $sudo_cmd rpm --import https://downloads.1password.com/linux/keys/1password.asc
            $sudo_cmd sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
            $sudo_cmd dnf check-update -y 1password 1password-cli && $sudo_cmd dnf install 1password 1password-cli
        fi

    elif command_exists pacman; then
        echo "Detected Arch Linux-based system. Installing and using Paru."
        $sudo_cmd pacman -Syu --noconfirm --needed $packages base-devel
        git clone https://aur.archlinux.org/paru-bin.git && cd paru-bin && makepkg -si && cd .. && rm -rf paru-bin

        if ! command_exists op && $IS_HOST; then
            $sudo_cmd paru -S --noconfirm --needed 1password 1password-cli zed
        fi

    elif command_exists brew; then
        echo "Detected macOS. Using Homebrew."
        brew install --adopt $packages zed 1password 1password-cli
    else
        echo "Error: No supported package manager found on this system."
        exit 1
    fi
}

# Install packages
install_packages

source_dir="$HOME/dotfiles"
target_dir="$HOME"

# Export variables to be available in the subshell spawned by find -exec
export source_dir
export target_dir

# Use find -exec with an inline sh script for POSIX compatibility.
# The inline script handles symlink creation and realpath fallback.
find "$source_dir" -exec sh -c '
    # Loop through each path found by find.
    # $source_dir and $target_dir are inherited from the environment.
    for path_item do
        # Get the path relative to the source directory.
        relative_path=${path_item#"$source_dir"/}

        # Construct the full destination path.
        destination_path="$target_dir/$relative_path"

        if [ -d "$path_item" ]; then
            # If it is a directory, create the corresponding directory in the target.
            mkdir -p "$destination_path"
        elif [ -f "$path_item" ]; then
            # If the file exists already at the destination, remove it.
            if [ -f "$destination_path" ]; then
                rm "$destination_path"
            fi
            # Ensure the parent directory exists before creating the symlink.
            mkdir -p "$(dirname "$destination_path")"

            # Resolve the absolute path for the symlink target.
            abs_target_path=""
            if command -v realpath >/dev/null 2>&1; then
                abs_target_path=$(realpath "$path_item")
            else
                # Basic POSIX fallback for realpath.
                _fallback_path="$path_item" # Current item from find
                _resolved_abs_path=""

                if [ -d "$_fallback_path" ]; then
                    # For directories, cd into it and get pwd.
                    if _cd_output=$(cd "$_fallback_path" 2>/dev/null && pwd); then
                        _resolved_abs_path="$_cd_output"
                    fi
                else
                    # For files, cd into their directory, then append basename.
                    _fallback_dir="$(dirname "$_fallback_path")"
                    _fallback_base="$(basename "$_fallback_path")"
                    
                    # Default dirname to "." if dirname returns empty (e.g. for a file in current dir like "foo")
                    if [ -z "$_fallback_dir" ] && [ "$_fallback_path" = "$_fallback_base" ]; then
                        _fallback_dir="."
                    # Handle root files like "/file", dirname is "/"
                    elif [ -z "$_fallback_dir" ] && [ "${_fallback_path%%/*}" = "" ]; then
                         _fallback_dir="/"
                    fi
                    
                    if _cd_output=$(cd "$_fallback_dir" 2>/dev/null && pwd); then
                        # If cd output is root, avoid double slash
                        if [ "$_cd_output" = "/" ]; then
                            _resolved_abs_path="/$_fallback_base"
                        else
                            _resolved_abs_path="$_cd_output/$_fallback_base"
                        fi
                    fi
                fi
                
                # Use resolved path if successful, otherwise fallback to original path with a warning.
                if [ -n "$_resolved_abs_path" ]; then
                    abs_target_path="$_resolved_abs_path"
                else
                    echo "Warning: realpath fallback failed for $_fallback_path. Using original path." >&2
                    abs_target_path="$_fallback_path"
                fi
            fi
            ln -s "$abs_target_path" "$destination_path"
        fi
    done
' sh {} +

if $IS_HOST; then
    op signin
    op inject -f -i .continue/config.yaml.sample -o .continue/config.yaml
fi
