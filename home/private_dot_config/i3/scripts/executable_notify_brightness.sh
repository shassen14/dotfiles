#!/bin/bash
# ~/.config/i3/scripts/notify_brightness.sh
# Managed by Chezmoi: {{ .chezmoi.sourceFile }}
#
# Sends a brightness notification using dunst/notify-send and 'light' command.

# --- Configuration ---
TIMEOUT=1500
URGENCY="low"
REPLACE_ID="brightness"
USE_FONT_AWESOME=true

# --- Check for 'light' command ---
if ! command -v light &> /dev/null; then
    notify-send -u critical -t 3000 "Brightness Error" "'light' command not found. Please install it."
    exit 1
fi

# --- Get Brightness ---
# Using 'light -G' gets percentage, cut gets integer part
BRIGHTNESS=$(light -G | cut -d'.' -f1)

# --- Determine Icon ---
if [[ "$BRIGHTNESS" -lt 33 ]]; then
    ICON="display-brightness-low-symbolic"
    ICON_FA="" # Font Awesome variant
elif [[ "$BRIGHTNESS" -lt 66 ]]; then
    ICON="display-brightness-medium-symbolic"
    ICON_FA="" # Font Awesome variant
else
    ICON="display-brightness-high-symbolic"
    ICON_FA="" # Font Awesome variant
fi

# Select icon
if [[ "$USE_FONT_AWESOME" = true ]]; then
    FINAL_ICON=$ICON_FA
else
    FINAL_ICON=$ICON
fi

# --- Send Notification ---
notify-send -h int:value:"$BRIGHTNESS" -h string:x-canonical-private-synchronous:"$REPLACE_ID" -u "$URGENCY" -t "$TIMEOUT" -i "$FINAL_ICON" "Brightness: ${BRIGHTNESS}%"
