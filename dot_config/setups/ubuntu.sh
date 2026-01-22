#!/bin/bash
set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo "=== Updating system ==="
sudo apt update && sudo apt upgrade -y
echo "=== Installing Dependencies ==="
sudo apt install -y \
    zsh \
    xorg \
    xinit \
    i3 \
    dmenu \
    alacritty \
    feh \
    fonts-dejavu \
    fonts-font-awesome \
    pipewire \
    pipewire-pulse wireplumber pipewire-alsa pipewire-jack \
    pavucontrol \
    lightdm \
    lightdm-gtk-greeter \
    polybar \
    curl \
    mpv

echo "=== Installing Oh My Zsh  ==="
RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sudo chsh -s "$(which zsh)" "$USER"

echo "=== Configure Zsh ==="
cp -f "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc"
chmod 644 "$HOME/.zshrc"

echo "=== Installing NetworkManager==="
sudo apt install -y \
    network-manager \
    network-manager-gnome \

echo "=== Enable NetworkManager ==="
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

echo "=== Disable systemd-networkd ==="
sudo systemctl stop systemd-networkd systemd-networkd.socket
sudo systemctl disable systemd-networkd systemd-networkd.socket
sudo systemctl mask systemd-networkd systemd-networkd.socket

echo "=== Configure NetworkManager ==="
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

echo "=== Configure LightDM to start i3 ==="
sudo dpkg-reconfigure lightdm
echo "exec i3" > ~/.xsession

echo "=== Configure UFW ==="
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw --force enable

echo "=== Cleanup ==="
sudo apt autoremove -y

echo "=== Configure netplan ==="
NETPLAN_FILE=$(ls /etc/netplan/*.yaml 2>/dev/null | head -n1)
if [ -z "$NETPLAN_FILE" ]; then
    echo "No netplan config found, creating new one"
    NETPLAN_FILE="/etc/netplan/01-network-manager.yaml"
fi
sudo tee "$NETPLAN_FILE" >/dev/null <<EOF
network:
  version: 2
  renderer: NetworkManager
EOF

sudo netplan generate
sudo netplan apply

echo "====================================="
echo "SETUP COMPLETE"
echo "Rebooting system now"
echo "====================================="
sudo reboot
