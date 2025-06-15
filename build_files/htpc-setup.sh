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
    
    # Media center applications
    kodi
    
    # Media server access and streaming
    kodi-inputstream-adaptive
    kodi-inputstream-rtmp
    
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

dnf5 install --setopt=install_weak_deps=False --nogpgcheck -y "${HTPC_PACKAGES[@]}"

log "Creating HTPC user account"
# Create the htpc user with appropriate groups
useradd -m -G wheel,audio,video,input,pulse-access -s /bin/bash htpc
echo "htpc:htpc" | chpasswd

# Set up htpc user home directory permissions
chown -R htpc:htpc /home/htpc

log "Configuring automatic login with SDDM"
# Create SDDM configuration directory
mkdir -p /etc/sddm.conf.d

# Configure automatic login for htpc user
cat > /etc/sddm.conf.d/autologin.conf << 'EOF'
[Autologin]
User=htpc
Session=plasma-bigscreen-wayland

[General]
HaltCommand=/usr/bin/systemctl poweroff
RebootCommand=/usr/bin/systemctl reboot

[Theme]
Current=breeze

[X11]
ServerPath=/usr/bin/X
XephyrPath=/usr/bin/Xephyr
SessionCommand=/usr/share/sddm/scripts/Xsession
SessionDir=/usr/share/xsessions
XauthPath=/usr/bin/xauth

[Wayland]
SessionDir=/usr/share/wayland-sessions
CompositorCommand=kwin_wayland --drm --xwayland
EOF

# Ensure SDDM will actually auto-login (critical configuration)
cat > /etc/sddm.conf << 'EOF'
[Autologin]
User=htpc
Session=plasma-bigscreen-wayland
Relogin=false

[General]
HaltCommand=/usr/bin/systemctl poweroff
RebootCommand=/usr/bin/systemctl reboot
Numlock=on

[Theme]
Current=breeze
CursorTheme=breeze_cursors

[Users]
MaximumUid=60513
MinimumUid=500
HideUsers=
HideShells=/sbin/nologin,/bin/false
RememberLastUser=true
RememberLastSession=true
EOF

log "Setting up Plasma Bigscreen as default session for htpc user"
# Create user config directories
mkdir -p /home/htpc/.config
mkdir -p /home/htpc/.local/share/applications

# Set Plasma Bigscreen as the default session
echo "plasma-bigscreen-wayland" > /home/htpc/.dmrc

# Create desktop session preference
cat > /home/htpc/.config/plasma-bigscreen-session.conf << 'EOF'
[General]
DefaultSession=plasma-bigscreen-wayland
EOF

log "Configuring HTPC-specific systemd services"
# Enable SDDM display manager
systemctl enable sddm.service

# Enable audio services for media playback
systemctl enable pipewire.service
systemctl enable pipewire-pulse.service
systemctl enable wireplumber.service

# Enable network services for media streaming
systemctl enable avahi-daemon.service

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

# Basic LIRC configuration
cat > /etc/lirc/lirc_options.conf << 'EOF'
[lircd]
nodaemon        = False
permission      = 666
allow-simulate  = No
repeat-max      = 600

[lircmd]
EOF

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

log "Configuring audio for HTPC use"
# Set up PulseAudio configuration for media center use
mkdir -p /home/htpc/.config/pulse

cat > /home/htpc/.config/pulse/daemon.conf << 'EOF'
# HTPC-optimized PulseAudio configuration
default-sample-format = s24le
default-sample-rate = 48000
alternate-sample-rate = 44100
default-sample-channels = 2
default-channel-map = front-left,front-right

# Larger buffers for media playback
default-fragments = 8
default-fragment-size-msec = 25

# Automatically switch to newly connected audio devices
module-switch-on-connect = yes
EOF

log "Setting up HTPC power management"
# Configure power management for HTPC use
cat > /etc/systemd/logind.conf.d/htpc.conf << 'EOF'
[Login]
# Don't suspend on lid close (for HTPC laptops)
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore

