#!/bin/sh

# if host is passed in as an argument, skip some tools
if [ "$1" = "--host" ]; then
    IS_HOST=true
else
    IS_HOST=false
fi


# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install packages
install_packages() {
    packages="git openssh starship zsh micro"
    limited="git openssh starship zsh micro"

    if command_exists apt; then
        echo "Detected Debian/Ubuntu-based system. Using APT."
        sudo apt update && sudo apt install -y $limited
        curl -f https://zed.dev/install.sh | sh;
        curl -sS https://starship.rs/install.sh | sh
    elif command_exists dnf; then
        echo "Detected Fedora-based system. Using DNF."
        sudo dnf install -y $limited
        curl -f https://zed.dev/install.sh | sh

        if ! command_exists op && IS_HOST; then
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
        brew install $packages zed
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

# Remove git artifacts
rm -rf ~/.git
rm .gitignore
rm README.md
rm LICENCE

if IS_HOST; then
    op signin;
    op inject -f -i .env.sample -o .env;
fi
