#!/bin/bash

set -e

if [ "$EUID" -ne 0 ]; then 
    echo "Run as root: sudo ./setup.sh"
    exit 1
fi

# Get UID 1000 user (created during Ubuntu install)
USER_1000=$(id -nu 1000)

# Add user to sudo and docker groups
usermod -aG sudo,docker $USER_1000 2>/dev/null || true

# Install Docker
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    apt-get update
    apt-get install -y docker.io docker-compose
    systemctl enable docker
    systemctl start docker
else
    echo "Docker already installed"
fi

# Create parent directory with correct ownership
mkdir -p /mnt/hdd1/home-server
chown -R $USER_1000:$USER_1000 /mnt/hdd1/home-server

# Ensure docker-compose.yml exists in current directory
if [ ! -f docker-compose.yml ]; then
    echo "Error: docker-compose.yml not found in current directory"
    echo "Run this script from the directory containing docker-compose.yml"
    exit 1
fi

# Start services (as the user, so they own the containers)
echo "Starting services..."
su - $USER_1000 -c "cd $(pwd) && docker-compose up -d"

echo ""
echo "=== Done! ==="
echo ""
echo "User: $USER_1000 (UID 1000) - manages Docker and owns files"
echo ""
echo "Access services:"
echo "  Portainer: http://localhost:9000"
echo "  Jellyfin: http://localhost:8096"
echo "  qBittorrent: http://localhost:8080"
echo "  Minecraft: localhost:25565"
echo "  Nginx Proxy Manager: http://localhost:81"
echo ""
echo "Default logins:"
echo "  qBittorrent: admin / (check logs for password)"
echo "  Nginx Proxy Manager: admin@example.com / changeme"
echo ""
echo "Remember to change all default passwords!"
