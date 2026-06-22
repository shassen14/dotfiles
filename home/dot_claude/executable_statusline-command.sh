#!/usr/bin/env bash
# Claude Code status line — model, context window bar, 5h session bar
# Receives JSON via stdin
# Used on macOS/Linux. Windows uses statusline-command.ps1 (see settings.json).

input=$(cat)

# --- Helper: render a bar of width BAR_WIDTH filled to a given percentage ---
# Usage: make_bar <used_pct_float> <width>
make_bar() {
  local pct="$1"
  local width="$2"
  local filled
  filled=$(echo "$pct $width" | awk '{n=int($1/100*$2+0.5); if(n>$2)n=$2; if(n<0)n=0; print n}')
  local empty=$(( width - filled ))
  local bar=""
  local i
  for (( i=0; i<filled; i++ )); do bar="${bar}█"; done
  for (( i=0; i<empty;  i++ )); do bar="${bar}░"; done
  printf "%s" "$bar"
}

# --- Model ---
model=$(echo "$input" | jq -r '.model.display_name // ""')

# --- Context window (this session) ---
# used_percentage is total_input_tokens / context_window_size for the current session
ctx_info=""
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
if [ -n "$used_pct" ] && [ -n "$ctx_size" ]; then
  bar=$(make_bar "$used_pct" 10)
  used_pct_int=$(printf "%.0f" "$used_pct")
  ctx_info=$(printf "ctx [%s] %d%%" "$bar" "$used_pct_int")
fi

# --- 5-hour rate limit ---
five_hour_info=""
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
if [ -n "$five_pct" ]; then
  bar=$(make_bar "$five_pct" 10)
  five_pct_int=$(printf "%.0f" "$five_pct")
  if [ -n "$five_resets_at" ]; then
    # macOS uses `date -r <epoch>`; GNU/Linux uses `date -d @<epoch>`. Try both.
    reset_time=$(date -r "$five_resets_at" "+%I:%M%p" 2>/dev/null || date -d "@$five_resets_at" "+%I:%M%p" 2>/dev/null)
    reset_time=$(echo "$reset_time" | sed 's/^0//')
    five_hour_info=$(printf "%s [%s] %d%%" "$reset_time" "$bar" "$five_pct_int")
  else
    five_hour_info=$(printf "[%s] %d%%" "$bar" "$five_pct_int")
  fi
fi

# --- Assemble and print ---
[ -n "$model" ]          && printf "\033[2m%s\033[0m" "$model"
[ -n "$ctx_info" ]       && printf "\033[2m  |  %s\033[0m" "$ctx_info"
[ -n "$five_hour_info" ] && printf "\033[2m  |  %s\033[0m" "$five_hour_info"
