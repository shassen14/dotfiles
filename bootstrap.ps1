# bootstrap.ps1: Install chezmoi and apply dotfiles on Windows.
# Run from an elevated PowerShell prompt.
$ErrorActionPreference = "Stop"

$DOTFILES_REPO = "https://github.com/shassen14/dotfiles.git"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

# Install chezmoi via winget if missing
if (-not (Get-Command chezmoi -ErrorAction SilentlyContinue)) {
    winget install --id twpayne.chezmoi --exact --accept-source-agreements --accept-package-agreements
    # Refresh PATH so chezmoi is available immediately
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH", "User")
}

# Use local clone as chezmoi source if running from the repo.
# Otherwise fall back to cloning from the remote.
if (Test-Path (Join-Path $SCRIPT_DIR "home")) {
    $SOURCE = Join-Path $SCRIPT_DIR "home"
    chezmoi init --source $SOURCE
    # Pass --source to apply too: `init --source` does not always persist, so a
    # bare `apply` can fall back to the default (~/.local/share/chezmoi) and fail
    # with "The system cannot find the path specified." This first apply writes
    # ~/.config/chezmoi/chezmoi.toml with the real sourceDir, so later bare
    # `chezmoi` commands work.
    chezmoi apply --source $SOURCE -v
} else {
    chezmoi init $DOTFILES_REPO
    chezmoi apply -v
}
