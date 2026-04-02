#!/usr/bin/env bash
# run_once_install-tpm.sh
# Installs TPM (Tmux Plugin Manager) if not already present.
# version: 1

set -e

TPM_DIR="$HOME/.tmux/plugins/tpm"

if [ ! -d "$TPM_DIR" ]; then
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi
