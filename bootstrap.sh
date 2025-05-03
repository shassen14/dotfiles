#!/usr/bin/env bash

set -e

echo "🔍 Detecting OS..."
OS=""
INSTALL_CMD=""

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v apt &>/dev/null; then
        OS="debian"
    elif command -v dnf &>/dev/null; then
        OS="fedora"
    elif command -v pacman &>/dev/null; then
        OS="arch"
    else
        echo "❌ Unsupported Linux distribution"
        exit 1
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
else
    echo "❌ Unsupported OS: $OSTYPE"
    exit 1
fi

echo "✅ OS Detected: $OS"

# Install Ansible if not present
if ! command -v ansible &>/dev/null; then
    echo "📦 Installing Ansible..."
    case "$OS" in
        debian)
            sudo apt update
            sudo apt install -y software-properties-common
            sudo apt-add-repository --yes --update ppa:ansible/ansible
            sudo apt install -y ansible
            ;;
        fedora)
            sudo dnf install -y ansible
            ;;
        arch)
            sudo pacman -Sy --noconfirm ansible
            ;;
        macos)
            if ! command -v brew &>/dev/null; then
                echo "🍺 Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew install ansible
            ;;
    esac
else
    echo "✅ Ansible already installed"
fi

# Default playbook and inventory paths (you can override them)
PLAYBOOK=${1:-playbook.yml}
INVENTORY=${2:-inventory.ini}

# Run the playbook
echo "🚀 Running Ansible Playbook..."
if [[ "$CI" == "true" ]]; then
    ansible-playbook -i "$INVENTORY" "$PLAYBOOK"
else
    ansible-playbook -i "$INVENTORY" "$PLAYBOOK" -K
fi
