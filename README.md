# SoltrOS HTPC Edition

> 🖥️ **The ultimate Home Theater PC experience built on Universal Blue**

SoltrOS HTPC is a purpose-built operating system designed for your living room entertainment center. Based on Fedora Atomic Desktop and Universal Blue, it provides a rock-solid, auto-updating foundation optimized for media consumption and retro gaming.

## ✨ Features

### 📺 **TV-Optimized Interface**
- **Plasma Bigscreen** - KDE's 10-foot interface designed for TVs and remotes
- **Auto-login** - Boots directly to the entertainment interface
- **Controller-first navigation** - Designed for couch computing

### 🎮 **Gaming Ready**
- **RetroArch** - Multi-system emulator with extensive console support
- **Controller support** - PlayStation, Xbox, Nintendo, Steam Controller, 8BitDo
- **Game directories** - Pre-organized ROM and save file structure
- **Gaming optimizations** - Performance tweaks and hardware acceleration

### 📱 **Media Streaming**
- **Jellyfin Media Player** ready (install via Flatpak)
- **Hardware acceleration** - Intel/AMD GPU support for smooth 4K playback
- **Network sharing** - DLNA/UPnP media server built-in
- **Format support** - Extensive codec support for all media types

### 🔐 **Secure & Stable**
- **Immutable base** - Core system protected from changes
- **Automatic updates** - Security updates applied automatically
- **Verified boot** - Cryptographically signed container images
- **Rollback capability** - Previous system states always available

## 🚀 Quick Start

### **Installation**

**Recommended:** Install SoltrOS HTPC over **Fedora Silverblue** for the best experience:

1. **Install Fedora Silverblue** first from [getfedora.org](https://getfedora.org/silverblue/)
2. **Rebase to SoltrOS HTPC:**
   ```bash
   sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/soltros/soltros-htpc:latest
   sudo systemctl reboot
   ```

**Alternative:** Direct installation using our ISO:

1. **Download the ISO** from [Releases](https://github.com/soltros/soltros-os-mediacenter/releases)
2. **Flash to USB** using Balena Etcher or similar
3. **Boot and install** - Standard Fedora installer
4. **First boot** - System auto-logs in as `htpc` user

# View welcome guide
htpc-welcome
```

## 📁 Directory Structure

### **Media Directories**
- `~/Videos/` - Movie and TV show files
- `~/Music/` - Audio files and albums  
- `~/Pictures/` - Photo collections
- `~/Downloads/` - Downloaded content

### **Gaming Directories**
- `~/Games/ROMs/` - Game ROM files organized by system
  - `~/Games/ROMs/NES/` - Nintendo Entertainment System
  - `~/Games/ROMs/SNES/` - Super Nintendo
  - `~/Games/ROMs/PSX/` - PlayStation 1
  - `~/Games/ROMs/N64/` - Nintendo 64
  - *...and many more*
- `~/Games/BIOS/` - System BIOS files for emulators
- `~/Games/Saves/` - Game save states and saves
- `~/Games/Screenshots/` - Gaming screenshots

## 🎮 Supported Controllers

| Controller Type | Status | Notes |
|----------------|---------|-------|
| PlayStation (PS1-PS5) | ✅ Full Support | Wired and wireless |
| Xbox (360/One/Series) | ✅ Full Support | Wired and wireless |
| Nintendo (Switch Pro) | ✅ Full Support | Wired and wireless |
| Steam Controller | ✅ Full Support | All features |
| 8BitDo Controllers | ✅ Full Support | All models |
| Generic USB/Bluetooth | ✅ Basic Support | Most controllers work |

## 🛠️ Configuration

### **Display Settings**
Access display configuration through:
- **Plasma Bigscreen Settings** - TV-optimized interface
- **System Settings** - Full KDE control panel
- **Command line** - `xrandr` for advanced configuration

### **Audio Configuration**
- **HDMI Audio** - Automatically configured for TV output
- **Surround Sound** - 5.1/7.1 support where available
- **Audio Switching** - Automatic switching between devices
- **Per-application** - Individual app audio control

### **Network Shares**
Mount network drives for media access:
```bash
# SMB/CIFS shares
sudo mount -t cifs //server/share /mnt/media -o username=user

# NFS shares  
sudo mount -t nfs server:/path /mnt/media
```

## 🔧 System Management

### **Updates**
```bash
# Check for updates
rpm-ostree upgrade --check

# Apply updates (requires reboot)
rpm-ostree upgrade

# Rollback if needed
rpm-ostree rollback
```

### **Package Management**
```bash
# Install software via Flatpak (recommended)
flatpak install flathub app.name

# Layer RPM packages (requires reboot)
rpm-ostree install package-name

# Remove layered packages
rpm-ostree uninstall package-name
```

## 🎯 Recommended Applications

### **Media Players**
```bash
# Essential media applications
flatpak install flathub com.github.iwalton3.jellyfin-media-player
flatpak install flathub org.videolan.VLC
flatpak install flathub com.github.rafostar.Clapper
```

### **Gaming**
```bash
# Retro gaming suite
flatpak install flathub org.libretro.RetroArch
flatpak install flathub net.pcsx2.PCSX2
flatpak install flathub org.DolphinEmu.dolphin-emu
flatpak install flathub org.ppsspp.PPSSPP
```

### **Utilities**
```bash
# Useful HTPC utilities
flatpak install flathub com.github.tchx84.Flatseal  # Flatpak permissions
flatpak install flathub org.gnome.FileRoller       # Archive manager
flatpak install flathub org.qbittorrent.qBittorrent # Media downloads
```

## 🔍 Troubleshooting

### **Auto-login Issues**
```bash
# Check SDDM configuration
sudo cat /etc/sddm.conf

# Verify user exists
id htpc

# Check display manager status
systemctl status sddm
```

### **Controller Not Working**
```bash
# List input devices
ls /dev/input/

# Test controller input
evtest /dev/input/event*

# Check udev rules
ls /etc/udev/rules.d/*gaming*
```

### **Media Playback Issues**
```bash
# Check hardware acceleration
vainfo

# Audio device list
pactl list sinks

# Video driver info
lspci -k | grep -A 3 VGA
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### **Development Setup**
```bash
# Clone the repository
git clone https://github.com/soltros/soltros-os-mediacenter.git
cd soltros-os-mediacenter

# Build locally
podman build -t soltros-htpc .

# Test changes
podman run -it soltros-htpc
```

## 📄 License

SoltrOS HTPC is released under the [GPL-3.0 License](LICENSE).

## 🙏 Acknowledgments

- **Universal Blue** - For the amazing atomic desktop foundation
- **Fedora Project** - For the robust base operating system  
- **KDE Community** - For Plasma Bigscreen and excellent software
- **RetroArch Team** - For the incredible emulation platform

## 📞 Support

- **Documentation**: [GitHub Wiki](https://github.com/soltros/soltros-os-mediacenter/wiki)
- **Issues**: [GitHub Issues](https://github.com/soltros/soltros-os-mediacenter/issues)
- **Discussions**: [GitHub Discussions](https://github.com/soltros/soltros-os-mediacenter/discussions)

---

<div align="center">

**🖥️ Built for the Living Room • 🎮 Optimized for Gaming • 📺 Perfect for Media**

*SoltrOS HTPC - Where Entertainment Meets Reliability*

</div>