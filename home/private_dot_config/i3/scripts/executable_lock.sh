#!/bin/bash
# ~/.config/i3/scripts/lock.sh
# Managed by Chezmoi: {{ .chezmoi.sourceFile }}

# --- Configuration ---
BLUR_AMOUNT="5x4" # How much to blur the background (if using i3lock-fancy or manual blur)
LOCK_ICON="$HOME/.config/i3/scripts/lock_icon.png" # Optional: path to an icon to overlay
I3LOCK_ARGS="-n -c 282a36" # -n: no fork, -c: background color (Dracula BG)

# --- Picom Check (Optional: Disable compositor for i3lock to avoid issues) ---
# if pgrep -x "picom" > /dev/null; then
#     # Kill picom before locking if you experience issues with blur/transparency
#     # pkill picom
#     # PICOM_KILLED=true
#     # sleep 0.1 # Give it a moment to die
# fi

# --- Option 1: Simple i3lock ---
# i3lock $I3LOCK_ARGS

# --- Option 2: i3lock with a background image (if feh is used for wallpaper) ---
# Requires a screenshot utility like scrot or maim
# TMP_BG="/tmp/screen_locked.png"
# scrot "$TMP_BG" # Or maim "$TMP_BG"
# convert "$TMP_BG" -scale 10% -scale 1000% "$TMP_BG" # Optional: pixelate
# convert "$TMP_BG" -blur $BLUR_AMOUNT "$TMP_BG"     # Optional: blur
# if [ -f "$LOCK_ICON" ]; then
#    convert "$TMP_BG" "$LOCK_ICON" -gravity center -composite -matte "$TMP_BG"
# fi
# i3lock -i "$TMP_BG" $I3LOCK_ARGS
# rm "$TMP_BG"

# --- Option 3: Using i3lock-color or i3lock-fancy (if installed) ---
# These often have built-in blur and better customization.
# Example for i3lock-color (syntax might vary)
if command -v i3lock-color &> /dev/null; then
    i3lock-color \
        --insidevercolor=bd93f9ff \
        --insidewrongcolor=ff5555ff \
        --insidecolor=282a3600 \
        --ringvercolor=f1fa8cff \
        --ringwrongcolor=ff79c6ff \
        --ringcolor=6272a4ff \
        --linecolor=282a36ff \
        --keyhlcolor=8be9fdff \
        --bshlcolor=ff79c6ff \
        --separatorcolor=282a3600 \
        --verifcolor=f8f8f2ff \
        --wrongcolor=f8f8f2ff \
        --timecolor=f8f8f2ff \
        --datecolor=f8f8f2ff \
        --layoutcolor=f8f8f2ff \
        --greetercolor=f8f8f2ff \
        --keylayout 0 \
        --blur 5 \
        --bar-indicator \
        --bar-pos y+h \
        --bar-direction 1 \
        --bar-max-height 50 \
        --bar-base-width 50 \
        --bar-color 282a36cc \
        --bar- γίνει \
        --bar-total-width 250 \
        --passstate \
        --passerror \
        --passwarn \
        --passgood \
        --noinputtext="" \
        --textsize=20 \
        --modsize=10 \
        --timefont="Fira Code" \
        --datefont="Fira Code" \
        --layoutfont="Fira Code" \
        --veriftext="Verifying..." \
        --wrongtext="Auth Failed!" \
        --radius 120 \
        --ring-width 10 \
        --screen 1
        # --datestr="%A, %m %Y" \
        # --timestr="%H:%M:%S"
else
    # Fallback to simple i3lock
    i3lock $I3LOCK_ARGS
fi


# --- Picom Restart (Optional: if killed before locking) ---
# if [ "$PICOM_KILLED" = true ]; then
#     # Restart picom. Ensure this matches how you start it in your i3 config.
#     picom --config {{ .chezmoi.homeDir }}/.config/picom/picom.conf &
# fi
