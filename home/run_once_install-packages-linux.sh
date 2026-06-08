#!/usr/bin/env bash
# run_once_install-packages-linux.sh
# Installs packages on Linux via the native package manager.
# Chezmoi re-runs this when the file content changes — bump the version below to force a re-run.
# version: 15

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
        libfuse2t64 \
        i3 i3lock rofi picom dunst feh \
        flameshot playerctl thunar polybar \
        blender pre-commit \
        pavucontrol xss-lock arandr \
        brightnessctl lxappearance papirus-icon-theme

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

    # Brave Browser
    if ! command -v brave-browser &>/dev/null; then
        curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg \
            | sudo gpg --dearmor -o /usr/share/keyrings/brave-browser-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" \
            | sudo tee /etc/apt/sources.list.d/brave-browser-release.list > /dev/null
        sudo apt-get update -q
        sudo apt-get install -y brave-browser
    fi

    # GitHub CLI
    if ! command -v gh &>/dev/null; then
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
            | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
            | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt-get update -q
        sudo apt-get install -y gh
    fi

    # Spotify
    if ! command -v spotify &>/dev/null; then
        curl -fsSL https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg \
            | sudo gpg --dearmor -o /usr/share/keyrings/spotify-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/spotify-archive-keyring.gpg] http://repository.spotify.com stable non-free" \
            | sudo tee /etc/apt/sources.list.d/spotify.list > /dev/null
        sudo apt-get update -q
        sudo apt-get install -y spotify-client
    fi

    # Docker CE
    if ! command -v docker &>/dev/null; then
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
            | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
            | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update -q
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        sudo usermod -aG docker "$USER"
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
        xclip unzip \
        i3 i3lock rofi picom dunst feh \
        flameshot playerctl thunar polybar \
        blender pre-commit gh \
        docker docker-compose \
        pavucontrol xss-lock arandr autorandr \
        brightnessctl lxappearance papirus-icon-theme

elif command -v pacman &>/dev/null; then
    sudo pacman -Sy --noconfirm \
        bash zsh git curl wget jq \
        cmake pkg-config make base-devel \
        neovim ripgrep fd tmux \
        fzf zoxide zsh-autosuggestions zsh-syntax-highlighting \
        nodejs npm \
        python python-pip \
        ghostty imagemagick \
        xclip unzip \
        i3-wm i3lock rofi picom dunst feh \
        flameshot playerctl thunar polybar \
        blender pre-commit github-cli \
        docker docker-compose \
        pavucontrol xss-lock arandr autorandr \
        brightnessctl lxappearance papirus-icon-theme

else
    echo "Unsupported Linux distribution" >&2
    exit 1
fi

# Remaining installs are optional — failures are logged but don't abort.
set +e

# ── autorandr from source (apt package has Python 3.12 SyntaxWarnings) ───────
if ! command -v autorandr &>/dev/null && command -v apt-get &>/dev/null; then
    install_autorandr() {
        local build_dir
        build_dir=$(mktemp -d)
        git clone --depth=1 https://github.com/phillipberndt/autorandr.git "$build_dir"
        sudo make -C "$build_dir" install
        rm -rf "$build_dir"
        sudo systemctl daemon-reload
        sudo systemctl enable --now autorandr.service autorandr-lid-listener.service
        sudo udevadm control --reload-rules
    }
    try "autorandr" install_autorandr
fi

# ── i3lock-color (Dracula themed lock screen) ────────────────────────────────
if ! command -v i3lock-color &>/dev/null && command -v apt-get &>/dev/null; then
    install_i3lock_color() {
        sudo apt-get install -y \
            autoconf gcc make pkg-config \
            libpam0g-dev libcairo2-dev libfontconfig1-dev \
            libxcb-composite0-dev libev-dev libx11-xcb-dev \
            libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev \
            libxcb-image0-dev libxcb-util0-dev libxcb-xrm-dev \
            libxcb-shape0-dev \
            libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev libgif-dev
        local build_dir
        build_dir=$(mktemp -d)
        git clone --depth=1 https://github.com/Raymo111/i3lock-color.git "$build_dir"
        cd "$build_dir"
        ./install-i3lock-color.sh
        cd - > /dev/null
        rm -rf "$build_dir"
    }
    try "i3lock-color" install_i3lock_color
