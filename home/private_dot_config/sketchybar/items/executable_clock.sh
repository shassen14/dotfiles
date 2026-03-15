#!/usr/bin/env bash

COLOR="$MAGENTA"

sketchybar --add item clock right \
	--set clock update_freq=1 \
	icon.padding_left=10 \
	icon.color="$COLOR" \
	icon="" \
	label.color="$COLOR" \
	label.padding_right=5 \
	label.width=175 \
	align=center \
	background.height=$BACKGROUND_HEIGHT \
	background.corner_radius="$CORNER_RADIUS" \
	background.padding_right=3 \
	background.border_width="$BORDER_WIDTH" \
	background.border_color="$COLOR" \
	background.color="$BAR_COLOR" \
	background.drawing=on \
	script="$PLUGIN_DIR/clock.sh"
