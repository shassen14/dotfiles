#!/bin/bash
# ~/.config/i3/scripts/lock.sh
# Managed by Chezmoi: {{ .chezmoi.sourceFile }}
# Locks the screen, preferring i3lock-color for feedback.

# --- Configuration ---
# Use hex codes (without #) or named colors i3lock-color recognizes.
# Dracula Theme Colors (Adapt as needed)
BG_COLOR="282a36"
FG_COLOR="f8f8f2"
WRONG_COLOR="ff5555"  # Red
VERIFY_COLOR="50fa7b" # Green
INSIDE_COLOR="44475a" # Current Line / Darker Purple
RING_COLOR="6272a4"   # Comment / Lighter Purple
KEY_HL_COLOR="8be9fd" # Cyan for key press highlight
BSH_HL_COLOR="ff79c6" # Pink for backspace highlight

# --- Lock Command ---
if command -v i3lock-color &> /dev/null; then
    # Use i3lock-color with feedback options
    i3lock-color \
        --insidevercolor=${VERIFY_COLOR}ff \
        --insidewrongcolor=${WRONG_COLOR}ff \
        --insidecolor=${INSIDE_COLOR}cc \
        --ringvercolor=${VERIFY_COLOR}ff \
        --ringwrongcolor=${WRONG_COLOR}ff \
        --ringcolor=${RING_COLOR}ff \
        --linecolor=${BG_COLOR}ff \
        --keyhlcolor=${KEY_HL_COLOR}ff \
        --bshlcolor=${BSH_HL_COLOR}ff \
        --separatorcolor=${BG_COLOR}ff \
        --verifcolor=${FG_COLOR}ff \
        --wrongcolor=${FG_COLOR}ff \
        --timecolor=${FG_COLOR}ff \
        --datecolor=${FG_COLOR}ff \
        --layoutcolor=${FG_COLOR}ff \
        --greetercolor=${FG_COLOR}ff \
        --keylayout 0 \
        --ignore-empty-password \
        --pass-media-keys \
        --pass-screen-keys \
        --pass-power-keys \
        --indicator \
        --radius 120 \
        --ring-width 10 \
        --veriftext="Verifying..." \
        --wrongtext="Auth Failed!" \
        --noinputtext="Password Cleared" \
        --locktext="Locking..." \
        --lockfailedtext="Lock Failed!" \
        --datepos="tx:ty+30" \
        --timepos="tx:ty" \
        --timesize=28 \
        --datesize=18 \
        --greetertext="Enter Password" \
        --greeterpos="tx:ty+60" \
        --greetersize=14 \
        --modsize=10 \
        # --blur 5 \ # Optional: Add blur if desired and picom doesn't interfere
        # --image /path/to/background.png \ # Optional: Use an image background
        --clock # Show time and date
        # --datestr="%A, %d %B %Y" \
        # --timestr="%H:%M:%S"

else
    # Fallback to simple i3lock if i3lock-color isn't found
    echo "WARNING: i3lock-color not found, using basic i3lock." >&2
    i3lock -c "$BG_COLOR" # Use background color
fi
