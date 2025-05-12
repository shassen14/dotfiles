#!/usr/bin/env bash
# ~/.config/sketchybar/plugins/battery.sh
# Managed by Chezmoi

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ "$PERCENTAGE" = "" ]; then
  sketchybar --set battery drawing=off
  exit 0
fi

ICON="" # Default: Empty
COLOR="0xfff8f8f2" # Default: White

if [[ "$CHARGING" != "" ]]; then
  ICON="" # Charging
  COLOR="0xff8be9fd" # Cyan
else
  case ${PERCENTAGE} in
    9[0-9]|100) ICON=""; COLOR="0xff50fa7b" ;; # Full, Green
    [6-8][0-9]) ICON=""; COLOR="0xff50fa7b" ;; # Good, Green
    [3-5][0-9]) ICON=""; COLOR="0xfff1fa8c" ;; # Okay, Yellow
    [1-2][0-9]) ICON=""; COLOR="0xffffb86c" ;; # Low, Orange
    *) ICON=""; COLOR="0xffff5555" ;; # Empty/Crit, Red
  esac
fi
sketchybar --set battery icon="$ICON" icon.color="$COLOR" label="${PERCENTAGE}%" drawing=on
