#! /bin/sh
set -eo pipefail

# If we're on arch, and don't already have it, install paru

if [ -f /etc/arch-release ] && ! command -v paru &> /dev/null; then
    sudo pacman -S rustup
    rustup install stable
    sudo pacman -S --needed base-devel
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si
    cd ..
    rm -rf paru
fi

# Figure out which package manager we're using
# and install packages from dot_packages
if [ -f /etc/debian_version ]; then
    sudo apt-get install $(cat .packages)
elif [ -f /etc/redhat-release ]; then
    sudo yum install $(cat .packages)
elif [ -f /etc/arch-release ]; then
    paru -S $(cat .packages) --needed
elif [ -f /etc/gentoo-release ]; then
    sudo emerge $(cat .packages)
else
    echo "Unknown distribution"
    exit 1
fi
