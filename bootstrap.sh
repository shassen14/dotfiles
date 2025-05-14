#!/usr/bin/env bash
# bootstrap.sh: Installs dependencies (Ansible, Chezmoi), then runs Ansible.

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
    ANSIBLE_PKG="ansible"
    echo "✅ macOS Detected, ANSIBLE_PKG set to '$ANSIBLE_PKG'"
else
    echo "❌ Unsupported Operating System: $OSTYPE"
    exit 1
fi

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
        echo "ℹ️ The Homebrew installer might prompt for your macOS password."
        # DO NOT set NONINTERACTIVE=1 for local runs if password prompt is needed.
        # The Homebrew script itself will use `sudo` where necessary and prompt you.
        if [[ "$CI" == "true" ]]; then
            # In CI, we expect passwordless sudo or for NONINTERACTIVE to work.
            NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || { echo "❌ Failed to install Homebrew in CI environment."; exit 1; }
        else
            # For local interactive install, allow the script to prompt for sudo password.
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || { echo "❌ Failed to install Homebrew. Ensure Xcode Command Line Tools are installed ('xcode-select --install') and try again. If prompted, enter your macOS password."; exit 1; }
        fi
        echo "✅ Homebrew installed."
    else
         echo "✅ Homebrew already installed."
    fi

    echo "🍺 Evaluating Homebrew environment variables..."
    # Correctly evaluate and export Homebrew path
    if [[ "$(uname -m)" == "arm64" ]]; then # Apple Silicon
      eval "$(/opt/homebrew/bin/brew shellenv)"
      # Redundant if shellenv already does it, but ensures it if shellenv didn't modify current shell's PATH
      export PATH="/opt/homebrew/bin:$PATH"
    else # Intel
      eval "$(/usr/local/bin/brew shellenv)"
      export PATH="/usr/local/bin:$PATH"
    fi
    echo "🍺 Homebrew environment sourced. Current PATH includes Homebrew."

    echo "🍺 Updating Homebrew formulas..."
    brew update --quiet || echo "⚠️ Failed to update Homebrew formulas, continuing..."
fi

# --- Install Ansible ---
# ... (your Ansible install logic - ensure 'brew install ansible' on macOS does NOT use sudo)
if ! command -v ansible &>/dev/null; then
    echo "📦 Installing Ansible..."
    case "$OS_FAMILY" in
        Debian)
            # This part uses sudo, which is fine as it's for apt
            $UPDATE_CMD || { echo "⚠️ Failed to update package lists, continuing..."; }
            $INSTALL_CMD software-properties-common || { echo "❌ Failed to install software-properties-common."; exit 1; }
            sudo apt-add-repository --yes --update ppa:ansible/ansible || { echo "❌ Failed to add Ansible PPA."; exit 1; }
            $INSTALL_CMD $ANSIBLE_PKG || { echo "❌ Failed to install Ansible."; exit 1; }
            ;;
        RedHat)
            $INSTALL_CMD $ANSIBLE_PKG || $INSTALL_CMD ansible || { echo "❌ Failed to install Ansible/Ansible-Core."; exit 1; }
            ;;
        Archlinux)
            $UPDATE_CMD
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


# --- Run Ansible Playbook ---
PLAYBOOK="${1:-playbook.yml}" # Use $DOTFILES_REPO_ROOT if defined and path is relative
INVENTORY="${2:-inventory.ini}" # Use $DOTFILES_REPO_ROOT if defined and path is relative

# If DOTFILES_REPO_ROOT is set (e.g., in CI), assume playbook/inventory are relative to it.
# Otherwise, assume they are relative to the current directory (where bootstrap.sh is).
PLAYBOOK_PATH="$PLAYBOOK"
INVENTORY_PATH="$INVENTORY"
if [[ -n "$DOTFILES_REPO_ROOT" ]]; then
    PLAYBOOK_PATH="$DOTFILES_REPO_ROOT/$PLAYBOOK"
    INVENTORY_PATH="$DOTFILES_REPO_ROOT/$INVENTORY"
fi


if [[ ! -f "$PLAYBOOK_PATH" ]]; then
    echo "❌ Playbook file not found: $PLAYBOOK_PATH"
    exit 1
fi
if [[ ! -f "$INVENTORY_PATH" ]]; then
    echo "❌ Inventory file not found: $INVENTORY_PATH"
    exit 1
fi

echo "🚀 Running Ansible Playbook: $PLAYBOOK_PATH with Inventory: $INVENTORY_PATH"
# For Ansible, it will use 'become: true' in playbooks for tasks needing sudo.
# The '-K' flag for local runs will make Ansible prompt for the sudo password.
if [[ "$CI" == "true" ]]; then
    echo "ℹ️ Running in non-interactive CI mode (passwordless sudo assumed for 'become' tasks)."
    ansible-playbook -i "$INVENTORY_PATH" "$PLAYBOOK_PATH"
else
    echo "ℹ️ Running in interactive mode. Ansible may prompt for your sudo password for 'become' tasks."
    ansible-playbook -i "$INVENTORY_PATH" "$PLAYBOOK_PATH" -K
fi

echo "✅ Ansible Playbook finished."
echo "🎉 Bootstrap Complete!"