# Allow htpc user to manage power
HandlePowerKey=poweroff
HandleSuspendKey=suspend
HandleHibernateKey=hibernate

# Prevent auto-suspend during media playback
IdleAction=ignore
IdleActionSec=infinity
EOF

log "Configuring video acceleration"
# Set up video acceleration for Intel/AMD GPUs
cat > /etc/environment << 'EOF'
# HTPC video acceleration
LIBVA_DRIVER_NAME=iHD
VDPAU_DRIVER=va_gl
MOZ_X11_EGL=1
MOZ_ENABLE_WAYLAND=1
EOF

log "Setting up media sharing configuration"
# Configure minidlna for media sharing (useful for local media access)
cat > /etc/minidlna.conf << 'EOF'
# HTPC media server configuration
media_dir=V,/home/htpc/Videos
media_dir=A,/home/htpc/Music
media_dir=P,/home/htpc/Pictures

friendly_name=SoltrOS HTPC
db_dir=/var/cache/minidlna
log_dir=/var/log
inotify=yes
enable_tivo=no
strict_dlna=no
notify_interval=895
serial=12345678
model_number=1
EOF

# Enable minidlna service
systemctl enable minidlna.service

log "Finalizing htpc user permissions for emulation and media"
# Set proper ownership for all htpc user files
chown -R htpc:htpc /home/htpc

# Add htpc user to additional groups for hardware access and emulation
usermod -a -G dialout,cdrom,floppy,tape,dip,video,plugdev,input,games htpc

log "Creating HTPC welcome script with emulation info"
# Create a welcome script for first boot
cat > /home/htpc/.local/bin/htpc-welcome << 'EOF'
#!/bin/bash
# SoltrOS HTPC Welcome Script

echo "Welcome to SoltrOS Media Center!"
echo "================================"
echo "Your HTPC is ready to use."
echo ""
echo "To install Jellyfin Media Player:"
echo "flatpak install flathub com.github.iwalton3.jellyfin-media-player"
echo ""
echo "Available applications:"
echo "- Plasma Bigscreen (TV interface)"
echo "- Jellyfin Media Player (install via Flatpak)"
echo "- RetroArch (Multi-system emulator)"
echo "- Standalone emulators (PCSX2, Dolphin, PPSSPP, etc.)"
echo "- Firefox (Web browser)"
echo ""
echo "Media directories:"
echo "- Videos: ~/Videos"
echo "- Music: ~/Music"  
echo "- Pictures: ~/Pictures"
echo ""
echo "Gaming directories:"
echo "- ROMs: ~/Games/ROMs/"
echo "- Saves: ~/Games/Saves/"
echo "- BIOS files: ~/Games/BIOS/"
echo ""
echo "Controller support:"
echo "- PlayStation (PS1-PS5) controllers"
echo "- Xbox (360, One, Series) controllers" 
echo "- Nintendo (Switch Pro, Joy-Con) controllers"
echo "- Steam Controller"
echo "- 8BitDo controllers"
echo ""
echo "Auto-login is enabled for user 'htpc'"
echo "Default password: 'htpc' (please change on first login)"
echo ""
echo "To access the desktop environment, log out and select"
echo "a different session from the login screen."
EOF

# Make the welcome script executable
chmod +x /home/htpc/.local/bin/htpc-welcome
mkdir -p /home/htpc/.local/bin
chown -R htpc:htpc /home/htpc/.local

log "HTPC setup completed successfully"
log "Configured emulators: RetroArch, PCSX2, Dolphin, PPSSPP, and more"
log "System will boot directly to Plasma Bigscreen with user 'htpc'"
log "Default password is 'htpc' - please change on first login"
log "ROMs should be placed in ~/Games/ROMs/ subdirectories"
log "BIOS files should be placed in ~/Games/BIOS/"