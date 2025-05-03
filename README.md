# My Cross-Platform Dotfiles & Setup

This repository uses Ansible and Chezmoi to configure my development environment consistently across macOS and various Linux distributions.

## Philosophy

-   **Ansible:** Handles system-level setup, package/application installation (using native managers and Homebrew), and service configuration. Aims for idempotency.
-   **Chezmoi:** Manages user-specific configuration files (dotfiles) stored in a separate Git repository. Handles templating for OS differences and secret management.

## Prerequisites

1.  **Git:** Needs to be installed to clone this repository and for Chezmoi.
2.  **Curl:** Used by the bootstrap script and potentially Chezmoi install.
3.  **Sudo access:** The bootstrap script and Ansible require `sudo` privileges for package installation and system configuration. You will likely be prompted for your password during the `bootstrap.sh` run unless passwordless sudo is configured.
4.  **(Linux Arch):** An AUR helper (defaults to `yay` in the playbook) is required for installing AUR packages like Obsidian. The playbook attempts to install `yay` if not found.
5.  **(Optional) Password Manager CLI:** If your Chezmoi templates rely on a password manager (like `pass`, `bw`, `op`), ensure the corresponding CLI tool is installed (you might need to add tasks to Ansible for this).

## Structure

-   `bootstrap.sh`: The initial script to run on a new machine. Installs Ansible and executes the main playbook.
-   `inventory.ini`: Ansible inventory file (typically just `localhost`).
-   `playbook.yml`: The main Ansible playbook that imports role-specific playbooks.
-   `playbooks/`: Directory containing modular Ansible playbooks for different components (Chezmoi, Docker, VSCode, etc.).
-   `group_vars/all.yml`: Global variables for Ansible (like Chezmoi repo URL).

## Usage

1.  **Clone this Repository:**
    ```bash
    git clone https://your-repo-url/ansible-dotfiles.git
    cd ansible-dotfiles
    ```

2.  **Review Configuration:**
    *   Modify `group_vars/all.yml` to set your correct `chezmoi_repo` URL.
    *   Review playbooks in `playbooks/` and adjust package lists or configurations as needed.

3.  **Run the Bootstrap Script:**
    ```bash
    ./bootstrap.sh
    ```
    *   This script will detect your OS, install Ansible if necessary, and then run `ansible-playbook`.
    *   You may be prompted for your `sudo` password.

4.  **Subsequent Runs:**
    *   To re-apply the entire configuration or apply updates:
        ```bash
        ansible-playbook playbook.yml -i inventory.ini -K
        ```
    *   To apply only specific parts using tags (e.g., update Docker and VSCode):
        ```bash
        ansible-playbook playbook.yml -i inventory.ini -K --tags "docker,vscode"
        ```
    *   To update only your dotfiles via Chezmoi after Ansible has run:
        ```bash
        chezmoi update
        chezmoi apply -v
        ```
        (Or just re-run the Ansible playbook, as it includes a `chezmoi apply` step).

## Chezmoi Repository

This setup assumes your actual dotfiles are managed in a *separate* Git repository configured within `group_vars/all.yml`. Refer to the [Chezmoi documentation](https://www.chezmoi.io/) for managing that repository.

## TODO / Future Improvements

-   [ ] Add installation tasks for password manager CLIs if needed by Chezmoi.
-   [ ] Implement more robust error handling in `bootstrap.sh`.
-   [ ] Consider using Ansible Vault for managing any secrets needed by Ansible itself.
-   [ ] Add specific Ansible handlers for restarting services only when configs change.
-   [ ] Explore Flatpak/Snap installations for apps like Obsidian on Linux distributions without easy native packages/repos.