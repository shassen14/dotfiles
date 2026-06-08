#!/usr/bin/env bash
# Kill any running polybar instances and relaunch on all connected monitors.
# The primary monitor gets bar/main (workspaces + status).
# All other monitors get bar/secondary (workspaces + title only).

killall -q polybar
while pgrep -u "$UID" -x polybar > /dev/null; do sleep 0.1; done

PRIMARY=$(xrandr --query | awk '/ connected primary/ {print $1; exit}')
# Fall back to first connected monitor if xrandr has no primary set
if [[ -z "$PRIMARY" ]]; then
    PRIMARY=$(xrandr --query | awk '/ connected/ {print $1; exit}')
fi

for monitor in $(xrandr --query | awk '/ connected/ {print $1}'); do
    if [[ "$monitor" == "$PRIMARY" ]]; then
        MONITOR=$monitor polybar --reload main 2>&1 | tee -a /tmp/polybar-"$monitor".log &
    else
        MONITOR=$monitor polybar --reload secondary 2>&1 | tee -a /tmp/polybar-"$monitor".log &
    fi
done
