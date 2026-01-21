# Home Server Setup

Simple Docker Compose setup for Portainer, Jellyfin, qBittorrent, Minecraft, and Nginx Proxy Manager.

## Prerequisites

- **Ubuntu Server** (or similar Debian-based Linux)
- **User created during installation** (gets UID 1000 automatically)
- **Hard drive** mounted at `/mnt/hdd1` (required - setup will fail without it)
- Root access

## Disk Setup

### Option 1: Simple Mount (Ext4)

```bash
# Find your disk
sudo fdisk -l

# Format disk (WARNING: This erases all data!)
sudo mkfs.ext4 /dev/sdX1

# Mount to /mnt/hdd1
sudo mkdir -p /mnt/hdd1
sudo mount /dev/sdX1 /mnt/hdd1

# Get UUID for fstab
sudo blkid /dev/sdX1

# Add to fstab for auto-mount on boot
sudo nano /etc/fstab
# Add line: UUID=your-uuid-here /mnt/hdd1 ext4 defaults 0 2

# Test mount
sudo mount -a
```

### Option 2: LVM Setup (Recommended for Multiple Disks)

```bash
# Install LVM tools
sudo apt-get update
sudo apt-get install -y lvm2

# Find your disk
sudo fdisk -l

# Create physical volume
sudo pvcreate /dev/sdX

# Create volume group (name it 'vg-data' or whatever you prefer)
sudo vgcreate vg-data /dev/sdX

# Create logical volume (use 100% of space, or specify size like -L 500G)
sudo lvcreate -l 100%FREE -n lv-home-server vg-data

# Format the logical volume
sudo mkfs.ext4 /dev/vg-data/lv-home-server

# Mount to /mnt/hdd1
sudo mkdir -p /mnt/hdd1
sudo mount /dev/vg-data/lv-home-server /mnt/hdd1

# Add to fstab for auto-mount on boot
sudo nano /etc/fstab
# Add line: /dev/vg-data/lv-home-server /mnt/hdd1 ext4 defaults 0 2

# Test mount
sudo mount -a
```

**Adding More Disks to LVM Later:**

```bash
# Create physical volume on new disk
sudo pvcreate /dev/sdY

# Extend volume group
sudo vgextend vg-data /dev/sdY

# Extend logical volume
sudo lvextend -l +100%FREE /dev/vg-data/lv-home-server

# Resize filesystem
sudo resize2fs /dev/vg-data/lv-home-server
```

## Quick Start

1. **Clone/download this repo:**
   ```bash
   git clone <repo-url> ~/home-server
   cd ~/home-server
   ```

2. **Run setup:**
   ```bash
   sudo ./setup.sh
   ```

3. **Access services** (after setup completes):
   - **Portainer**: http://localhost:9000 - Docker management
   - **Jellyfin**: http://localhost:8096 - Media server
   - **qBittorrent**: http://localhost:8080 - Torrent client
   - **Minecraft**: localhost:25565 - Minecraft server
   - **Nginx Proxy Manager**: http://localhost:81 - Reverse proxy with SSL

## Getting Started

### Step 1: Start with Portainer
1. Go to http://localhost:9000
2. Create admin password on first login
3. Browse your containers - see all services running

### Step 2: Configure qBittorrent
1. Go to http://localhost:8080
2. Login: `admin` / (check logs: `docker logs qbittorrent`)
3. **Change password immediately** (Tools → Options → Web UI)
4. Set download location: `/downloads`
5. Start downloading

### Step 3: Add Media to Jellyfin
1. Copy media files to: `/mnt/hdd1/home-server/jellyfin/media/`
   - Or download via qBittorrent to: `/mnt/hdd1/home-server/qbittorrent/downloads/`
2. Go to http://localhost:8096
3. Complete initial setup (create admin account)
4. Add library (Dashboard → Libraries → Add Media Library)
   - Content type: Movies, TV Shows, etc.
   - Folders: `/media` (or `/downloads` for qBittorrent downloads)

### Step 4: Set Up Nginx Proxy Manager (Optional - for SSL/clean URLs)
1. Go to http://localhost:81
2. Login: `admin@example.com` / `changeme`
3. **Change password immediately**
4. Add Proxy Host (see README section below for details)


## Managing Services

```bash
cd ~/home-server  # (or wherever you cloned the repo)

# Check status
docker-compose ps

# View logs
docker-compose logs -f [service-name]

# Restart service
docker-compose restart [service-name]

# Stop all
docker-compose down

# Start all
docker-compose up -d

# Update services (after editing docker-compose.yml)
sudo ./setup.sh
```

## Nginx Proxy Manager Setup (Optional)

**Purpose**: Get clean URLs with SSL certificates (e.g., `https://jellyfin.yourserver.duckdns.org`)

**Prerequisites**:
- DuckDNS URL pointing to your public IP
- Router port forwarding: Ports 80 and 443 → Your server

**Setup Steps**:
1. Access Nginx Proxy Manager: http://localhost:81
2. Login and change password
3. Add Proxy Host:
   - **Details tab**: Domain name (e.g., `jellyfin.yourserver.duckdns.org`)
   - Forward to: `jellyfin` (container name) or server IP
   - Forward port: `8096` (for Jellyfin)
   - Enable "Block Common Exploits" and "Websockets Support"
   - **SSL tab**: Request SSL certificate, enable "Force SSL"
4. Repeat for other services (qBittorrent: 8080, Portainer: 9000)

**Result**: Access services via clean HTTPS URLs from anywhere.

## File Locations

- **Setup files**: `~/home-server/` (or wherever you cloned the repo)
- **All data**: `/mnt/hdd1/home-server/`
- **Jellyfin media**: `/mnt/hdd1/home-server/jellyfin/media/`
- **Downloads**: `/mnt/hdd1/home-server/qbittorrent/downloads/`
- **Minecraft world**: `/mnt/hdd1/home-server/minecraft/`

## Adding New Services

1. Edit `docker-compose.yml`
2. Add your service configuration
3. Run `sudo ./setup.sh` again
4. Services update automatically

## Default Passwords (Change Immediately!)

- **qBittorrent**: `admin` / (check logs for generated password)
- **Nginx Proxy Manager**: `admin@example.com` / `changeme`
- **Jellyfin**: Set during first login
- **Portainer**: Set during first login
