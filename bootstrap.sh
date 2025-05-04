#!/usr/bin/env bash
# bootstrap.sh: Installs Ansible and runs the main playbook.

set -e # Exit immediately if a command exits with a non-zero status.

echo "🚀 Starting Dotfiles Bootstrap Process..."

# --- Detect OS and Set Specific Commands ---
echo "🔍 Detecting Operating System..."
OS_FAMILY=""
OS_DISTRO=""
UPDATE_CMD="" # Command to update package lists
INSTALL_CMD="" # Command to install packages
GIT_PKG="git" # Default git package name
ANSIBLE_PKG="ansible" # Default ansible package name

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v apt-get &> /dev/null; then
        OS_FAMILY="Debian"
        OS_DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]') || OS_DISTRO="debian"
        # Define commands specific to Debian/Ubuntu
        UPDATE_CMD="sudo apt-get update"
        INSTALL_CMD="sudo apt-get install -y"
    elif command -v dnf &> /dev/null; then
        OS_FAMILY="RedHat"
        OS_DISTRO="fedora" # Assuming Fedora for dnf
        UPDATE_CMD="sudo dnf check-update" # DNF uses check-update, install handles metadata sync
        INSTALL_CMD="sudo dnf install -y"
        ANSIBLE_PKG="ansible-core" # Prefer ansible-core on modern Fedora/RHEL
    elif command -v pacman &> /dev/null; then
        OS_FAMILY="Archlinux"
        OS_DISTRO="arch"
        UPDATE_CMD="sudo pacman -Sy" # Pacman needs Sy for syncing before install usually
        INSTALL_CMD="sudo pacman -S --noconfirm"
        ANSIBLE_PKG="ansible"
    else
        echo "❌ Unsupported Linux distribution."
        exit 1
    fi
    echo "✅ Linux Distribution Detected: $OS_DISTRO (Family: $OS_FAMILY)"

elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS_FAMILY="Darwin"
    OS_DISTRO="macos"
    # No system package manager update needed here, handled by brew later
    echo "✅ macOS Detected"
else
    echo "❌ Unsupported Operating System: $OSTYPE"
    exit 1
fi

# --- Install Prerequisite: Git ---
if ! command -v git &> /dev/null; then
    echo "📦 Installing Git..."
    if [[ "$OS_FAMILY" == "Darwin" ]]; then
        # On macOS, Homebrew (installed below) will handle Git.
        echo "ℹ️ Git not found. Will be installed via Homebrew or Command Line Tools."
    elif [[ -n "$INSTALL_CMD" ]]; then
        # Run update before first package install on Linux
        $UPDATE_CMD || { echo "⚠️ Failed to update package lists, continuing..."; } # Allow update failure
        $INSTALL_CMD $GIT_PKG || { echo "❌ Failed to install Git."; exit 1; }
        echo "✅ Git installed."
    fi
else
    echo "✅ Git already installed."
fi


# --- Install Ansible ---
if ! command -v ansible &>/dev/null; then
    echo "📦 Installing Ansible..."
    case "$OS_FAMILY" in
        Debian)
            # Run update before installing dependencies
            $UPDATE_CMD || { echo "⚠️ Failed to update package lists, continuing..."; }
            # Install dependency needed to add PPA
            $INSTALL_CMD software-properties-common || { echo "❌ Failed to install software-properties-common."; exit 1; }
            # Add PPA and update package list automatically (--update flag)
            sudo apt-add-repository --yes --update ppa:ansible/ansible || { echo "❌ Failed to add Ansible PPA."; exit 1; }
            # Now install Ansible (list is already updated by previous command)
            $INSTALL_CMD $ANSIBLE_PKG || { echo "❌ Failed to install Ansible."; exit 1; }
            ;;
        RedHat)
            # Install Ansible (dnf handles metadata sync during install)
            $INSTALL_CMD $ANSIBLE_PKG || $INSTALL_CMD ansible || { echo "❌ Failed to install Ansible/Ansible-Core."; exit 1; } # Try ansible if core fails
            ;;
        Archlinux)
            # Install Ansible (pacman -S handles sync if -Sy was run recently or included)
            $UPDATE_CMD # Ensure list is synced before install for pacman
            $INSTALL_CMD $ANSIBLE_PKG || { echo "❌ Failed to install Ansible."; exit 1; }
            ;;
        Darwin)
            if ! command -v brew &> /dev/null; then
                echo "🍺 Homebrew not found. Installing Homebrew..."
                NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || { echo "❌ Failed to install Homebrew."; exit 1; }
                echo "🍺 Adding Homebrew to PATH for this session (post-install)..."
                if [[ "$(uname -m)" == "arm64" ]]; then
                  eval "$(/opt/homebrew/bin/brew shellenv)"
                else
                  eval "$(/usr/local/bin/brew shellenv)"
                fi
            else
                 echo "✅ Homebrew already installed."
            fi
            echo "🍺 Updating Homebrew formulas..."
            brew update --quiet || echo "⚠️ Failed to update Homebrew formulas, continuing..."
            echo "🍺 Installing Ansible via Homebrew..."
            # No -v needed unless debugging brew itself
            brew install $ANSIBLE_PKG || { echo "❌ Failed to install Ansible via Homebrew."; exit 1; }
            ;;
    esac
    echo "✅ Ansible installed successfully."
else
    echo "✅ Ansible already installed."
fi

# --- CRITICAL: Ensure Brew Environment is Set BEFORE Running Ansible on macOS ---
if [[ "$OS_FAMILY" == "Darwin" ]]; then
    echo "🍺 Ensuring Homebrew environment is sourced for Ansible execution..."
    if [[ "$(uname -m)" == "arm64" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
      export PATH="/opt/homebrew/bin:$PATH"
    else
      eval "$(/usr/local/bin/brew shellenv)"
      export PATH="/usr/local/bin:$PATH"
    fi
    echo "🍺 Homebrew environment sourced."
fi

# --- Run Ansible Playbook ---
PLAYBOOK=${1:-playbook.yml}
INVENTORY=${2:-inventory.ini}

if [[ ! -f "$PLAYBOOK" ]]; then
    echo "❌ Playbook file not found: $PLAYBOOK"
    exit 1
fi
if [[ ! -f "$INVENTORY" ]]; then
    echo "❌ Inventory file not found: $INVENTORY"
    exit 1
fi

echo "🚀 Running Ansible Playbook: $PLAYBOOK with Inventory: $INVENTORY"
if [[ "$CI" == "true" ]]; then
    echo "ℹ️ Running in non-interactive CI mode (passwordless sudo assumed)."
    ansible-playbook -i "$INVENTORY" "$PLAYBOOK"
else
    echo "ℹ️ Running in interactive mode. You may be prompted for your sudo password."
    ansible-playbook -i "$INVENTORY" "$PLAYBOOK" -K
fi

echo "✅ Ansible Playbook finished."
echo "🎉 Bootstrap Complete!"