# komorebi watchdog — keeps komorebi + whkd running and logs every komorebi run.
#
# Launched at login (hidden, via `conhost --headless`) by the "komorebi-watchdog"
# Startup shortcut that run_once_install-packages-windows registers.
#
# Logs: %LOCALAPPDATA%\komorebi\logs\
#   watchdog.log                  — starts, exits (with exit code), restarts
#   komorebi-<time>.log/.err.log  — komorebi's own output for each run (newest 10 kept)
#   whkd.log                      — whkd output (e.g. "could not load whkdrc")
#
# Exit code 0 = clean stop (komorebic stop); anything else = crash — check the
# .err.log for that run. To stop tiling on purpose, end this watchdog first
# (Stop-Process -Name pwsh where the command line mentions watchdog.ps1),
# otherwise it brings komorebi straight back.

$config     = Join-Path $HOME ".config\komorebi\komorebi.json"
$logDir     = Join-Path $env:LOCALAPPDATA "komorebi\logs"
$logLevel   = "warn"   # komorebi --log-level; "info" logs every window title change
$keepRuns   = 10
$pollSecs   = 3
$burstMax   = 5        # this many starts within $burstWindow => back off
$burstWindow = [TimeSpan]::FromMinutes(2)
$backoffSecs = 60

New-Item -ItemType Directory -Force $logDir | Out-Null
$watchLog = Join-Path $logDir "watchdog.log"

# Single instance per login session.
$mutex = [System.Threading.Mutex]::new($false, "Local\komorebi-watchdog")
if (-not $mutex.WaitOne(0)) { exit }

function Write-Log([string]$msg) {
    if ((Test-Path $watchLog) -and (Get-Item $watchLog).Length -gt 1MB) {
        Move-Item -Force $watchLog (Join-Path $logDir "watchdog.old.log")
    }
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $msg" | Add-Content $watchLog
}

function Find-Exe([string]$name, [string]$fallback) {
    $cmd = Get-Command $name -ErrorAction SilentlyContinue
    if ($cmd) { $cmd.Source } else { $fallback }
}

$komorebiExe = Find-Exe "komorebi.exe" "C:\Program Files\komorebi\bin\komorebi.exe"
$whkdExe     = Find-Exe "whkd.exe" "C:\Program Files\whkd\bin\whkd.exe"

function Start-Whkd {
    if (Get-Process whkd -ErrorAction SilentlyContinue) { return }
    $whkdLog = Join-Path $logDir "whkd.log"
    Start-Process $whkdExe -WindowStyle Hidden `
        -RedirectStandardOutput $whkdLog -RedirectStandardError (Join-Path $logDir "whkd.err.log")
    Write-Log "whkd was not running — started it"
}

function Start-Komorebi {
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $out = Join-Path $logDir "komorebi-$stamp.log"
    $err = Join-Path $logDir "komorebi-$stamp.err.log"
    $p = Start-Process $komorebiExe -WindowStyle Hidden -PassThru `
        -ArgumentList "--config", "`"$config`"", "--log-level", $logLevel `
        -RedirectStandardOutput $out -RedirectStandardError $err
    Write-Log "started komorebi (pid $($p.Id)), log: komorebi-$stamp.log"

    # Prune old run logs (keep the newest $keepRuns runs).
    Get-ChildItem $logDir -Filter "komorebi-*.log" |
        Where-Object Name -notlike "*.err.log" |
        Sort-Object Name -Descending | Select-Object -Skip $keepRuns |
        ForEach-Object {
            Remove-Item $_.FullName, ($_.FullName -replace '\.log$', '.err.log') -ErrorAction SilentlyContinue
        }
    $p
}

Write-Log "watchdog started (pid $PID)"
$proc = $null
$starts = [System.Collections.Generic.List[datetime]]::new()

while ($true) {
    Start-Whkd

    if ($proc -and $proc.HasExited) {
        $code = try { $proc.ExitCode } catch { "unknown" }
        $ranFor = try { "{0:hh\:mm\:ss}" -f ((Get-Date) - $proc.StartTime) } catch { "?" }
        $kind = if ($code -eq 0) { "clean stop" } else { "CRASH" }
        Write-Log "komorebi (pid $($proc.Id)) exited — code $code ($kind) after $ranFor"
        $proc = $null
        # `komorebic stop` keeps cleaning up for a few seconds and force-kills any
        # komorebi that starts meanwhile — let it finish before restarting.
        if ($code -eq 0) { Start-Sleep -Seconds 4 }
    }

    if (-not $proc) {
        # Adopt an instance started elsewhere (e.g. alt+ctrl+r fallback) instead of
        # launching a second one.
        $existing = Get-Process komorebi -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($existing) {
            $proc = $existing
            Write-Log "watching komorebi started outside the watchdog (pid $($proc.Id)) — no log for this run"
        } else {
            $cutoff = (Get-Date) - $burstWindow
            $starts.RemoveAll({ param($t) $t -lt $cutoff }) | Out-Null
            if ($starts.Count -ge $burstMax) {
                Write-Log "komorebi died $burstMax times in $($burstWindow.TotalMinutes) min — backing off $backoffSecs s"
                $starts.Clear()
                Start-Sleep -Seconds $backoffSecs
                continue
            }
            $proc = Start-Komorebi
            $starts.Add((Get-Date))
        }
    }

    Start-Sleep -Seconds $pollSecs
}
