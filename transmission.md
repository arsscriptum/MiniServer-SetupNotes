# notes on docker-transmission-openvpn 

OpenVPN is a robust and highly flexible VPN daemon. See [Reference manual](https://openvpn.net/community-resources/reference-manual-for-openvpn-2-0/) for OpenVPN


## Let other containers use the VPN

To let other containers use VPN you have to add them to the same Service network as your VPN container runs, you can do this by adding network_mode: "service:transmission-openvpn". 

Additionally, you have to set **depends_on** to the transmission-openvpn service to let docker-compose know that your new container should start after transmission-openvpn is up and running. As the final step, you can add **healthcheck** to your service.

```bash
version: '3.3'
services:
 smission-openvpn:
        cap_add:
            - NET_ADMIN
        volumes:
            - '/your/storage/path/:/data'
        environment:
            - OPENVPN_PROVIDER=PIA
            - OPENVPN_CONFIG=france
            - OPENVPN_USERNAME=user
            - OPENVPN_PASSWORD=pass
            - LOCAL_NETWORK=192.168.0.0/16
            - OPENVPN_OPTS=--inactive 3600 --ping 10 --ping-exit 60
        logging:
            driver: json-file
            options:
                max-size: 10m
        ports:
            - '9091:9091'
            - '9117:9117'  # This is Jackett Port – managed by VPN Service Network
        image: haugene/transmission-openvpn
    jackett:
        image: lscr.io/linuxserver/jackett:latest
        container_name: jackett
        environment:
            - PUID=1000
            - PGID=1000
            - TZ=Europe/London
            - AUTO_UPDATE=true #optional
            - RUN_OPTS=<run options here> #optional
        volumes:
            - <path to data>:/config
            - <path to blackhole>:/downloads
        # You have to comment ports, they should be managed in transmission-openvpn section now.
#       ports:
#           - 9117:9117
        restart: unless-stopped
        network_mode: "service:transmission-openvpn" # Add to the transmission-openvpn Container Network
        depends_on:
            - transmission-openvpn # Set dependency on transmission-openvpn Container
        healthcheck: # Here you will check if transmission is reachable from the Jackett container via localhost
            test: curl -f http://localhost:9091 || exit 1
            # Use this test if you protect your transmission with a username and password 
            # comment the test above and un-comment the line below.
            #test: curl -f http://${TRANSMISSION_RPC_USERNAME}:${TRANSMISSION_RPC_PASSWORD}@localhost:9091 || exit 1
            interval: 5m00s
            timeout: 10s
            retries: 2
```

## Check if the container is using VPN

After the container starts, simply call curl under it to check your IP address, for example with Jackett you should see your VPN IP address as output:

```bash
docker exec jackett curl -s https://api.ipify.org
```

You can also check that Jackett is attached to the VPN network by pinging it from the transmission-openvpn Container localhost:

```bash
docker exec transmission-vpn curl -Is http://localhost:9117
HTTP/1.1 301 Moved Permanently
Date: Tue, 17 May 2022 19:58:19 GMT
Server: Kestrel
Location: /UI/Dashboard
```

### Dante

Let's add Dante socks5 proxy to the transmission-openvpn network based on the example from Running the container:


```bash
version: '3.3'
services:
 smission-openvpn:
        cap_add:
            - NET_ADMIN
        volumes:
            - '/your/storage/path/:/data'
        environment:
            - OPENVPN_PROVIDER=PIA
            - OPENVPN_CONFIG=france
            - OPENVPN_USERNAME=user
            - OPENVPN_PASSWORD=pass
            - LOCAL_NETWORK=192.168.0.0/16
        logging:
            driver: json-file
            options:
                max-size: 10m
        ports:
            - '9091:9091'
            - '1080:1080'  # This is Dante Socks5 Port – managed by VPN Service Network
        restart: unless-stopped
        image: haugene/transmission-openvpn

    socks5-proxy:
        image: wernight/dante
        restart: unless-stopped
        network_mode: service:transmission-openvpn
        depends_on:
            - transmission-openvpn
        command:
            - /bin/sh
            - -c
            - |
                echo "Waiting for VPN to connect . . ."
                while ! ip link show tun0 >/dev/null 2>&1 || ! ip link show tun0 | grep -q "UP"; do sleep 1; done
                echo "VPN connected. Starting proxy service . . ."
                sed -i 's/^\(external:\).*/\1 tun0/' /etc/sockd.conf
                sockd
```



```bash

# OpenVPN will exit if ping fails over a period of time which will stop the container and then the Docker daemon will restart it (restart=always)
OPENVPN_OPTS=--inactive 3600 --ping 10 --ping-exit 60




# To log to stdout instead set the environment variable LOG_TO_STDOUT to true.
LOG_TO_STDOUT=true

# To use your host DNS rather than what is provided by OpenVPN, set PEER_DNS=false. This allows for potential DNS leakage.
PEER_DNS=false


PUID=1000
PGID=1000


DEBUG=true
LOG_TO_STDOUT=true
HEALTH_CHECK_HOST="google.com"
PEER_DNS=true
ENABLE_UFW=true
UFW_ALLOW_GW_NET=true
UFW_EXTRA_PORTS=5299,9091,51413
UFW_DISABLE_IPTABLES_REJECT=true
DROP_DEFAULT_ROUTE=true



# By default, Transmission will log to a file in TRANSMISSION_HOME/transmission.log
TRANSMISSION_HOME/transmission.log



HEALTH_CHECK_HOST=google.com

# TRANSMISSION_WEB_UI=combustion
# TRANSMISSION_WEB_UI=kettu
# TRANSMISSION_WEB_UI=transmission-web-control
# TRANSMISSION_WEB_UI=flood-for-transmission
# TRANSMISSION_WEB_UI=shift
# TRANSMISSION_WEB_UI=transmissionic


ENABLE_UFW
UFW_ALLOW_GW_NET
UFW_EXTRA_PORTS
UFW_DISABLE_IPTABLES_REJECT




        healthcheck: # Here you will check if transmission is reachable from the Jackett container via localhost
            test: curl -f http://localhost:9091 || exit 1
            # Use this test if you protect your transmission with a username and password 
            # comment the test above and un-comment the line below.
            #test: curl -f http://${TRANSMISSION_RPC_USERNAME}:${TRANSMISSION_RPC_PASSWORD}@localhost:9091 || exit 1
            interval: 5m00s
            timeout: 10s
            retries: 2
```



-e "TRANSMISSION_SCRAPE_PAUSED_TORRENTS_ENABLED=false"            


        depends_on:
            - transmission-openvpn




## Restart the container if the connection is lost

If the VPN connection fails or the container for any other reason loses connectivity, you want it to recover from it. One way of doing this is to set the environment variable OPENVPN_OPTS=--inactive 3600 --ping 10 --ping-exit 60 and use the --restart=always flag when starting the container. This way OpenVPN will exit if ping fails over a period of time which will stop the container and then the Docker daemon will restart it.


```bash
OPENVPN`_OPTS=--inactive 3600 --ping 10 --ping-exit 60
```


TRANSMISSION_PEER_PORT_RANDOM_LOW=
TRANSMISSION_PEER_PORT_RANDOM_HIGH
TRANSMISSION_PEER_PORT_RANDOM_ON_START

 is enabled then it allows traffic to the range of peer ports defined by  and .




```bash
 version: '3'
services:
transmission:
image: haugene/transmission-openvpn:latest
container_name: transmission
networks:
- mesdockers
command: "dumb-init /etc/openvpn/start.sh"
cap_add:
- net_admin
devices:
- /dev/net/tun
environment:
OPENVPN_USERNAME: ""
OPENVPN_PASSWORD: ""
OPENVPN_PROVIDER: "NORDVPN"
GLOBAL_APPLY_PERMISSIONS: "true"
TRANSMISSION_HOME: "/data/transmission-home"
TRANSMISSION_RPC_PORT: "9091"
TRANSMISSION_BLOCKLIST_ENABLED=false
TRANSMISSION_BLOCKLIST_URL=http://www.example.com/blocklist
TRANSMISSION_INCOMPLETE_DIR_ENABLED=true
TRANSMISSION_DOWNLOAD_DIR=/Completed
TRANSMISSION_INCOMPLETE_DIR=/Incomplete
TRANSMISSION_WATCH_DIR: "/transmissiondl/Torrents"
CREATE_TUN_DEVICE: "true"
ENABLE_UFW: "true"
UFW_ALLOW_GW_NET: "true"
UFW_EXTRA_PORTS: "5299,9091,51413"
UFW_DISABLE_IPTABLES_REJECT: "true"
DROP_DEFAULT_ROUTE: "true"
PGID: "100"
PUID: "1030"
TZ: "Europe/Paris"
DROP_DEFAULT_ROUTE: "true"
WEBPROXY_ENABLED: "false"
WEBPROXY_PORT: "8888"
WEBPROXY_USERNAME: ""
WEBPROXY_PASSWORD: ""
LOG_TO_STDOUT: "false"
HEALTH_CHECK_HOST: "google.com"
TRANSMISSION_CACHE_SIZE_MB: "32"
TRANSMISSION_DOWNLOAD_QUEUE_SIZE: "8"
TRANSMISSION_IDLE_SEEDING_LIMIT: "120"
TRANSMISSION_IDLE_SEEDING_LIMIT_ENABLED: "true"

TRANSMISSION_LPD_ENABLED: "true"
TRANSMISSION_MAX_PEERS_GLOBAL: "500"
TRANSMISSION_PEER_LIMIT_GLOBAL: "500"
TRANSMISSION_PORT_FORWARDING_ENABLED: "true"
TRANSMISSION_PEER_PORT: "51413"
TRANSMISSION_RATIO_LIMIT_ENABLED: "true"
TRANSMISSION_RPC_AUTHENTICATION_REQUIRED: "true"
TRANSMISSION_RPC_PASSWORD: ""
TRANSMISSION_RPC_USERNAME: ""
TRANSMISSION_SCRIPT_TORRENT_DONE_ENABLED: "true"
TRANSMISSION_SCRIPT_TORRENT_DONE_FILENAME: "/config/Unrar.sh"
TRANSMISSION_TRASH_ORIGINAL_TORRENT_FILES: "true"
NORDVPN_COUNTRY: "Fr"
NORDVPN_CATEGORY: "legacy_p2p"
NORDVPN_PROTOCOL: "udp"
LOCAL_NETWORK: "192.168.1.0/24"
OPENVPN_OPTS: "--inactive 3600 --ping 10 --ping-exit 60"
ports:
- 9091:9091
- 51413:51413
- 5299:5299
volumes:
- /volume1/docker/transmission/resolv.conf:/etc/resolv.conf
- /volume1/Downloads/transmission:/transmissiondl
- /volume1/docker/transmission/config:/config
- /volume1/docker/transmission/data:/data
labels:
- com.centurylinklabs.watchtower.enable=true
restart: unless-stopped
```


```bash
OPENVPN_USERNAME=**None**
OPENVPN_PASSWORD=**None**
OPENVPN_PROVIDER=**None**
TRANSMISSION_ALT_SPEED_DOWN=50
TRANSMISSION_ALT_SPEED_ENABLED=false
TRANSMISSION_ALT_SPEED_TIME_BEGIN=540
TRANSMISSION_ALT_SPEED_TIME_DAY=127
TRANSMISSION_ALT_SPEED_TIME_ENABLED=false
TRANSMISSION_ALT_SPEED_TIME_END=1020
TRANSMISSION_ALT_SPEED_UP=50
TRANSMISSION_BIND_ADDRESS_IPV4=0.0.0.0
TRANSMISSION_BIND_ADDRESS_IPV6=::
TRANSMISSION_BLOCKLIST_ENABLED=false
TRANSMISSION_BLOCKLIST_URL=http://www.example.com/blocklist
TRANSMISSION_CACHE_SIZE_MB=4
TRANSMISSION_DHT_ENABLED=true
TRANSMISSION_INCOMPLETE_DIR_ENABLED=true
TRANSMISSION_DOWNLOAD_DIR=/data/completed
TRANSMISSION_INCOMPLETE_DIR=/data/incomplete
TRANSMISSION_DOWNLOAD_LIMIT=100
TRANSMISSION_DOWNLOAD_LIMIT_ENABLED=0
TRANSMISSION_DOWNLOAD_QUEUE_ENABLED=true
TRANSMISSION_DOWNLOAD_QUEUE_SIZE=5
TRANSMISSION_ENCRYPTION=1
TRANSMISSION_IDLE_SEEDING_LIMIT=30
TRANSMISSION_IDLE_SEEDING_LIMIT_ENABLED=false

TRANSMISSION_LPD_ENABLED=false
TRANSMISSION_MAX_PEERS_GLOBAL=200
TRANSMISSION_MESSAGE_LEVEL=2
TRANSMISSION_PEER_CONGESTION_ALGORITHM=
TRANSMISSION_PEER_ID_TTL_HOURS=6
TRANSMISSION_PEER_LIMIT_GLOBAL=200
TRANSMISSION_PEER_LIMIT_PER_TORRENT=50
TRANSMISSION_PEER_PORT=51413
TRANSMISSION_PEER_PORT_RANDOM_HIGH=65535
TRANSMISSION_PEER_PORT_RANDOM_LOW=49152
TRANSMISSION_PEER_PORT_RANDOM_ON_START=false
TRANSMISSION_PEER_SOCKET_TOS=default
TRANSMISSION_PEX_ENABLED=true
TRANSMISSION_PORT_FORWARDING_ENABLED=false
TRANSMISSION_PREALLOCATION=1
TRANSMISSION_PREFETCH_ENABLED=1
TRANSMISSION_QUEUE_STALLED_ENABLED=true
TRANSMISSION_QUEUE_STALLED_MINUTES=30
TRANSMISSION_RATIO_LIMIT=2
TRANSMISSION_RATIO_LIMIT_ENABLED=false
TRANSMISSION_RENAME_PARTIAL_FILES=true
TRANSMISSION_RPC_AUTHENTICATION_REQUIRED=false
TRANSMISSION_RPC_BIND_ADDRESS=0.0.0.0
TRANSMISSION_RPC_ENABLED=true
TRANSMISSION_RPC_HOST_WHITELIST=
TRANSMISSION_RPC_HOST_WHITELIST_ENABLED=true
TRANSMISSION_RPC_PASSWORD=password
TRANSMISSION_RPC_PORT=9091
TRANSMISSION_RPC_URL=/transmission/
TRANSMISSION_RPC_USERNAME=username
TRANSMISSION_RPC_WHITELIST=127.0.0.1
TRANSMISSION_RPC_WHITELIST_ENABLED=false
TRANSMISSION_SCRAPE_PAUSED_TORRENTS_ENABLED=true
TRANSMISSION_SCRIPT_TORRENT_DONE_ENABLED=false
TRANSMISSION_SCRIPT_TORRENT_DONE_FILENAME=
TRANSMISSION_SEED_QUEUE_ENABLED=false
TRANSMISSION_SEED_QUEUE_SIZE=10
TRANSMISSION_SPEED_LIMIT_DOWN=100
TRANSMISSION_SPEED_LIMIT_DOWN_ENABLED=false
TRANSMISSION_SPEED_LIMIT_UP=100
TRANSMISSION_SPEED_LIMIT_UP_ENABLED=false
TRANSMISSION_START_ADDED_TORRENTS=true
TRANSMISSION_TRASH_ORIGINAL_TORRENT_FILES=false
TRANSMISSION_UMASK=2
TRANSMISSION_UPLOAD_LIMIT=100
TRANSMISSION_UPLOAD_LIMIT_ENABLED=0
TRANSMISSION_UPLOAD_SLOTS_PER_TORRENT=14
TRANSMISSION_SEED_QUEUE_ENABLED=false
TRANSMISSION_SEED_QUEUE_SIZE=10
TRANSMISSION_SPEED_LIMIT_DOWN=100
TRANSMISSION_SPEED_LIMIT_DOWN_ENABLED=false
TRANSMISSION_SPEED_LIMIT_UP=100
TRANSMISSION_SPEED_LIMIT_UP_ENABLED=false
TRANSMISSION_START_ADDED_TORRENTS=true
TRANSMISSION_TRASH_ORIGINAL_TORRENT_FILES=false
TRANSMISSION_UMASK=2
TRANSMISSION_UPLOAD_LIMIT=100
TRANSMISSION_UPLOAD_LIMIT_ENABLED=0
TRANSMISSION_UPLOAD_SLOTS_PER_TORRENT=14
TRANSMISSION_UTP_ENABLED=true
TRANSMISSION_WATCH_DIR=/data/watch
TRANSMISSION_WATCH_DIR_ENABLED=true
TRANSMISSION_HOME=/data/transmission-home
ENABLE_UFW=false
TRANSMISSION_WEB_UI=
```