#!/usr/bin/bash

set ${SET_X:+-x} -eou pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

log "Installing HTPC-focused packages only"

log "Install essential HTPC applications"

# HTPC-focused Applications (minimal set)
HTPC_PACKAGES=(
    # Core system essentials
    fish
    tailscale
    papirus-icon-theme
    lm_sensors
    udisks2
    udiskie
    pipewire
    pipewire-pulse
    wireplumber
    pipewire-alsa
    playerctl
    linux-firmware
    
    # Essential for media playback
    gamemode
    gamemode-devel
    
    # MacBook thermal management (if needed)
    mbpfan
    thermald
    
    # Basic system monitoring
    btop
    
    # File system support for media files
    exfatprogs
    ntfs-3g
    btrfs-progs
    
    # Network file system support for media shares
    gvfs
    gvfs-smb
    gvfs-fuse
    gvfs-mtp
    gvfs-archive
    gvfs-nfs
    samba-client
    cifs-utils
    
    # Audio/multimedia essentials
    pipewire-utils
    wireplumber
)

dnf5 install --setopt=install_weak_deps=False --nogpgcheck --skip-unavailable -y "${HTPC_PACKAGES[@]}"

log "Disable Copr repos if any were enabled"
if [ ${#COPR_REPOS[@]} -gt 0 ]; then
    for repo in "${COPR_REPOS[@]}"; do
        dnf5 -y copr disable "$repo"
    done
fi

log "HTPC package installation with basic emulation support complete"
log "Note: Most emulators are best installed via Flatpak for better compatibility"