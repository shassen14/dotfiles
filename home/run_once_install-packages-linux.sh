#!/usr/bin/env bash
# run_once_install-packages-linux.sh
# Installs packages on Linux via the native package manager.
# Chezmoi re-runs this when the file content changes — bump the version below to force a re-run.
# version: 6

[[ "$(uname)" != "Linux" ]] && exit 0

set -e

if command -v apt-get &>/dev/null; then
    sudo apt-get update -q
    sudo apt-get install -y \
        bash zsh git curl wget jq \
        cmake pkg-config make build-essential \
        neovim ripgrep fd-find tmux \
        fzf zsh-autosuggestions zsh-syntax-highlighting \
        nodejs npm \
        python3 python3-pip python3-venv \
        imagemagick \
        xclip unzip

    # Ghostty not in apt repos — install via Flatpak
    if command -v flatpak &>/dev/null; then
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        flatpak install --noninteractive flathub com.mitchellh.ghostty
    else
        echo "Ghostty: install flatpak then re-run, or install Ghostty manually." >&2
    fi

elif command -v dnf &>/dev/null; then
    sudo dnf install -y \
        bash zsh git curl wget jq \
        cmake pkg-config make \
        neovim ripgrep fd tmux \
        fzf zoxide zsh-autosuggestions zsh-syntax-highlighting \
        nodejs npm \
        python3 python3-pip \
        ghostty imagemagick \
        xclip unzip

elif command -v pacman &>/dev/null; then
    sudo pacman -Sy --noconfirm \
        bash zsh git curl wget jq \
        cmake pkg-config make base-devel \
        neovim ripgrep fd tmux \
        fzf zoxide zsh-autosuggestions zsh-syntax-highlighting \
        nodejs npm \
        python python-pip \
        ghostty imagemagick \
        xclip unzip

else
    echo "Unsupported Linux distribution" >&2
    exit 1
fi

# Starship (not in most distro repos)
if ! command -v starship &>/dev/null; then
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y
fi

# zoxide (not in apt repos — install via official script)
if ! command -v zoxide &>/dev/null && command -v apt-get &>/dev/null; then
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# Rustup
if ! command -v rustup &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi

# OrcaSlicer (via Flatpak — not in distro repos)
if command -v flatpak &>/dev/null; then
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install --noninteractive flathub com.bambulab.OrcaSlicer
else
    echo "OrcaSlicer: install flatpak then re-run, or install OrcaSlicer manually." >&2
fi

# Ollama (local LLM runner)
if ! command -v ollama &>/dev/null; then
    curl -fsSL https://ollama.com/install.sh | sh
fi

# OpenCode (terminal AI coding agent)
if ! command -v opencode &>/dev/null; then
    curl -fsSL https://opencode.ai/install | sh
fi
