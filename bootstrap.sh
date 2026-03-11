#!/usr/bin/env bash
# bootstrap.sh: Install chezmoi and apply dotfiles.
set -e

DOTFILES_REPO="https://github.com/shassen14/dotfiles.git"

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

# Clone dotfiles repo, then apply from the home/ subdirectory
chezmoi init "$DOTFILES_REPO"
exec chezmoi apply --source "$(chezmoi source-path)/home"
