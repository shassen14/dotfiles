#!/usr/bin/env bash
# ~/.config/sketchybar/plugins/space.sh
# Managed by Chezmoi
# This script is executed for each space item (e.g., space.1, space.2)
# when the 'aerospace_workspace_changed' event is triggered.

# Environment variables provided by SketchyBar when this script is run for an item:
# - NAME: The name of the item (e.g., "space.1", "space.N").
# - SENDER: The event that triggered this script (e.g., "aerospace_workspace_changed").
# - INFO: For 'aerospace_workspace_changed', this will contain FOCUSED_WORKSPACE_NAME from the --trigger command.

# Load shared variables
source "$HOME/.config/sketchybar/variables.sh"

# Extract the SID (Workspace ID/Name) from the item's name (e.g., "space.1" -> "1")
# This assumes workspace names/IDs from AeroSpace don't contain dots.
# If they can (e.g., "1.Main"), you'll need a more robust parsing method.
ITEM_SID="${NAME#*.}" # Remove "space." prefix

# Default icons (can be overridden by specific workspace names below)
# These are examples, use your Nerd Font or Font Awesome characters
SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7" "8" "9") # Numbered icons
# Or use thematic icons if you name your workspaces in AeroSpace:
# declare -A NAMED_WORKSPACE_ICONS=(
#   ["Web"]=""
#   ["Code"]=""
#   ["Term"]=""
#   ["Chat"]=""
#   ["Music"]=""
# )

ICON_TO_SET=""
# Attempt to get an icon based on ITEM_SID if it's a number 1-10
if [[ "$ITEM_SID" =~ ^[1-9]+$ ]] && [ "$ITEM_SID" -ge 1 ] && [ "$ITEM_SID" -le 10 ]; then
	ICON_TO_SET="${SPACE_ICONS[$((ITEM_SID - 1))]}" # Array is 0-indexed for 1-10
else
	# Fallback or use named icons if ITEM_SID is not a simple number
	# ICON_TO_SET="${NAMED_WORKSPACE_ICONS[$ITEM_SID]}"
	if [ -z "$ICON_TO_SET" ]; then
		ICON_TO_SET="" # Default workspace icon (e.g., desktop)
	fi
fi

# Check if this space item is the currently focused one
# The FOCUSED_WORKSPACE_NAME is passed via the --trigger command's environment
# (e.g., sketchybar --trigger aerospace_workspace_changed FOCUSED_WORKSPACE_NAME="1")
IS_FOCUSED="false"
if [ "$ITEM_SID" = "$FOCUSED_WORKSPACE" ]; then # Expects FOCUSED_WORKSPACE env var
	IS_FOCUSED="true"
fi

if [ "$IS_FOCUSED" = "true" ]; then
	sketchybar --animate tanh 5 --set "$NAME" \
		icon="$ICON_TO_SET" \
		icon.color="$RED" \
		background.drawing=on
	# background.color="$POPUP_BACKGROUND_COLOR"

	# background.border_width=1 \
	# background.corner_radius=5 \
	# background.height=20 \
	# background.width=0 \
	# background.y_offset=0 # Ensure no unwanted vertical shift
	# background.border_color="$MAGENTA" \

else
	sketchybar --animate tanh 5 --set "$NAME" \
		icon="$ICON_TO_SET" \
		icon.color="$COMMENT" \
		background.drawing=off
fi
