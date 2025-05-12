#!/usr/bin/env bash
# ~/.config/sketchybar/plugins/current_track.sh (macOS version)
# Managed by Chezmoi. Uses osascript for Music.app and Spotify.

# Function to check if an application is running
is_app_running() {
  osascript -e "application \"$1\" is running" 2>/dev/null
}

# Function to get track info using osascript
get_track_info() {
  local app_name="$1"
  local script_output
  script_output=$(osascript -e "
    tell application \"$app_name\"
      if player state is playing or player state is paused then
        set current_artist to artist of current track
        set current_title to name of current track
        set player_state_text to \"unknown\"
        if player state is playing then
          set player_state_text to \"Playing\"
        else if player state is paused then
          set player_state_text to \"Paused\"
        end if
        return player_state_text & \"|\" & current_artist & \"|\" & current_title
      else
        return \"Stopped||Unknown Track\"
      end if
    end tell
  " 2>/dev/null)
  echo "$script_output"
}

PLAYER_INFO=""
APP_FOUND=""

# Prioritize Spotify if it's running and playing/paused
if [[ $(is_app_running "Spotify") == "true" ]]; then
  PLAYER_INFO=$(get_track_info "Spotify")
  APP_FOUND="Spotify"
fi

# If Spotify isn't providing info, try Music.app
if [[ -z "$PLAYER_INFO" || "$PLAYER_INFO" == "Stopped||Unknown Track" ]]; then
  if [[ $(is_app_running "Music") == "true" ]]; then # Music.app (or iTunes on older macOS)
    PLAYER_INFO=$(get_track_info "Music")
    APP_FOUND="Music"
  fi
fi

if [[ -n "$PLAYER_INFO" && "$PLAYER_INFO" != "Stopped||Unknown Track" ]]; then
  PLAYER_STATE=$(echo "$PLAYER_INFO" | cut -d'|' -f1)
  ARTIST=$(echo "$PLAYER_INFO" | cut -d'|' -f2)
  TITLE=$(echo "$PLAYER_INFO" | cut -d'|' -f3)

  STATUS_ICON="" # Default: Play icon (means paused or stopped)
  if [ "$PLAYER_STATE" = "Playing" ]; then
    STATUS_ICON="" # Pause icon (means playing)
  elif [ "$PLAYER_STATE" = "Paused" ]; then
    STATUS_ICON="" # Play icon
  else
    STATUS_ICON="" # Stop icon / Unknown (should ideally hide item)
    sketchybar --set current_track drawing=off
    exit 0
  fi

  TRACK_INFO_DISPLAY=""
  if [ "$ARTIST" != "" ] && [ "$ARTIST" != "missing value" ]; then
    TRACK_INFO_DISPLAY="$ARTIST - $TITLE"
  else
    TRACK_INFO_DISPLAY="$TITLE"
  fi

  # Truncate if too long
  MAX_LEN=35 # Adjust as needed
  if [ "${#TRACK_INFO_DISPLAY}" -gt "$MAX_LEN" ]; then
    TRACK_INFO_DISPLAY="$(echo "$TRACK_INFO_DISPLAY" | cut -c 1-$((MAX_LEN-3)))..."
  fi

  ICON_COLOR="0xfff8f8f2" # Default white
  if [[ "$APP_FOUND" == "Spotify" ]]; then
    ICON_COLOR="0xff1DB954" # Spotify green
  fi

  sketchybar --set current_track label="$TRACK_INFO_DISPLAY" icon="$STATUS_ICON" icon.color="$ICON_COLOR" drawing=on
else
  sketchybar --set current_track drawing=off # Hide if no player active or no track info
fi
