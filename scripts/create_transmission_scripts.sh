#!/bin/bash

# Define the content to be written
content='#!/bin/bash

pecho() { echo -e "$1"; }
log() { pecho "$1"; }
debug() { log "DEBUG: $1" >&2; logger --tag transmissionvpn -p user.debug "$1" ; }
info() { log "INFO: $1" >&2; logger --tag transmissionvpn -p user.info "$1" ; }
error() { log "ERROR: $1" >&2; logger --tag transmissionvpn -p user.error "$1" ; }
fatal() { error "$1"; exit 1; }
try() { "$1" || fatal "\x27$1\x27 failed"; }
usage_fatal() { usage >&2; pecho "" >&2; fatal "$1"; }
'

# List of files
files=(
    "/srv/vpn/scripts/openvpn-pre-start.sh"
    "/srv/vpnscripts/openvpn-post-config.sh"
    "/srv/vpn/scripts/transmission-pre-start.sh"
    "/srv/vpn/scripts/transmission-post-start.sh"
    "/srv/vpn/scripts/routes-post-start.sh"
    "/srv/vpn/scripts/transmission-pre-stop.sh"
    "/srv/vpn/scripts/transmission-post-stop.sh"
)

# Iterate over the list of files and write content to each
for file in "${files[@]}"; do
    # Append the content and then append the info function with the filename
    echo -e "$content\ninfo \"$(basename "$file")\"" > "$file"
    echo "Written to $file"
done

echo "Set appropriate permissions"

chmod +x /srv/vpn/scripts/*.sh
