#!/bin/bash
# ~/.config/i3/scripts/notify_volume.sh
# Managed by Chezmoi: {{ .chezmoi.sourceFile }}
#
# Sends a volume notification using dunst/notify-send based on pactl output.
# Usage: ./notify_volume.sh [mute]
# If "mute" argument is provided, it checks mute status specifically.

# --- Configuration ---
# Notification timeout in milliseconds
TIMEOUT=1500
# Notification urgency (low, normal, critical)
URGENCY="low"
# Notification ID/Hint for replacing previous volume notifications
REPLACE_ID="audio_volume"
# Optional: Set to true to use Font Awesome icons if you prefer
USE_FONT_AWESOME=true

# --- Get Volume and Mute Status ---
get_volume() {
    pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]{1,3}(?=%)' | head -n 1
}

get_mute_status() {
    pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}'
}

VOLUME=$(get_volume)
MUTE_STATUS=$(get_mute_status)

# --- Determine Icon and Text ---
if [[ "$1" == "mute" ]] || [[ "$MUTE_STATUS" == "yes" ]]; then
    # Mute status notification
    if [[ "$MUTE_STATUS" == "yes" ]]; then
        ICON="audio-volume-muted-symbolic"
        ICON_FA="" # Font Awesome Mute
        TEXT="Muted"
    else
        # Triggered by mute toggle, but now unmuted, show current volume level instead
         ICON="audio-volume-high-symbolic" # Assume high if unmuting
         ICON_FA="" # Font Awesome High
         TEXT="Vol: ${VOLUME}%"
    fi
else
    # Volume level notification
    if [[ "$VOLUME" -eq 0 ]]; then
        ICON="audio-volume-off-symbolic"
        ICON_FA="" # Font Awesome Mute/Off
    elif [[ "$VOLUME" -lt 33 ]]; then
        ICON="audio-volume-low-symbolic"
        ICON_FA="" # Font Awesome Low
    elif [[ "$VOLUME" -lt 66 ]]; then
        ICON="audio-volume-medium-symbolic"
        ICON_FA="" # Font Awesome Medium (same as low often)
    else
        ICON="audio-volume-high-symbolic"
        ICON_FA="" # Font Awesome High
    fi
    TEXT="Vol: ${VOLUME}%"
fi

# Select icon based on USE_FONT_AWESOME setting
if [[ "$USE_FONT_AWESOME" = true ]]; then
    FINAL_ICON=$ICON_FA
else
    FINAL_ICON=$ICON # Use standard themed icon names
fi


# --- Send Notification ---
# -h int:value: Provides a hint for progress bars in dunst
# -h string:x-canonical-private-synchronous: Hint to replace previous notifications with same ID
# -t: Timeout
# -u: Urgency
# -i: Icon
notify-send -h int:value:"$VOLUME" -h string:x-canonical-private-synchronous:"$REPLACE_ID" -u "$URGENCY" -t "$TIMEOUT" -i "$FINAL_ICON" "$TEXT"

# Optional: Play a sound feedback (requires a sound player like paplay or mpv)
# paplay /usr/share/sounds/freedesktop/stereo/audio-volume-change.oga &
