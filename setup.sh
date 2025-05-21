#!/bin/sh

IS_HOST=false
# if host is passed in as an argument, skip some tools
if [ "$1" = "--host" ]; then
    IS_HOST=true
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install packages
install_packages() {
    packages="git starship zsh micro"

    if command_exists apk; then
        echo "Detected Alpine based system. Using APK."
        sudo apk update && sudo apk add -y $packages

    elif command_exists dnf; then
        echo "Detected Fedora-based system. Using DNF."
        sudo dnf install -y $limited

        if ! command_exists op && IS_HOST; then
            curl -f https://zed.dev/install.sh | sh
            sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
            sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
            sudo dnf check-update -y 1password 1password-cli && sudo dnf install 1password 1password-cli
        fi

    elif command_exists pacman; then
        echo "Detected Arch Linux-based system. Installing and using Paru."
        sudo pacman -Syu --noconfirm --needed $packages base-devel
        git clone https://aur.archlinux.org/paru-bin.git && cd paru-bin && makepkg -si && cd .. && rm -rf paru-bin

        if ! command_exists op && IS_HOST; then
            sudo paru -S --noconfirm --needed 1password 1password-cli zed
        fi

    elif command_exists brew; then
        echo "Detected macOS. Using Homebrew."
        brew install --adopt $packages zed 1password 1password-cli
    else
        echo "Error: No supported package manager found on this system."
        exit 1
    fi
}

# Check for root privileges if necessary
if [ "$(id -u)" -ne 0 ] && ! command_exists brew; then
    echo "This script requires root privileges to install packages."
    echo "Please run it as root or with sudo."
    exit 1
fi

# Install packages
install_packages

# Remove Readme and Licence
rm README.md
rm LICENCE

source_dir="$HOME/dotfiles"
target_dir="$HOME"

find "$source_dir" -print0 | while IFS= read -r '' path; do
    # Get the path relative to the source directory
    relative_path=${path#$source_dir/}

    # Construct the full destination path
    destination_path="$target_dir/$relative_path"

    if [ -d "$path" ]; then
        # If it's a directory, create the corresponding directory in the target
        mkdir -p "$destination_path"
    elif [ -f "$path" ]; then
        # If the file exists already, remove it
        if [ -f "$destination_path" ]; then
            rm "$destination_path"
        fi
        # Create a symlink to the original file
        # Ensure the parent directory exists before creating the symlink
        mkdir -p "$(dirname "$destination_path")"
        ln -s "$(realpath "$path")" "$destination_path"
    fi
done

if $IS_HOST; then
    op signin
    op inject -f -i .continue/config.yaml.sample -o .continue/config.yaml
fi
