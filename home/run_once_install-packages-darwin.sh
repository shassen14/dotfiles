#!/usr/bin/env bash
# run_once_install-packages-darwin.sh
# Installs all macOS packages via Homebrew Bundle.
# Chezmoi re-runs this when the file content changes — bump the version below to force a re-run.
# version: 2

[[ "$(uname)" != "Darwin" ]] && exit 0

set -e

brew bundle --file ~/.config/homebrew/Brewfile
