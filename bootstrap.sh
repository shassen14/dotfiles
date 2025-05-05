#!/usr/bin/env bash
# bootstrap.sh: Installs dependencies (Ansible, Chezmoi), then runs Ansible.
# Assumes Ansible playbook will handle chezmoi init/apply.

set -e # Exit immediately if a command exits with a non-zero status.

echo "🚀 Starting Dotfiles Bootstrap Process..."

# --- Detect OS and Set Specific Commands ---
echo "🔍 Detecting Operating System..."
OS_FAMILY=""
OS_DISTRO=""
UPDATE_CMD="" # Command to update package lists
INSTALL_CMD="" # Command to install packages
GIT_PKG="git" # Default git package name
CURL_PKG="curl" # Default curl package name
ANSIBLE_PKG="ansible" # Default ansible package name

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v apt-get &> /dev/null; then
        OS_FAMILY="Debian"
        OS_DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]') || OS_DISTRO="debian"
        UPDATE_CMD="sudo apt-get update"
        INSTALL_CMD="sudo apt-get install -y"
    elif command -v dnf &> /dev/null; then
        OS_FAMILY="RedHat"
        OS_DISTRO="fedora"
        UPDATE_CMD="sudo dnf check-update"
        INSTALL_CMD="sudo dnf install -y"
        ANSIBLE_PKG="ansible-core"
    elif command -v pacman &> /dev/null; then
        OS_FAMILY="Archlinux"
        OS_DISTRO="arch"
        UPDATE_CMD="sudo pacman -Sy"
        INSTALL_CMD="sudo pacman -S --noconfirm"
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

# --- Install Prerequisites (Git, Curl) ---
if ! command -v git &> /dev/null; then
    echo "📦 Installing Git..."
    if [[ "$OS_FAMILY" == "Darwin" ]]; then
        echo "ℹ️ Git not found. Will be installed via Homebrew or Command Line Tools."
    elif [[ -n "$INSTALL_CMD" ]]; then
        $UPDATE_CMD || { echo "⚠️ Failed to update package lists, continuing..."; }
        $INSTALL_CMD $GIT_PKG || { echo "❌ Failed to install Git."; exit 1; }
        echo "✅ Git installed."
    fi
else
    echo "✅ Git already installed."
fi

if ! command -v curl &> /dev/null; then
     echo "📦 Installing Curl..."
     if [[ "$OS_FAMILY" == "Darwin" ]]; then
         echo "ℹ️ Curl not found, but usually present on macOS. Continuing..."
     elif [[ -n "$INSTALL_CMD" ]]; then
        $INSTALL_CMD $CURL_PKG || { echo "❌ Failed to install Curl."; exit 1; }
         echo "✅ Curl installed."
     fi
else
     echo "✅ Curl already installed."
fi

# --- Setup Homebrew (macOS ONLY) and Update PATH Early ---
if [[ "$OS_FAMILY" == "Darwin" ]]; then
    if ! command -v brew &> /dev/null; then
        echo "🍺 Homebrew not found. Installing Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || { echo "❌ Failed to install Homebrew."; exit 1; }
    else
         echo "✅ Homebrew already installed."
    fi
    echo "🍺 Sourcing Homebrew environment variables..."
    if [[ "$(uname -m)" == "arm64" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
      export PATH="/opt/homebrew/bin:$PATH"
    else
      eval "$(/usr/local/bin/brew shellenv)"
      export PATH="/usr/local/bin:$PATH"
    fi
    echo "🍺 Homebrew environment sourced. PATH=$PATH"

    echo "🍺 Updating Homebrew formulas..."
    brew update --quiet || echo "⚠️ Failed to update Homebrew formulas, continuing..."
fi

# --- Install Ansible ---
if ! command -v ansible &>/dev/null; then
    echo "📦 Installing Ansible..."
    case "$OS_FAMILY" in
        Debian)
            $UPDATE_CMD || { echo "⚠️ Failed to update package lists, continuing..."; }
            $INSTALL_CMD software-properties-common || { echo "❌ Failed to install software-properties-common."; exit 1; }
            sudo apt-add-repository --yes --update ppa:ansible/ansible || { echo "❌ Failed to add Ansible PPA."; exit 1; }
            $INSTALL_CMD $ANSIBLE_PKG || { echo "❌ Failed to install Ansible."; exit 1; }
            ;;
        RedHat)
            $INSTALL_CMD $ANSIBLE_PKG || $INSTALL_CMD ansible || { echo "❌ Failed to install Ansible/Ansible-Core."; exit 1; }
            ;;
        Archlinux)
            $UPDATE_CMD # Ensure list is synced before install for pacman
            $INSTALL_CMD $ANSIBLE_PKG || { echo "❌ Failed to install Ansible."; exit 1; }
            ;;
        Darwin)
            echo "🍺 Installing Ansible via Homebrew..."
            brew install $ANSIBLE_PKG || { echo "❌ Failed to install Ansible via Homebrew."; exit 1; }
            ;;
    esac
    echo "✅ Ansible installed successfully."
else
    echo "✅ Ansible already installed."
fi

# # --- Install Chezmoi ---
# if ! command -v chezmoi &> /dev/null; then
#     echo "📦 Installing Chezmoi..."
#     if [[ "$OS_FAMILY" == "Darwin" ]]; then
#         brew install chezmoi || { echo "❌ Failed to install Chezmoi via Homebrew."; exit 1; }
#     else
#         echo "Installing Chezmoi using install script..."
#         sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin || { echo "❌ Failed to install Chezmoi using script."; exit 1; }
#     fi
#     echo "✅ Chezmoi installed successfully."
# else
#     echo "✅ Chezmoi already installed."
# fi

# # --- Verify chezmoi command exists before running Ansible ---
# if ! command -v chezmoi &> /dev/null; then
#     echo "❌ CRITICAL FAILURE: chezmoi command not found in PATH before running Ansible!"
#     echo "Current PATH=$PATH"
#     exit 1
# fi
# echo "✅ chezmoi command found in PATH."

# --- Run Ansible Playbook ---
# Assumes playbook/inventory are relative to where bootstrap.sh is run
PLAYBOOK=${1:-playbook.yml}
INVENTORY=${2:-inventory.ini}

if [[ ! -f "$PLAYBOOK" ]]; then
    echo "❌ Playbook file not found: $PLAYBOOK (relative to $(pwd))"
    exit 1
fi
if [[ ! -f "$INVENTORY" ]]; then
    echo "❌ Inventory file not found: $INVENTORY (relative to $(pwd))"
    exit 1
fi

echo "🚀 Running Ansible Playbook: $PLAYBOOK with Inventory: $INVENTORY"
if [[ "$CI" == "true" ]]; then
    echo "ℹ️ Running in non-interactive CI mode (passwordless sudo assumed)."
    # Run ansible from the directory containing the playbook
    ansible-playbook -i "$INVENTORY" "$PLAYBOOK"
else
    echo "ℹ️ Running in interactive mode. You may be prompted for your sudo password."
    ansible-playbook -i "$INVENTORY" "$PLAYBOOK" -K
fi

echo "✅ Ansible Playbook finished."
echo "🎉 Bootstrap Complete!"