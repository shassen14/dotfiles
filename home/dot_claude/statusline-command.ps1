# Claude Code status line — model, context window bar, 5h session bar (Windows)
# Receives JSON via stdin. macOS/Linux use statusline-command.sh.

$ErrorActionPreference = "SilentlyContinue"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$raw  = [Console]::In.ReadToEnd()
$data = $raw | ConvertFrom-Json

function Make-Bar([double]$pct, [int]$width) {
    $filled = [int][math]::Round($pct / 100 * $width)
    if ($filled -gt $width) { $filled = $width }
    if ($filled -lt 0)      { $filled = 0 }
    return ("█" * $filled) + ("░" * ($width - $filled))
}

$parts = @()

# --- Model ---
$model = $data.model.display_name
if ($model) { $parts += $model }

# --- Context window (this session) ---
$usedPct = $data.context_window.used_percentage
$ctxSize = $data.context_window.context_window_size
if ($null -ne $usedPct -and $null -ne $ctxSize) {
    $bar = Make-Bar ([double]$usedPct) 10
    $parts += "ctx [$bar] $([int][math]::Round([double]$usedPct))%"
}

# --- 5-hour rate limit ---
$fivePct   = $data.rate_limits.five_hour.used_percentage
$fiveReset = $data.rate_limits.five_hour.resets_at
if ($null -ne $fivePct) {
    $bar    = Make-Bar ([double]$fivePct) 10
    $pctInt = [int][math]::Round([double]$fivePct)
    if ($fiveReset) {
        $time = [DateTimeOffset]::FromUnixTimeSeconds([long]$fiveReset).LocalDateTime.ToString("h:mmtt", [System.Globalization.CultureInfo]::InvariantCulture)
        $parts += "$time [$bar] $pctInt%"
    } else {
        $parts += "[$bar] $pctInt%"
    }
}

# --- Assemble and print (dim), no trailing newline ---
$line = $parts -join "  |  "
if ($line) {
    $esc = [char]27
    [Console]::Out.Write("$esc[2m$line$esc[0m")
}
