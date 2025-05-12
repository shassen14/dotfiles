#!/usr/bin/env bash
# ~/.config/sketchybar/plugins/sound_volume.sh
# Managed by Chezmoi. Requires SwitchAudioSource (brew install switchaudio-osx)

VOLUME=$(osascript -e 'output volume of (get volume settings)')
MUTED=$(osascript -e 'output muted of (get volume settings)')
# CURRENT_OUTPUT_DEVICE=$(SwitchAudioSource -c -t output) # Can be verbose

ICON="" # Default: Speaker high
COLOR="0xfff8f8f2"

if [[ "$MUTED" == "true" ]]; then
  ICON="" # Muted
  LABEL_TEXT="Muted"
  COLOR="0xffff5555" # Red
else
  LABEL_TEXT="${VOLUME}%"
  case ${VOLUME} in
    [6-9][0-9]|100) ICON="";; # High
    [3-5][0-9]) ICON="";;     # Medium
    [1-9]|[1-2][0-9]) ICON="";; # Low (using Mute icon for very low for variety)
    0) ICON=""; LABEL_TEXT="Muted";; # Also show muted if volume is 0
    *) ICON="";;
  esac
fi

sketchybar --set sound_volume icon="$ICON" icon.color="$COLOR" label="$LABEL_TEXT"ß
