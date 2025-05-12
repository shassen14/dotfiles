#!/usr/bin/env bash
# ~/.config/sketchybar/plugins/aerospace_workspaces.sh
# Managed by Chezmoi
# This script requires 'aerospace' CLI and 'jq'.

# Output format: <idx>:<name>(<num-windows-on-it>)|...
# Example: 1:Web(3)|2:Code(2)|3:Term(1)* (* indicates focused workspace)
# Icons for workspaces (adjust as needed)
WORKSPACE_ICONS=("" "" "" "" "" "" "" "" "" "") # Web, Term, Files, Media, Chat, DB, Game, Desktop, Docs, Settings
FOCUSED_BG_COLOR="0xff6272a4" # Purpleish for focused workspace background
DEFAULT_BG_COLOR="0x00000000" # Transparent background for others

generate_bar_output() {
    local output=""
    # Get workspace data from AeroSpace CLI in JSON format
    local workspaces_json
    workspaces_json=$(aerospace list-workspaces --focused-monitor) # Or --all-monitors
    if [ -z "$workspaces_json" ]; then
        echo "sketchybar --set aerospace_workspaces label=\"Error: AeroSpace CLI failed\""
        return
    fi

    local focused_workspace_id
    focused_workspace_id=$(echo "$workspaces_json" | jq -r '.[] | select(.visible_on_focused_monitor and .focused) | .name')


    echo "$workspaces_json" | jq -r -c '.[] | select(.visible_on_focused_monitor) | "\(.name) \(if .focused then "focused" else "unfocused" end) \(.windows_on_workspace | length)"' |
    while IFS=' ' read -r name focused_status window_count; do
        # Use idx for icon lookup, assuming names are numeric or you parse idx
        local idx=$name
        local icon="${WORKSPACE_ICONS[$((idx-1))]}" # Array is 0-indexed
        if [ -z "$icon" ]; then # Fallback if name isn't a simple number or out of icon array range
            icon="" # Default desktop icon
        fi

        local label_str="$icon $name"
        # local label_str="$icon $name ($window_count)" # Optionally show window count

        if [[ "$focused_status" == "focused" ]]; then
            output+="--add item aerospace_workspace.$name center \
                     --set aerospace_workspace.$name label=\"$label_str\" \
                                                 background.color=$FOCUSED_BG_COLOR \
                                                 background.corner_radius=3 \
                                                 label.color=0xfff8f8f2 \
                                                 click_script=\"aerospace workspace $name\" "
        else
            output+="--add item aerospace_workspace.$name center \
                     --set aerospace_workspace.$name label=\"$label_str\" \
                                                 background.color=$DEFAULT_BG_COLOR \
                                                 label.color=0xfff8f8f2 \
                                                 click_script=\"aerospace workspace $name\" "
        fi
    done

    if [ -n "$output" ]; then
        # Remove existing workspace items before adding new ones to prevent duplicates
        # This is a simple way; more robust would be to update existing items
        sketchybar --remove '/aerospace_workspace\..*/' $output
    else
        sketchybar --set aerospace_workspaces label="AeroSpace?"
    fi
}

generate_bar_output
# Note: SketchyBar's item management can be complex. This script recreates items.
# For more advanced updates (e.g., just changing label/color of existing items),
# you would query existing items and update them individually.
# This simple version is easier to start with.
