#!/bin/bash
set -e

echo "============================"
echo "  steelboot bootstrapper"
echo "============================"

# Ensure script is running as root or via sudo
if [ "$EUID" -ne 0 ]; then
  echo "[!] Please run this script as root (or with sudo)."
  exit 1
fi

# Update APT cache
echo "[*] Updating package lists..."
apt-get update -y

# Install prerequisites
echo "[*] Installing required packages..."
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git

# Add Docker GPG key and repo
if ! [ -f /etc/apt/keyrings/docker.gpg ]; then
  echo "[*] Adding Docker GPG key..."
  mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg
fi

echo "[*] Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
echo "[*] Installing Docker Engine..."
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Ensure docker group exists and user is added to it
if ! getent group docker > /dev/null; then
  groupadd docker
fi

echo "[*] Adding current user to docker group..."
usermod -aG docker "$SUDO_USER"

echo
echo "[*] steelboot bootstrap complete."
echo "[*] You may need to log out and back in for Docker group permissions to apply."