fi

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
            | jq -r '[.assets[] | select(.name | test("Linux.*\\.AppImage$")) | .browser_download_url][0]')
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

# ── Nerd Fonts ───────────────────────────────────────────────────────────────
if ! fc-list | grep -qi "FiraCode Nerd Font"; then
    install_nerd_font() {
        local name="$1"
        local fonts_dir="$HOME/.local/share/fonts/NerdFonts"
        mkdir -p "$fonts_dir"
        curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${name}.tar.xz" \
            -o "/tmp/${name}.tar.xz"
        tar -xf "/tmp/${name}.tar.xz" -C "$fonts_dir"
        rm -f "/tmp/${name}.tar.xz"
    }
    try "FiraCode Nerd Font" install_nerd_font "FiraCode"
    try "Hack Nerd Font"     install_nerd_font "Hack"
    fc-cache -f "$HOME/.local/share/fonts"
fi

# ── Font Awesome 6 ───────────────────────────────────────────────────────────
if ! fc-list | grep -qi "Font Awesome 6"; then
    install_font_awesome() {
        local dir="$HOME/.local/share/fonts/FontAwesome6"
        mkdir -p "$dir"
        local url
        url=$(curl -fsSL https://api.github.com/repos/FortAwesome/Font-Awesome/releases/latest \
            | jq -r '.assets[] | select(.name | contains("desktop")) | .browser_download_url' \
            | head -1)
        [[ -z "$url" ]] && { echo "Could not resolve Font Awesome download URL" >&2; return 1; }
        curl -fsSL "$url" -o /tmp/fontawesome.zip
        unzip -j /tmp/fontawesome.zip "*/otfs/*.otf" -d "$dir"
        rm -f /tmp/fontawesome.zip
        fc-cache -f "$HOME/.local/share/fonts"
    }
    try "Font Awesome 6" install_font_awesome
fi

# ── Obsidian ─────────────────────────────────────────────────────────────────
if ! command -v obsidian &>/dev/null && command -v apt-get &>/dev/null; then
    install_obsidian() {
        local url
        url=$(curl -fsSL https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest \
            | jq -r '[.assets[] | select(.name | endswith(".deb")) | .browser_download_url][0]')
        [[ -z "$url" ]] && { echo "Could not resolve Obsidian download URL" >&2; return 1; }
        curl -fsSL "$url" -o /tmp/obsidian.deb
        sudo dpkg -i /tmp/obsidian.deb || sudo apt-get install -f -y
        rm -f /tmp/obsidian.deb
    }
    try "obsidian" install_obsidian
fi

# ── Discord ──────────────────────────────────────────────────────────────────
if ! command -v discord &>/dev/null && command -v apt-get &>/dev/null; then
    install_discord() {
        curl -fsSL "https://discord.com/api/download?platform=linux&format=deb" -o /tmp/discord.deb
        sudo dpkg -i /tmp/discord.deb || sudo apt-get install -f -y
        rm -f /tmp/discord.deb
    }
    try "discord" install_discord
fi

# ── Bitwarden ────────────────────────────────────────────────────────────────
if ! command -v bitwarden &>/dev/null && command -v apt-get &>/dev/null; then
    install_bitwarden() {
        local url
        url=$(curl -fsSL https://api.github.com/repos/bitwarden/clients/releases/latest \
            | jq -r '[.assets[] | select(.name | test("amd64\\.deb$")) | .browser_download_url][0]')
        [[ -z "$url" ]] && { echo "Could not resolve Bitwarden download URL" >&2; return 1; }
        curl -fsSL "$url" -o /tmp/bitwarden.deb
        sudo dpkg -i /tmp/bitwarden.deb || sudo apt-get install -f -y
        rm -f /tmp/bitwarden.deb
    }
    try "bitwarden" install_bitwarden
fi
