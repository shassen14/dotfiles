#!/usr/bin/env bash
# bootstrap.sh: Installs dependencies, Chezmoi, runs initial init, then runs Ansible.

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
        OS_DISTRO="fedora" # Assuming Fedora for dnf
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
        # Curl is typically built-in on macOS
         echo "ℹ️ Curl not found, but usually present on macOS. Continuing..."
     elif [[ -n "$INSTALL_CMD" ]]; then
        # Assume update was run for Git if needed
        $INSTALL_CMD $CURL_PKG || { echo "❌ Failed to install Curl."; exit 1; }
         echo "✅ Curl installed."
     fi
else
     echo "✅ Curl already installed."
fi

# --- CRITICAL: Run Initial Chezmoi Init BEFORE Ansible ---
CHEZMOI_REPO_URL="https://github.com/shassen14/dotfiles.git"
CHEZMOI_BRANCH="main"

if [[ ! -d "$HOME/.local/share/chezmoi/.git" ]]; then
  echo "🚀 Running initial 'chezmoi init' directly under strace..."
  # Ensure strace is installed
  if ! command -v strace &> /dev/null; then
    echo "Installing strace for debugging..."
    $UPDATE_CMD || echo "Warning: Update failed"
    # Install strace - package name might vary slightly (e.g., on Fedora)
    $INSTALL_CMD strace || { echo "❌ Failed to install strace."; exit 1; }
  fi

  # Run init under strace, logging to a file in the user's home directory
  strace -o "$HOME/chezmoi_init_bootstrap_trace.log" -f \
      chezmoi init --verbose --branch "$CHEZMOI_BRANCH" "$CHEZMOI_REPO_URL"

  # Check the exit code explicitly
  INIT_EXIT_CODE=$?
  echo "✅ 'chezmoi init' command finished with exit code: $INIT_EXIT_CODE"

  # Check if directory was created AFTER the command finished
  if [[ ! -d "$HOME/.local/share/chezmoi/.git" ]]; then
    echo "❌ CRITICAL FAILURE: 'chezmoi init' finished (exit code $INIT_EXIT_CODE) but cache dir '$HOME/.local/share/chezmoi/.git' was not created!"
    echo "ℹ️ Check the trace log: $HOME/chezmoi_init_bootstrap_trace.log"
    # Optional: print last few lines of trace log
    # tail -n 50 "$HOME/chezmoi_init_bootstrap_trace.log"
    exit 1 # Explicitly exit if verification fails
  fi
  echo "✅ Initial 'chezmoi init' completed and cache directory verified."
else
  echo "✅ Chezmoi internal repository already initialized."
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
            brew install $ANSIBLE_PKG || { echo "❌ Failed to install Ansible via Homebrew."; exit 1; }
            ;;
    esac
    echo "✅ Ansible installed successfully."
else
    echo "✅ Ansible already installed."
fi

# --- Ensure Brew Environment is Set BEFORE Running Ansible on macOS ---
# Needs to run AFTER all potential brew installs and BEFORE ansible-playbook
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
# Use -v with ansible-playbook for more verbose Ansible output if needed
if [[ "$CI" == "true" ]]; then
    echo "ℹ️ Running in non-interactive CI mode (passwordless sudo assumed)."
    ansible-playbook -i "$INVENTORY" "$PLAYBOOK"
else
    echo "ℹ️ Running in interactive mode. You may be prompted for your sudo password."
    ansible-playbook -i "$INVENTORY" "$PLAYBOOK" -K
fi

echo "✅ Ansible Playbook finished."
echo "🎉 Bootstrap Complete!"