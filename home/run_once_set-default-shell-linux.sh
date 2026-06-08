#!/usr/bin/env bash
# Sets zsh as the default login shell on Linux.
# Chezmoi runs this once (content-hashed). Edit and re-apply to force a re-run.

[[ "$(uname)" != "Linux" ]] && exit 0

ZSH_PATH="$(command -v zsh)"
if [[ -z "$ZSH_PATH" ]]; then
    echo "zsh not found — skipping shell change" >&2
    exit 0
fi

if [[ "$SHELL" == "$ZSH_PATH" ]]; then
    echo "Default shell is already zsh ($ZSH_PATH)"
    exit 0
fi

# usermod doesn't prompt for a password (unlike chsh)
sudo usermod -s "$ZSH_PATH" "$USER"
echo "Default shell changed to $ZSH_PATH — takes effect on next login"
