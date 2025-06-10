#!/usr/bin/env bash
# ~/.config/sketchybar/items/spaces.sh
# Managed by Chezmoi

# This script is sourced by sketchybarrc to create the workspace items.
# It should not directly call sketchybar --set for individual space properties here,
# as that's the job of the update script (plugins/space.sh) triggered by events.
source "$HOME/.config/sketchybar/variables.sh"

# Define a custom event that your AeroSpace config will trigger
# This is good practice to have a specific event for your workspace changes.
# You would trigger this from AeroSpace like:
# on-workspace-change run 'sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE_NAME=$AERO_WORKSPACE_NAME'
sketchybar --add event aerospace_workspace_changed

# Create items for each workspace reported by AeroSpace
# We will make them subscribe to the custom event.
CURRENT_WORKSPACES=$(aerospace list-workspaces --all) # Get all workspace names/IDs

# Remove all existing space items before adding new ones to prevent duplicates on reload
# This is important if the number of workspaces changes or on config reloads.
EXISTING_SPACE_ITEMS=$(sketchybar --query bar | jq -r '(.items // [])[] | select(type=="object" and .name? and (.name | startswith("space."))) | .name')

for item_name in $EXISTING_SPACE_ITEMS; do
	if [ -n "$item_name" ]; then # Ensure item_name is not empty
		sketchybar --remove "$item_name"
	fi
done

for sid in $CURRENT_WORKSPACES; do
	sketchybar --add item "space.$sid" left \
		--set "space.$sid" \
		icon.padding_left=7 \
		icon.padding_right=7 \
		label.drawing=off \
		script="$PLUGIN_DIR/space.sh" \
		--subscribe "space.$sid" aerospace_workspace_changed mouse.clicked
				# click_script="aerospace workspace $sid" \
done

# Optional: A bracket to group the spaces visually
# This bracket will also subscribe to the event to potentially update its width or appearance.
sketchybar --add bracket spaces_bracket '/space\..*/' \
	--set spaces_bracket \
	background.color=0x50282a36 \
	background.border_color="$RED" \
	background.border_width=$BORDER_WIDTH \
	background.corner_radius=$CORNER_RADIUS \
	background.height=$BACKGROUND_HEIGHT \
	background.y_offset=0
# Semi-transparent background for the bracket

# Trigger an initial update for all space items
# This ensures they get their initial state correctly from space.sh
# We pass the current focused workspace name as an argument to the event.
FOCUSED_WORKSPACE_FROM_AERO=$(aerospace list-workspaces --focused)
if [ -n "$FOCUSED_WORKSPACE_FROM_AERO" ]; then
	# This FOCUSED_WORKSPACE is correct for the plugins/space.sh script
	sketchybar --trigger aerospace_workspace_changed FOCUSED_WORKSPACE="$FOCUSED_WORKSPACE_FROM_AERO"
fi

echo "Space items created and initial update triggered."
