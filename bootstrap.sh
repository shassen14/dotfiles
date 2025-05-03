#!/usr/bin/env bash
# bootstrap.sh: Installs Ansible and runs the main playbook.

set -e # Exit immediately if a command exits with a non-zero status.
# set -u # Treat unset variables as an error (optional, good practice)
# set -o pipefail # Cause pipelines to fail on the first command that fails (optional, good practice)

echo "🚀 Starting Dotfiles Bootstrap Process..."

# --- Detect OS ---
echo "🔍 Detecting Operating System..."
OS_FAMILY="" # e.g., Debian, RedHat, Archlinux, Darwin
OS_DISTRO="" # e.g., ubuntu, fedora, arch, macos
INSTALL_CMD="" # Package manager command

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v apt-get &> /dev/null; then
        OS_FAMILY="Debian"
        OS_DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]') || OS_DISTRO="debian" # Get specific distro if lsb_release exists
        INSTALL_CMD="sudo apt-get update && sudo apt-get install -y"
    elif command -v dnf &> /dev/null; then
        OS_FAMILY="RedHat"
        OS_DISTRO="fedora" # Assuming Fedora for dnf
        INSTALL_CMD="sudo dnf install -y"
    elif command -v pacman &> /dev/null; then
        OS_FAMILY="Archlinux"
        OS_DISTRO="arch"
        INSTALL_CMD="sudo pacman -Sy --noconfirm" # Sync package lists before install
    else
        echo "❌ Unsupported Linux distribution."
        exit 1
    fi
    echo "✅ Linux Distribution Detected: $OS_DISTRO (Family: $OS_FAMILY)"

elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS_FAMILY="Darwin"
    OS_DISTRO="macos"
    echo "✅ macOS Detected"
else
    echo "❌ Unsupported Operating System: $OSTYPE"
    exit 1
fi

# --- Install Prerequisite: Git (needed for some Ansible installs/Chezmoi) ---
if ! command -v git &> /dev/null; then
    echo "📦 Installing Git..."
    if [[ -n "$INSTALL_CMD" ]]; then
        $INSTALL_CMD git || { echo "❌ Failed to install Git."; exit 1; }
    elif [[ "$OS_FAMILY" == "Darwin" ]]; then
        # On macOS, Xcode Command Line Tools often provide Git. Prompt if needed.
        # Alternatively, Homebrew (installed below) will handle it.
        echo "ℹ️ Git not found. Will be installed via Homebrew or Command Line Tools."
    fi
else
    echo "✅ Git already installed."
fi


# --- Install Ansible ---
if ! command -v ansible &>/dev/null; then
    echo "📦 Installing Ansible..."
    case "$OS_FAMILY" in
        Debian)
            sudo apt-get update
            sudo apt-get install -y software-properties-common
            sudo apt-add-repository --yes --update ppa:ansible/ansible
            $INSTALL_CMD ansible || { echo "❌ Failed to install Ansible."; exit 1; }
            ;;
        RedHat)
            $INSTALL_CMD ansible-core || $INSTALL_CMD ansible || { echo "❌ Failed to install Ansible."; exit 1; } # Try ansible-core first
            ;;
        Archlinux)
            $INSTALL_CMD ansible || { echo "❌ Failed to install Ansible."; exit 1; }
            ;;
        Darwin)
            if ! command -v brew &> /dev/null; then
                echo "🍺 Homebrew not found. Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || { echo "❌ Failed to install Homebrew."; exit 1; }
                # Add brew to PATH for the current script session
                # Check for Apple Silicon vs Intel paths
                if [[ "$(uname -m)" == "arm64" ]]; then
                  eval "$(/opt/homebrew/bin/brew shellenv)"
                else
                  eval "$(/usr/local/bin/brew shellenv)"
                fi
            fi
            echo "🍺 Installing Ansible via Homebrew..."
            brew install ansible || { echo "❌ Failed to install Ansible via Homebrew."; exit 1; }
            ;;
    esac
    echo "✅ Ansible installed successfully."
else
    echo "✅ Ansible already installed."
fi

# --- Run Ansible Playbook ---
# Default playbook and inventory paths (can be overridden via arguments)
PLAYBOOK=${1:-playbook.yml}
INVENTORY=${2:-inventory.ini}

# Check if files exist
if [[ ! -f "$PLAYBOOK" ]]; then
    echo "❌ Playbook file not found: $PLAYBOOK"
    exit 1
fi
if [[ ! -f "$INVENTORY" ]]; then
    echo "❌ Inventory file not found: $INVENTORY"
    exit 1
fi

echo "🚀 Running Ansible Playbook: $PLAYBOOK with Inventory: $INVENTORY"
# Use -K to prompt for the become password (sudo).
# For non-interactive use, configure passwordless sudo or use Ansible Vault.
# Add -v for more verbose output if needed during debugging.
if [[ "$CI" == "true" ]]; then
    # CI usually needs non-interactive
    echo "ℹ️ Running in non-interactive CI mode (passwordless sudo assumed)."
    ansible-playbook -i "$INVENTORY" "$PLAYBOOK"
else
    echo "ℹ️ Running in interactive mode. You may be prompted for your sudo password."
    ansible-playbook -i "$INVENTORY" "$PLAYBOOK" -K
fi

echo "✅ Ansible Playbook finished."
echo "🎉 Bootstrap Complete!"