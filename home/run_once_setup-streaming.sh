#!/usr/bin/env bash
# Sets up Stream Deck udev access and installs streaming tools.
# version: 5

[[ "$(uname)" != "Linux" ]] && exit 0

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/bin:$PATH"

try() {
    local desc="$1"; shift
    if "$@"; then echo "OK: $desc"
    else echo "WARN: $desc failed — install manually if needed" >&2
    fi
}

# ── Stream Deck udev rule ─────────────────────────────────────────────────────
UDEV_RULE='/etc/udev/rules.d/50-streamdeck.rules'
if [ ! -f "$UDEV_RULE" ]; then
    echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", TAG+="uaccess"' \
        | sudo tee "$UDEV_RULE" > /dev/null
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    echo "OK: Stream Deck udev rule installed"
fi

# ── Flatpak + Flathub (needed for StreamController) ──────────────────────────
sudo apt-get install -y flatpak
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# ── StreamController (Stream Deck + GUI with OBS/Spotify/etc. plugins) ───────
if ! flatpak list --app 2>/dev/null | grep -q com.core447.StreamController; then
    try "StreamController" flatpak install --user -y flathub com.core447.StreamController
fi

# ── obsws-python (OBS WebSocket client for scene switching) ──────────────────
if ! python3 -c 'import obsws_python' &>/dev/null; then
    try "obsws-python" pip3 install --break-system-packages obsws-python
fi

# ── twitch-cli (official Twitch CLI) ─────────────────────────────────────────
if ! command -v twitch &>/dev/null && [ ! -f "$HOME/.local/bin/twitch" ]; then
    install_twitch_cli() {
        local url
        url=$(curl -fsSL https://api.github.com/repos/twitchdev/twitch-cli/releases/latest \
            | jq -r '[.assets[] | select(.name | test("Linux_x86_64\\.tar\\.gz$")) | .browser_download_url][0]')
        [[ -z "$url" ]] && { echo "Could not resolve twitch-cli URL" >&2; return 1; }
        local tmp
        tmp=$(mktemp -d)
        curl -fsSL "$url" -o "$tmp/twitch-cli.tar.gz"
        tar -xf "$tmp/twitch-cli.tar.gz" -C "$tmp"
        local bin
        bin=$(find "$tmp" -name 'twitch' -type f | head -1)
        [[ -z "$bin" ]] && { echo "twitch binary not found in archive" >&2; rm -rf "$tmp"; return 1; }
        install -m755 "$bin" "$HOME/.local/bin/twitch"
        rm -rf "$tmp"
    }
    try "twitch-cli" install_twitch_cli
fi
