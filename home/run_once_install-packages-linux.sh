#!/usr/bin/env bash
# run_once_install-packages-linux.sh
# Installs packages on Linux via the native package manager.
# Chezmoi re-runs this when the file content changes — bump the version below to force a re-run.
# version: 1

[[ "$(uname)" != "Linux" ]] && exit 0

set -e

if command -v apt-get &>/dev/null; then
    sudo apt-get update -q
    sudo apt-get install -y \
        bash zsh git curl wget jq \
        cmake pkg-config make build-essential \
        neovim ripgrep fd-find tmux \
        nodejs npm \
        python3 python3-pip python3-venv \
        xclip unzip

elif command -v dnf &>/dev/null; then
    sudo dnf install -y \
        bash zsh git curl wget jq \
        cmake pkg-config make \
        neovim ripgrep fd tmux \
        nodejs npm \
        python3 python3-pip \
        xclip unzip

elif command -v pacman &>/dev/null; then
    sudo pacman -Sy --noconfirm \
        bash zsh git curl wget jq \
        cmake pkg-config make base-devel \
        neovim ripgrep fd tmux \
        nodejs npm \
        python python-pip \
        xclip unzip

else
    echo "Unsupported Linux distribution" >&2
    exit 1
fi

# Starship (not in most distro repos)
if ! command -v starship &>/dev/null; then
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y
fi

# Rustup
if ! command -v rustup &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi
