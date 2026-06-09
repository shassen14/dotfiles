#!/usr/bin/env bash
# Installs opencode. Separate from the main install script so editing
# unrelated packages doesn't retrigger this download.

[[ "$(uname)" != "Linux" ]] && exit 0
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"

if command -v opencode &>/dev/null; then
    echo "opencode already installed"
    exit 0
fi

curl -fsSL https://opencode.ai/install | bash
