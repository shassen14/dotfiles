#!/usr/bin/env bash

if pgrep -x "Spotify" >/dev/null 2>&1; then
	STATE=$(osascript -e 'tell app "Spotify" to player state as string' 2>/dev/null)
	if [ "$STATE" = "playing" ]; then
		TRACK=$(osascript -e 'tell app "Spotify" to (name of current track & " - " & artist of current track)' 2>/dev/null)
		sketchybar --set "$NAME" label="$TRACK" drawing=on
	else
		sketchybar --set "$NAME" drawing=off
	fi
else
	sketchybar --set "$NAME" drawing=off
fi
