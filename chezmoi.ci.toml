# ~/dotfiles/chezmoi.ci.toml
# Static configuration for CI and local bootstrap.
# Its main purpose is to provide the [data] block for all templates.
# The 'sourceDir' and 'destDir' are effectively controlled by CLI flags
# passed by Ansible during CI or local bootstrap 'apply' step.

# This [data] section MUST contain all keys that your templates
# (including your main chezmoi.toml.tmpl) will access.
[data]
  name = "Samir Hassen (CI/Bootstrap)"
  email = "your_actual_email@example.com" # Use your real email

  # Core application commands/names
  terminal = "alacritty"
  editor = "nvim"
  browser = "brave-browser" # General browser command (e.g., for Linux exec)

  # macOS specific application names (for 'open -a ...')
  terminal_app_name_mac = "Alacritty"
  browser_app_name_mac = "Brave Browser"

  # Linux specific executable names (if different from general 'browser', 'terminal')
  terminal_cmd_linux = "alacritty"
  browser_cmd_linux = "brave-browser"

# Add other essential global Chezmoi settings if needed for the bootstrap phase,
# but most will come from your main chezmoi.toml.tmpl.
# Example:
# encryption = "gpg"
# pager = "less -R"