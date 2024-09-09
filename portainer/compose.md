
This is a file with the [compose yml file format](https://docs.docker.com/compose/compose-application-model/).

With Docker Compose you use a YAML configuration file, known as the Compose file, to configure your application’s services, and then you create and start all the services from your configuration with the Compose CLI, in my case Portainer.

It has 10 sections, each representing a service:

- plex
- jackett
- organizr
- qbittorrentvpn
- radarr
- sabnzbd
- sonarr
- grafana
- prometheus
- node-exporter

What's really important to configure is the ```volumes``` section for each service. 
On the *left* of **colon** ```:``` is the real path on the server, on the *right* is the **virtual** path in the image. So you 
need to make sure that all the paths on the left, for each service exists, has the right permissions and contains the files required by each service.

```sh
/home/storage/Configs
/home/storage/Configs/Radarr
/home/storage/Configs/Jackett
/home/storage/Configs/Organizr
/home/storage/Configs/QBittorrentVPN
/home/storage/Configs/Sabnzbd
/home/storage/Configs/Sonarr
/home/storage/Torrents
/home/storage/Torrents/Incomplete
/home/storage/TV
/home/storage/Movies
/home/storage/Downloads
/home/storage/Downloads/Incomplete
/etc/timezone
/home/storage/Configs/Prometheus/prometheus.yml
```

Here's my file: 


```yml
version: "2.1"
services:
  plex:
    image: lscr.io/linuxserver/plex
    container_name: plex
    network_mode: host
    environment:
      - PUID=1000
      - PGID=1000
      - VERSION=docker
      - PLEX_CLAIM=
    volumes:
      - /home/storage/Configs:/config
      - /home/storage/TV:/tv
      - /home/storage/Movies:/movies
    restart: unless-stopped
    
  jackett:
    image: linuxserver/jackett
    container_name: jackett
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/New_York
    volumes:
      - /home/storage/Configs/Jackett:/config
      - /home/storage/Torrents:/downloads
    ports:
      - 9117:9117
    restart: unless-stopped
    
  organizr:
    container_name: organizr
    hostname: organizr
    image: organizr/organizr
    restart: unless-stopped
    ports:
        - 90:80
    volumes:
        - /home/storage/Configs/Organizr:/config
    environment:
        - fpm=true #true or false | using true will provide better performance
        - branch=v2-master #v2-master or #v2-develop
        - PUID=1000
        - PGID=1000
        - TZ=America/New_York
    
  qbittorrentvpn:
    image: markusmcnugen/qbittorrentvpn
    container_name: qbittorrentvpn
    privileged: true   
    environment:
      - VPN_USERNAME= # SET YOU VPN USERNAME HERE
      - VPN_PASSWORD= # SET VPN PASSWORD HERE
      - PUID=1000
      - PGID=1000
      - WEBUI_PORT_ENV=8080
      - INCOMING_PORT_ENV=8999
      - VPN_ENABLED=yes
      - CREATE_TUN_DEVICE=true
      - LAN_NETWORK=10.0.0.0/24         # adjust this to YOUR network settings
      - NAME_SERVERS=1.1.1.1,1.0.0.1    # you can use whatever DNS provider you want
    ports:
      - 8080:8080
      - 8999:8999
      - 8999:8999/udp
    volumes:
      - /home/storage/Configs/QBittorrentVPN:/config
      - /home/storage/Torrents/Complete:/Complete
      - /home/storage/Torrents/Incomplete:/Incomplete
      - /home/storage/Torrents/TorrentFiles:/TorrentFiles
      - /home/storage/Torrents/TorrentFiles_Incomplete:/TorrentFiles_Incomplete
      - /etc/timezone:/etc/timezone:ro #This is for TimeZone
    restart: unless-stopped
    
  radarr:
    image: linuxserver/radarr
    container_name: radarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/New_York
      - UMASK_SET=022 
    volumes:
      - /home/storage/Configs/Radarr:/config
      - /home/storage/Downloads:/downloads
      - /home/storage/Movies:/Movies
    ports:
      - 7878:7878
    restart: unless-stopped
    
  sabnzbd:
    image: ghcr.io/linuxserver/sabnzbd
    container_name: sabnzbd
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/New_York
    volumes:
      - /home/storage/Configs/Sabnzbd:/config
      - /home/storage/Downloads:/downloads
      - /home/storage/Downloads/Incomplete:/incomplete-downloads #optional
    ports:
      - 8181:8080
      - 9191:9090
    restart: unless-stopped
    
  sonarr:
    image: linuxserver/sonarr
    container_name: sonarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/New-York
      - UMASK_SET=022
    volumes:
      - /home/storage/Configs/Sonarr:/config
      - /home/storage/Downloads:/Downloads
      - /home/storage/TV:/TV
    ports:
      - 8989:8989
    restart: unless-stopped

  node-exporter:
      image: quay.io/prometheus/node-exporter:latest
      container_name: node-exporter
      network_mode: host
      environment:
        - PUID=1000
        - PGID=1000
        - TZ=America/New_York
        - UMASK_SET=022
      volumes:
        - /:/host:ro,rslave
      ports:
        - 9100:9090
      restart: unless-stopped
    
  grafana:
    image: grafana/grafana
    container_name: grafana
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/New_York
      - UMASK_SET=022
    ports:
      - 3000:3000
    restart: unless-stopped

  prometheus:
      image: prom/prometheus
      container_name: prometheus
      environment:
        - PUID=999
        - PGID=988
        - TZ=America/New_York
        - UMASK_SET=022
      volumes:
        - /home/storage/Configs/Prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      ports:
        - 9292:9090
      restart: unless-stopped
```