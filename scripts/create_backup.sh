#!/bin/bash

# ┌────────────────────────────────────────────────────────────────────────────────┐
# │                                                                                │
# │   create_backup.sh                                                             │
# │   a script that will create a package with the files and directories below     │
# │   needs to be run as root. It will create a package to restore the files later │
# ┼────────────────────────────────────────────────────────────────────────────────┼
# │   Guillaume Plante  <guillaumeplante.qc@gmail.com>                             │
# └────────────────────────────────────────────────────────────────────────────────┘

# Colors for output
UL='\033[4;93m'
IL='\033[3;91m'
BL='\033[6;94m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

LogCategory=backup

# handy logging and error handling functions
pecho() { printf %s\\n "$*"; }

log() { pecho "$@"; }

# Verbose output function
log_info() {
    echo -e "${CYAN}[INFO] $1${NC}"
    logger --tag $LogCategory -p user.info "[INFO] $1"
}

log_il() {
    echo -e "${IL}$1${NC}"
    logger --tag $LogCategory -p user.info "$1"
}


log_warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
    logger --tag $LogCategory -p user.warning "[WARNING] $1"
}
log_error() {
    echo -e "${RED}[ERROR] $1${NC}"
    logger --tag $LogCategory -p user.error "[ERROR] $1"
}
debug() { : log_info "INFO: $@" >&2; }
error() { log_info "ERROR: $@" >&2; }
fatal() { log_error "$@"; exit 1; }
try() { "$@" || fatal "'$@' failed"; }
usage_fatal() { usage >&2; pecho "" >&2; fatal "$@"; }


log_il "\ncreate_backup.sh - creating a backup of my scripts\n"


# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    log_error "Please run as root"
    exit 1
fi

# Directory to store backups
backup_dir="/srv/backup/scripts-config"

# Create backup directory if it doesn't exist
if [ ! -d "$backup_dir" ]; then
    mkdir -p "$backup_dir"
fi

# Set the output filename for the backup tarball
backup_file="$backup_dir/backup_$(date +%Y%m%d).tar.gz"

# List of files and directories to include in the package
files_to_backup=(
    "/root/.ssh"
    "/etc/samba/smb.conf"
    "/etc/initramfs-tools/initramfs.conf"
    "/etc/initramfs-tools/root/.ssh"
    "/home/gp/.ssh"
    "/home/gp/scripts"
    "/srv/secrets"
    "/srv/scripts"
    "/srv/vpn/config"
    "/srv/vpn/scripts"
    "/home/storage/Configs/QBittorrentVPN/openvpn"
    "/home/storage/Configs/QBittorrentVPN/qBittorrent/config"
    "/etc/dropbear"
)

# Excluded directories
excluded_dirs=(
    "--exclude=/srv/vpn/config/vpn-configs-contrib"
    "--exclude=/srv/vpn/config/transmission-home"
)

# Create the tarball, with verbose output (-v), preserving file permissions (-p), and excluding specified directories
log_info "Creating backup package..."
tar -cpvzf $backup_file "${excluded_dirs[@]}" --absolute-names "${files_to_backup[@]}"

# Check if the tarball was created successfully
if [ $? -eq 0 ]; then
    log_info "Backup successfully created at: $backup_file"
else
    log_error "An error occurred while creating the backup."
    exit 1
fi

# Step to delete backups older than 10 days (log rotation)
log_info "Performing log rotation, deleting backups older than 10 days..."
find $backup_dir -type f -name "backup_*.tar.gz" -mtime +10 -exec rm -f {} \;

log_info "Backup creation and log rotation complete."
