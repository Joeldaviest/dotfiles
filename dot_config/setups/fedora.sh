#!/bin/bash
set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "=== Updating system ==="
sudo dnf update -y

echo "=== Installing Dependencies ==="
sudo dnf install -y \
    zsh \
    xorg-x11-server-Xorg \
    xorg-x11-xinit \
    i3 \
    dmenu \
    alacritty \
    feh \
    dejavu-sans-fonts \
    dejavu-serif-fonts \
    dejavu-sans-mono-fonts \
    fontawesome-fonts \
    pipewire \
    pipewire-pulseaudio \
    wireplumber \
    pipewire-alsa \
    pipewire-jack-audio-connection-kit \
    pavucontrol \
    lightdm \
    lightdm-gtk \
    polybar \
    curl \
    mpv

echo "=== Installing Oh My Zsh ==="
RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sudo chsh -s "$(which zsh)" "$USER"

echo "=== Installing NetworkManager ==="
sudo dnf install -y \
    NetworkManager \
    network-manager-applet

echo "=== Enable NetworkManager ==="
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

echo "=== Configure LightDM ==="
sudo systemctl enable lightdm
echo "exec i3" > ~/.xsession
chmod +x ~/.xsession

echo "=== Configure Firewalld ==="
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --set-default-zone=public
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload

echo "=== Cleanup ==="
sudo dnf autoremove -y
sudo dnf clean all

echo "====================================="
echo "SETUP COMPLETE"
echo "Rebooting system now"
echo "====================================="
sudo reboot
