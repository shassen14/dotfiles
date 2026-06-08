#!/usr/bin/env bash
# bootstrap.sh: Install chezmoi and apply dotfiles.
set -e

DOTFILES_REPO="https://github.com/shassen14/dotfiles.git"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# macOS: install Homebrew if missing
if [[ "$OSTYPE" == "darwin"* ]] && ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
fi

# Install chezmoi
if ! command -v chezmoi &>/dev/null; then
    if command -v brew &>/dev/null; then
        brew install chezmoi
    else
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
        export PATH="$HOME/.local/bin:$PATH"
    fi
fi

# Use local clone as chezmoi source if running from the repo (no separate clone needed).
# Otherwise fall back to cloning from the remote.
if [[ -d "$SCRIPT_DIR/home" ]]; then
    chezmoi init --source "$SCRIPT_DIR/home"
else
    chezmoi init "$DOTFILES_REPO"
fi

chezmoi apply -v

# Switch default shell to zsh on Linux (zsh is installed by the run_once script above)
if [[ "$(uname)" == "Linux" ]] && command -v zsh &>/dev/null; then
    ZSH_PATH="$(command -v zsh)"
    if [[ "$SHELL" != "$ZSH_PATH" ]]; then
        echo "Changing default shell to zsh..."
        sudo usermod -s "$ZSH_PATH" "$USER"
        echo "Shell changed — log out and back in (or run: exec zsh)"
    fi
fi
