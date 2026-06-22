#!/usr/bin/env bash
# run_once_install-claude.sh
# Installs Claude Code (Anthropic's CLI) via the official native installer on
# macOS/Linux. Windows installs it from run_once_install-packages-windows.ps1.
# Chezmoi re-runs this when file content changes — bump the version to force a re-run.
# version: 1

set -e
export PATH="$HOME/.local/bin:$PATH"

if command -v claude &>/dev/null; then
    echo "Claude Code already installed."
    exit 0
fi

echo "Installing Claude Code..."
curl -fsSL https://claude.ai/install.sh | bash
