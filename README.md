# My Mini Media Server

I’ve been meaning to set up an Ubuntu server to run a media server, Jenkins and Yocto as a personal project for some time. These notes are related to the media server aspect. 
I'll be using docker and notes may be usefull in the future. Using docker, setting up multiple services on a linux server is easy and convenient, so this is my choice for my media server, which will be use to search for movies, games music and other media files,  

***MEDIA SERVER*** : The server setup below enmables you to automatically handle requests with **Sonarr** or **Radarr**, download them via usenet or torrent, then load them into **Plex** for viewing.

On of the things I love about this build is that we can run a VPN through the torrent container only (**QBbittorrentVPN**). We maintain our anonymity when using public torrent trackers as well as maintain normal download and upload speeds outside of the container.

## Services

My mini server runs Ubuntu This mini server runs multiple services, what we call a **stack**:

- [Plex](#Plex)
- [SABnzbd](#SABnzbd)
- [Sonarr](#Sonarr)
- [Radarr](#Radarr)
- [Organizr](#Organizr)
- [Jackett](#Jackett)
- [Prometheus](#Prometheus)
- [Node-Exporter](#Node)
- [QBittorrentVPN](#QBittorrentVPN)
- [Torrent Tracker](#TorrentTracker)

## Important Informations

- [Ports](#Ports)


## PLEX <a name="Plex"></a>

[Plex](https://www.plex.tv) is a popular media server platform that allows users to organize, stream, and access their personal media content (like movies, TV shows, music, photos, and home videos) on various devices. It provides a centralized way to manage media libraries and stream content both locally and remotely to a wide range of devices.

Key features of Plex include:

1. **Media Server**: Plex allows users to set up a personal media server on their computer, NAS (Network Attached Storage), or a dedicated server. The media server organizes and catalogs the user's media files, providing rich metadata (such as cover art, summaries, actor information, and more) for a clean, easy-to-navigate interface.

2. **Streaming on Multiple Devices**: Plex supports streaming to a wide variety of devices, including smart TVs, smartphones (iOS and Android), tablets, streaming boxes (like Roku, Apple TV, Amazon Fire TV), gaming consoles, and web browsers. This makes it easy to access your media library from anywhere, as long as the server is running.

3. **Remote Access**: One of Plex’s standout features is the ability to stream your media remotely. You can access your content from outside your home network, allowing you to watch your movies, TV shows, or listen to your music while traveling or away from home.

4. **Live TV and DVR**: Plex offers support for live TV and DVR functionality when paired with a compatible tuner and antenna. This allows users to watch and record live over-the-air TV broadcasts, which can be stored and managed like any other media content.

5. **Plex Apps and Channels**: Plex offers various "channels" (which are similar to apps) that allow users to access additional content, such as web shows, podcasts, news, and streaming services. Plex also integrates with free ad-supported movies and TV shows, providing users with more viewing options.

6. **Shared Libraries**: Plex users can share their media libraries with friends or family, giving them access to your content while keeping separate viewing histories and watch lists. Plex also supports multi-user accounts with individual watch lists and recommendations.

7. **Music and Photos**: In addition to video, Plex organizes and streams music files, complete with metadata like album art and artist information. It also handles photo collections, allowing you to view and organize your photo library on all devices.

It is a versatile and comprehensive media management solution that allows users to centralize their personal media libraries and stream content across devices, both locally and remotely. With its rich features like live TV, DVR, metadata management, and support for multiple device types, Plex is widely used for home entertainment systems and is the base for me wanting to get a media server, it is fun to use and looks super profesh.


## SABnzbd  <a name="SABnzbd"></a>

[SABnzbd](https://sabnzbd.org/wiki/) is a program to download binary files from Usenet servers. Many people upload all sorts of interesting material to Usenet and you need a special program to get this material with the least effort. It is a free and open-source Usenet binary newsreader designed to automate the process of downloading, verifying, repairing, and unpacking files from Usenet. In short, SABnzbd is a powerful tool for automating the download and management of content from Usenet via NZB files, and it simplifies the process by handling downloading, verification, and file unpacking.


## Sonarr <a name="Sonarr"></a>


[Sonarr](https://sonarr.tv/) is an open-source personal video recorder (PVR) software designed to help users automate the process of downloading and managing TV shows. It works by monitoring specified TV shows, checking for new episodes, and automatically downloading them from Usenet or torrent clients. 


## Radarr <a name="Radarr"></a>


[Radarr](https://radarr.video) is an open-source, movie-focused companion to Sonarr, designed to automate the process of downloading and managing movies. It works similarly to Sonarr but is specifically tailored for managing a movie collection. Radarr helps users keep track of desired movies, find high-quality versions, and download them automatically from Usenet or torrent services. 


## Organizr <a name="Organizr"></a>

[Organizr](https://organizr.app) is a web-based tool designed to consolidate access to various web applications into a single, unified dashboard. It's particularly popular in the media server and home server communities, where users run multiple self-hosted services like Sonarr, Radarr, SABnzbd, Plex, and others. Organizr simplifies the process of managing and accessing these services by providing a centralized interface.


## Grafana <a name="Grafana"></a>

[Grafana](https://grafana.com) is an open-source analytics and monitoring platform used to visualize and analyze metrics from various data sources in real-time. It's widely used in industries like IT operations, DevOps, data science, and software development to monitor system performance, track business metrics, and analyze data trends. Grafana is known for its beautiful and flexible dashboards, which allow users to visualize metrics using various types of charts, graphs, heatmaps, and tables. These dashboards can be customized and arranged to display real-time data from different sources. It is widely used for infrastructure monitoring, application performance monitoring (APM), and security monitoring. Its dashboards provide real-time insights into system performance, helping teams proactively address issues. Also , Grafana includes built-in alerting functionality, allowing users to set up thresholds and get notifications when certain metrics exceed predefined limits. Alerts can be sent via email, Slack, PagerDuty, or other communication platforms.


## Jackett <a name="Jackett"></a>

[Jackett](https://github.com/Jackett/Jackett) is an open-source tool that acts as a proxy between torrent indexers and applications like Sonarr, Radarr, and other media automation tools. Its primary purpose is to enable these applications to search for and download content from a wide variety of public and private torrent trackers. Jackett simplifies the process of searching for torrents across multiple sources and integrates them seamlessly into your media management workflows.


## Prometheus <a name="Prometheus"></a>

[Prometheus](https://prometheus.io) is an open-source monitoring and alerting toolkit designed for collecting and analyzing time-series data, primarily from software systems and infrastructure. It is widely used in DevOps and cloud-native environments to monitor applications, services, and server performance metrics.


## Node Exporter <a name="Node"></a>

[Node Exporter](https://github.com/prometheus/node_exporter) is an open-source tool designed to expose hardware and OS-level metrics from Linux-based systems (and other operating systems) for Prometheus. It is one of the most widely used exporters in the Prometheus ecosystem, helping users monitor system metrics like CPU usage, memory consumption, disk I/O, network statistics, and more. It enables Prometheus to scrape and collect these metrics for analysis, alerting, and visualization.

### Key Features of Node Exporter:

1. **System Metrics Exposure**: Node Exporter exposes a wide range of operating system and hardware metrics, including:
   - **CPU usage** (idle, system, user, and iowait)
   - **Memory usage** (free, used, cached, and buffers)
   - **Disk I/O** (read/write operations, usage, and errors)
   - **File system statistics** (space usage, inodes)
   - **Network traffic** (sent, received bytes, packets, errors, and dropped packets)
   - **Load average** and **system uptime**
   - **Temperature sensors** (if supported)

2. **Prometheus Integration**: Node Exporter works seamlessly with Prometheus, making it easy to scrape system-level metrics at regular intervals. The metrics are exposed via a simple HTTP endpoint (`/metrics`), which Prometheus can collect.

3. **Lightweight and Minimalist**: Node Exporter is designed to have a minimal impact on system performance. It runs as a lightweight daemon that exports metrics without using too many system resources.


## QBittorrentVPN <a name="QBittorrentVPN"></a>

Finally there's [QBittorrentVPN](https://hub.docker.com/r/markusmcnugen/qbittorrentvpn/)

`qBittorrentVPN` is a Docker container or setup that combines the popular BitTorrent client **qBittorrent** with a **VPN** (Virtual Private Network) to ensure secure and private torrenting. It allows users to run qBittorrent behind a VPN, so all torrenting traffic is encrypted and routed through the VPN tunnel, preventing the user's actual IP address from being exposed to peers in the BitTorrent network or to their Internet Service Provider (ISP).


## Torrent Tracker <a name="TorrentTracker"></a>

Last but not least, [Torrent Tracker](https://github.com/arsscriptum/torrents-tracker)

This is an application to query different torrents indexers (i.e. PirateBay) to find differents media files. There's plently of different pirate bay client programs out there, but **this one is mine**. A Django/Flex Application, configured as a docker-compose image. I basically made it with a couple of requirements in mind:

1. **Docker-Compose Image**: So I can run the service along with other services on my media server, all managed by Portainer
2. **Integrated VPN**: so all the requests done to the torrents indexers is encrypted and routed through the VPN tunnel, preventing the user's actual IP address from being exposed
3. **QTorrentVPN Integration**: So that when I find torrents to download, they are added automatically to the download queue in QBittorrent using the rest api, no more copy/pasting links left and right



## Ports List <a name="Ports"></a>

|   application   | host port | container port |
|:---------------:|:---------:|:--------------:|
| portainer       | 9443      | 9443           |
| plex            | 3000      | 3000           |
| prometheus      | 9292      | 9090           |
| node-exporter   | 9100      | 9090           |
| sonarr          | 8989      | 8989           |
| sabnzbd         | 8181      | 8080           |
| sabnzbd         | 9191      | 9090           |
| radarr          | 7878      | 7878           |
| qbittorrentvpn  | 8080      | 8080           |
| qbittorrentvpn  | 8999      | 8999           |
| qbittorrentvpn  | 8999      | 8999/udp       |
| organizr        | 90        | 80             |
| jackett         | 9117      | 9117           |
| torrents-search | 7070      | 7070           |