#!/usr/bin/env bash
# run_once_install-packages-linux.sh
# Installs packages on Linux via the native package manager.
# Chezmoi re-runs this when the file content changes — bump the version below to force a re-run.
# version: 12

[[ "$(uname)" != "Linux" ]] && exit 0

# Helper: run an optional install step — logs failure but never aborts the script.
try() {
    local desc="$1"; shift
    if "$@"; then
        echo "OK: $desc"
    else
        echo "WARN: $desc failed (exit $?) — install manually if needed" >&2
    fi
}

set -e  # Strict mode for the core apt block below.

# ── Core apt packages ────────────────────────────────────────────────────────
if command -v apt-get &>/dev/null; then
    # Neovim PPA (latest stable/unstable builds)
    if [ ! -f /usr/share/keyrings/neovim-ppa.gpg ]; then
        curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x9DBB0BE9366964F134855E2255F96FCF8231B6DD" | sudo gpg --dearmor -o /usr/share/keyrings/neovim-ppa.gpg
        echo "deb [signed-by=/usr/share/keyrings/neovim-ppa.gpg] https://ppa.launchpadcontent.net/neovim-ppa/unstable/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/neovim-ppa.list > /dev/null
    fi

    # OBS Studio PPA
    if [ ! -f /usr/share/keyrings/obsproject.gpg ]; then
        curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xBC7345F522079769F5BBE987EFC71127F425E228" | sudo gpg --dearmor -o /usr/share/keyrings/obsproject.gpg
        echo "deb [signed-by=/usr/share/keyrings/obsproject.gpg] https://ppa.launchpadcontent.net/obsproject/obs-studio/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/obs-studio.list > /dev/null
    fi

    sudo apt-get update -q
    sudo apt-get install -y \
        bash zsh git curl wget jq gnupg \
        cmake pkg-config make build-essential \
        neovim ripgrep fd-find tmux \
        fzf zsh-autosuggestions zsh-syntax-highlighting \
        python3 python3-pip python3-venv \
        obs-studio imagemagick \
        xclip unzip \
        software-properties-common \
        libfuse2t64

    # Ubuntu names the fd binary 'fdfind' — symlink it to 'fd'
    if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    fi

    # Node.js via NodeSource (Ubuntu's apt nodejs+npm packages conflict)
    if ! command -v node &>/dev/null; then
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi

    # VS Code
    if ! command -v code &>/dev/null; then
        curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
            | gpg --dearmor -o /tmp/microsoft.gpg
        sudo install -D -o root -g root -m 644 /tmp/microsoft.gpg \
            /usr/share/keyrings/microsoft-archive-keyring.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] \
https://packages.microsoft.com/repos/vscode stable main" \
            | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
        sudo apt-get update -q
        sudo apt-get install -y code
    fi

    # Ghostty via community PPA — updates via apt upgrade
    if ! command -v ghostty &>/dev/null; then
        sudo add-apt-repository -y ppa:mkasberg/ghostty-ubuntu
        sudo apt-get update -q
        sudo apt-get install -y ghostty
    fi

elif command -v dnf &>/dev/null; then
    sudo dnf install -y \
        bash zsh git curl wget jq \
        cmake pkg-config make \
        neovim ripgrep fd tmux \
        fzf zoxide zsh-autosuggestions zsh-syntax-highlighting \
        nodejs npm \
        python3 python3-pip \
        ghostty imagemagick \
        xclip unzip

elif command -v pacman &>/dev/null; then
    sudo pacman -Sy --noconfirm \
        bash zsh git curl wget jq \
        cmake pkg-config make base-devel \
        neovim ripgrep fd tmux \
        fzf zoxide zsh-autosuggestions zsh-syntax-highlighting \
        nodejs npm \
        python python-pip \
        ghostty imagemagick \
        xclip unzip

else
    echo "Unsupported Linux distribution" >&2
    exit 1
fi

# Remaining installs are optional — failures are logged but don't abort.
set +e

# ── Starship prompt ──────────────────────────────────────────────────────────
if ! command -v starship &>/dev/null; then
    try "starship" curl -fsSL https://starship.rs/install.sh | sh -s -- -y
fi

# ── zoxide (smarter cd) ──────────────────────────────────────────────────────
if ! command -v zoxide &>/dev/null && command -v apt-get &>/dev/null; then
    mkdir -p "$HOME/.local/bin"
    try "zoxide" bash -c 'curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh'
fi

# ── Rustup ───────────────────────────────────────────────────────────────────
if ! command -v rustup &>/dev/null; then
    try "rustup" bash -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path'
fi

# ── OrcaSlicer AppImage (no apt/PPA available) ───────────────────────────────
if ! command -v orcaslicer &>/dev/null; then
    install_orcaslicer() {
        local dir="$HOME/.local/share/OrcaSlicer"
        mkdir -p "$dir" "$HOME/.local/bin"
        local url
        url=$(curl -fsSL --retry 3 https://api.github.com/repos/SoftFever/OrcaSlicer/releases/latest \
            | grep -o '"browser_download_url": "[^"]*Linux[^"]*\.AppImage"' \
            | head -1 | cut -d'"' -f4)
        [[ -z "$url" ]] && { echo "Could not resolve OrcaSlicer download URL" >&2; return 1; }
        curl -fsSL --retry 3 "$url" -o "$dir/OrcaSlicer.AppImage"
        chmod +x "$dir/OrcaSlicer.AppImage"
        ln -sf "$dir/OrcaSlicer.AppImage" "$HOME/.local/bin/orcaslicer"
    }
    try "OrcaSlicer" install_orcaslicer
fi

# ── Ollama ───────────────────────────────────────────────────────────────────
if ! command -v ollama &>/dev/null; then
    try "ollama" bash -c 'curl -fsSL https://ollama.com/install.sh | bash'
fi

# ── OpenCode ─────────────────────────────────────────────────────────────────
if ! command -v opencode &>/dev/null; then
    try "opencode" bash -c 'curl -fsSL https://opencode.ai/install | bash'
fi
