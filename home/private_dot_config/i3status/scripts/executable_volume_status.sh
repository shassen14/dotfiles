#!/bin/bash
# ~/.config/i3status/scripts/volume_status.sh
# Managed by Chezmoi: {{ .chezmoi.sourceFile }}
# Outputs volume status with icons for i3status run_watch

# --- Configuration ---
USE_FONT_AWESOME=true # Set to false to use standard icon names

# --- Get Volume and Mute Status ---
# Use pactl for PulseAudio/PipeWire
if ! command -v pactl &> /dev/null; then
    echo "ERR: pactl not found"
    exit 1
fi

VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]{1,3}(?=%)' | head -n 1)
MUTE_STATUS=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')

# --- Determine Icon and Text ---
if [[ "$MUTE_STATUS" == "yes" ]]; then
    ICON="audio-volume-muted-symbolic"
    ICON_FA="" # Font Awesome Mute
    TEXT="Muted"
else
    TEXT="${VOLUME}%"
    if [[ "$VOLUME" -eq 0 ]]; then
        ICON="audio-volume-off-symbolic"
        ICON_FA="" # Font Awesome Mute/Off
    elif [[ "$VOLUME" -lt 33 ]]; then
        ICON="audio-volume-low-symbolic"
        ICON_FA="" # Font Awesome Low
    elif [[ "$VOLUME" -lt 66 ]]; then
        ICON="audio-volume-medium-symbolic"
        ICON_FA="" # Font Awesome Medium
    else
        ICON="audio-volume-high-symbolic"
        ICON_FA="" # Font Awesome High
    fi
fi

# Select icon
if [[ "$USE_FONT_AWESOME" = true ]]; then
    FINAL_ICON=$ICON_FA
else
    FINAL_ICON="($ICON)" # Add parentheses for themed names if you like
fi

# Output for i3status
echo "$FINAL_ICON $TEXT"
