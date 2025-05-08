#!/bin/bash
# ~/.config/i3status/scripts/media_status.sh
# Managed by Chezmoi: {{ .chezmoi.sourceFile }}
# Outputs currently playing media for i3status run_watch

# Max length for metadata to avoid overly long bar segment
MAX_LEN=40

# Check if playerctl can find a player
if playerctl status &> /dev/null; then
    PLAYER_STATUS=$(playerctl status)
    # Get metadata, handle cases where it might be empty or unavailable
    ARTIST=$(playerctl metadata artist 2>/dev/null || echo "")
    TITLE=$(playerctl metadata title 2>/dev/null || echo "")

    # Determine icon based on status
    if [[ "$PLAYER_STATUS" == "Playing" ]]; then
        ICON="▶" # Play icon
    elif [[ "$PLAYER_STATUS" == "Paused" ]]; then
        ICON="⏸" # Pause icon
    else
        ICON="⏹" # Stop icon
    fi

    # Format metadata
    if [[ -n "$ARTIST" && -n "$TITLE" ]]; then
        METADATA="$ARTIST - $TITLE"
    elif [[ -n "$TITLE" ]]; then
        METADATA="$TITLE"
    elif [[ -n "$ARTIST" ]]; then # Less common case
        METADATA="$ARTIST"
    else
        # Fallback if no metadata found but player is active
        PLAYER_NAME=$(playerctl metadata --format "{{ playerName }}" 2>/dev/null || echo "")
         if [[ -n "$PLAYER_NAME" ]]; then
            METADATA="($PLAYER_NAME)"
        else
            METADATA=""
        fi
    fi

    # Truncate if too long
    if [[ ${#METADATA} -gt $MAX_LEN ]]; then
        TRUNCATED_METADATA=$(echo "$METADATA" | cut -c1-$((MAX_LEN-1)))
        METADATA="${TRUNCATED_METADATA}…"
    fi

    # Output formatted string
    if [[ -n "$METADATA" ]]; then
         echo "$ICON $METADATA"
    else
        # Only show icon if no metadata but player active
         echo "$ICON"
    fi

else
    # No player found, output nothing
    echo ""
fi
