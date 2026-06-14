#!/usr/bin/env bash
# run_once_configure-nvidia-suspend-linux.sh
# Fixes black-screen-on-resume with the NVIDIA proprietary driver by preserving
# video memory across suspend and enabling the driver's power-management units.
# Chezmoi re-runs this when the file content changes — bump the version to force a re-run.
# version: 1

[[ "$(uname)" != "Linux" ]] && exit 0

# Only act when the NVIDIA proprietary driver is actually present.
if ! command -v nvidia-smi &>/dev/null && [[ ! -e /proc/driver/nvidia/version ]]; then
    echo "NVIDIA driver not detected — skipping suspend/resume config."
    exit 0
fi

modprobe_conf=/etc/modprobe.d/nvidia-power.conf
desired='options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp'

# 1. Preserve video memory across suspend (the root cause of the black screen).
if [[ "$(cat "$modprobe_conf" 2>/dev/null)" != "$desired" ]]; then
    echo "$desired" | sudo tee "$modprobe_conf" > /dev/null
    echo "Wrote $modprobe_conf"

    # Rebuild initramfs so the module option takes effect at boot.
    if command -v update-initramfs &>/dev/null; then
        sudo update-initramfs -u
    elif command -v dracut &>/dev/null; then
        sudo dracut --force
    elif command -v mkinitcpio &>/dev/null; then
        sudo mkinitcpio -P
    fi
else
    echo "OK: $modprobe_conf already configured"
fi

# 2. Enable the driver's suspend/resume/hibernate services (often shipped but
#    not enabled). Skip any that don't exist on this driver version.
for unit in nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service; do
    if systemctl list-unit-files "$unit" &>/dev/null \
        && systemctl list-unit-files "$unit" | grep -q "$unit"; then
        if ! systemctl is-enabled "$unit" &>/dev/null; then
            sudo systemctl enable "$unit" && echo "Enabled $unit"
        else
            echo "OK: $unit already enabled"
        fi
    else
        echo "WARN: $unit not found — driver may not ship it" >&2
    fi
done

echo "NVIDIA suspend/resume configured. Reboot for the modprobe change to take effect."
