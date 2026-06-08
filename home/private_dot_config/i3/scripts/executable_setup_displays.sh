#!/usr/bin/env bash
# setup_displays.sh — deterministic display bringup for i3 startup (NVIDIA-friendly).
#
# Why this exists: a bare `autorandr --change` silently does nothing when no saved
# profile matches the current hardware, leaving a second monitor dark on boot.
# This script tries a saved profile first, then GUARANTEES every connected output
# is enabled and arranged left-to-right so you never boot into a single-monitor mess.
#
# To make a layout "sticky", arrange it once (arandr / nvidia-settings) then save:
#     autorandr --save docked
# After that this script's autorandr step will restore it automatically.

export DISPLAY="${DISPLAY:-:0}"

# 1. Preferred: restore a saved autorandr profile that matches current hardware.
autorandr --change 2>/dev/null || true

# 2. Safety net: if fewer outputs are ACTIVE than are physically CONNECTED,
#    auto-enable everything left-to-right (primary = first connected output).
connected=$(xrandr --query | grep -c " connected")
active=$(xrandr --query | grep -cE " connected [a-z]*\s*[0-9]+x[0-9]+\+")

if (( active < connected )); then
    prev=""
    while read -r out; do
        if [[ -z "$prev" ]]; then
            xrandr --output "$out" --auto --primary
        else
            xrandr --output "$out" --auto --right-of "$prev"
        fi
        prev="$out"
    done < <(xrandr --query | awk '/ connected/{print $1}')
fi
