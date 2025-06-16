#!/usr/bin/bash

set ${SET_X:+-x} -eou pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

log "Setting up HTPC configuration with Plasma Bigscreen"

log "Installing Plasma Bigscreen and HTPC packages"
# Install Plasma Bigscreen and related media center packages
HTPC_PACKAGES=(
    # Plasma Bigscreen desktop environment (TV-optimized interface)
    plasma-bigscreen
    plasma-bigscreen-shell
    plasma-workspace
    
    # Display manager for automatic login
    sddm
    sddm-breeze
    sddm-kcm
    
    # Remote control support
    lirc
    
    # Audio/Video codecs for media playback
    gstreamer1-plugins-good
    gstreamer1-plugins-bad-free
    gstreamer1-plugins-ugly-free
    gstreamer1-libav
    
    # Hardware acceleration
    intel-media-driver
    libva-intel-driver
    mesa-va-drivers
    mesa-vdpau-drivers
    
    # Network media sharing
    minidlna
    
    # Essential KDE components for Plasma Bigscreen
    kwin
    plasma-systemsettings
    kde-cli-tools
    
    # Audio system
    pipewire-alsa
    pipewire-pulseaudio
    wireplumber
)

dnf5 install --setopt=install_weak_deps=False --nogpgcheck --skip-unavailable -y "${HTPC_PACKAGES[@]}"





log "Configuring HTPC-specific systemd services"
# Enable SDDM display manager
ln -sf /usr/lib/systemd/system/sddm.service /etc/systemd/system/display-manager.service

# Enable audio services for media playback (check if they exist first)
if [ -f /usr/lib/systemd/system/pipewire.service ]; then
    ln -sf /usr/lib/systemd/system/pipewire.service /etc/systemd/system/multi-user.target.wants/pipewire.service
fi

if [ -f /usr/lib/systemd/user/pipewire-pulse.service ]; then
    mkdir -p /etc/systemd/user/default.target.wants
    ln -sf /usr/lib/systemd/user/pipewire-pulse.service /etc/systemd/user/default.target.wants/pipewire-pulse.service
fi

if [ -f /usr/lib/systemd/user/wireplumber.service ]; then
    mkdir -p /etc/systemd/user/default.target.wants
    ln -sf /usr/lib/systemd/user/wireplumber.service /etc/systemd/user/default.target.wants/wireplumber.service
fi

# Enable network services for media streaming
if [ -f /usr/lib/systemd/system/avahi-daemon.service ]; then
    ln -sf /usr/lib/systemd/system/avahi-daemon.service /etc/systemd/system/multi-user.target.wants/avahi-daemon.service
fi

log "Setting up HTPC media directories and emulation"
# Create standard media directories
mkdir -p /home/htpc/{Videos,Music,Pictures,Downloads}

# Create emulation directories
mkdir -p /home/htpc/Games/{ROMs,Saves,Screenshots,BIOS}
mkdir -p /home/htpc/Games/ROMs/{NES,SNES,N64,GameCube,Wii,GB,GBC,GBA,DS,PSX,PS2,PSP,Genesis,Saturn,Dreamcast,Arcade}

# Set up Games directories with proper permissions
chown -R htpc:htpc /home/htpc/Games

log "Configuring remote control support"
# Set up LIRC for remote control support
mkdir -p /etc/lirc/lircd.conf.d


log "Setting up HTPC-specific udev rules for controllers and emulation"
# Create udev rules for HTPC devices
cat > /etc/udev/rules.d/99-htpc-devices.rules << 'EOF'
# HTPC device access rules

# Remote control receivers
SUBSYSTEM=="usb", ATTRS{idVendor}=="147a", MODE="0666", TAG+="uaccess"
SUBSYSTEM=="usb", ATTRS{idVendor}=="0471", MODE="0666", TAG+="uaccess"

# TV tuners and capture devices
SUBSYSTEM=="usb", ATTRS{idVendor}=="2040", MODE="0666", TAG+="uaccess"
SUBSYSTEM=="usb", ATTRS{idVendor}=="0ccd", MODE="0666", TAG+="uaccess"

# MCE remote controls
SUBSYSTEM=="usb", ATTRS{idVendor}=="0471", ATTRS{idProduct}=="0815", MODE="0666", TAG+="uaccess"

# Game controllers for emulation
# PlayStation controllers (PS1-PS5)
SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", MODE="0666", TAG+="uaccess"
SUBSYSTEM=="hidraw", KERNELS=="*054c*", MODE="0666", TAG+="uaccess"

# Xbox controllers (Original, 360, One, Series X/S)
SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", MODE="0666", TAG+="uaccess"
SUBSYSTEM=="hidraw", KERNELS=="*045e*", MODE="0666", TAG+="uaccess"

# Nintendo controllers (Switch Pro, Joy-Con, GameCube adapter)
SUBSYSTEM=="usb", ATTRS{idVendor}=="057e", MODE="0666", TAG+="uaccess"
SUBSYSTEM=="hidraw", KERNELS=="*057e*", MODE="0666", TAG+="uaccess"

# Steam Controller
SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666", TAG+="uaccess"
SUBSYSTEM=="hidraw", KERNELS=="*28de*", MODE="0666", TAG+="uaccess"

# 8BitDo controllers
SUBSYSTEM=="usb", ATTRS{idVendor}=="2dc8", MODE="0666", TAG+="uaccess"
SUBSYSTEM=="hidraw", KERNELS=="*2dc8*", MODE="0666", TAG+="uaccess"

# Generic USB game controllers
SUBSYSTEM=="usb", ATTRS{bInterfaceClass}=="03", ATTRS{bInterfaceSubClass}=="00", MODE="0666", TAG+="uaccess"
SUBSYSTEM=="input", GROUP="input", MODE="0664"
KERNEL=="js[0-9]*", MODE="0664", GROUP="input"
KERNEL=="event[0-9]*", MODE="0664", GROUP="input"
EOF

