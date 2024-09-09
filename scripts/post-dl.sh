#!/bin/bash

#!/bin/bash

LogCategory=QBittorrentVPN

TORRENT_NAME=$1          # Torrent name
TORRENT_CATEGORY=$2      # Category
TORRENT_TAGS=$3          # Tags (separated by comma)
TORRENT_SAVE_PATH=$4     # Save path
TORRENT_SIZE=$5          # Torrent size (bytes)

DestinationPath=/home/storage/Movies

logger --tag $LogCategory -p user.info "post-download script called for $TORRENT_NAME"
logger --tag $LogCategory -p user.info "file location $TORRENT_SAVE_PATH"
logger --tag $LogCategory -p user.info "file category $TORRENT_CATEGORY"
logger --tag $LogCategory -p user.info "file tags $TORRENT_TAGS"
logger --tag $LogCategory -p user.info "file size $TORRENT_SIZE"

logger --tag $LogCategory -p user.info "would copy \"$TORRENT_SAVE_PATH\" to $DestinationPath"

#rsync -av --exclude='*.jpg' --exclude='*.jpeg' --exclude='*.png' --exclude='*.gif' "$1/" "$new_path/$(basename "$1")/"
# Remove empty directories
#find "$new_path/$(basename "$1")" -type d -empty -delete
#chown -R 99:100 "$new_path/$(basename "$1")"