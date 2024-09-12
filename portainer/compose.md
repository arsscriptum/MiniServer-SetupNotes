
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
/home/storage/TorrentFiles
/home/storage/Incomplete
/home/storage/TV
/home/storage/Movies
/home/storage/Downloads
/home/storage/Downloads/Incomplete
/etc/timezone
/home/storage/Configs/Prometheus/prometheus.yml
```

## Media Center Docker Compose File

Here's my [file](mediacenter.yml)



## PLEX SERVER - Claiming

The `PLEX_CLAIM` variable is used in the Plex Docker image to automatically claim your Plex Media Server to your Plex account when the server is first set up. This is useful when deploying Plex in a containerized environment, especially in headless or automated setups, where you may not have immediate access to the web UI for claiming the server manually.

### Purpose:
When you set up Plex Media Server for the first time, Plex requires you to claim the server to link it to your Plex account. This usually involves logging into your Plex account through the server's web UI. By using the `PLEX_CLAIM` environment variable, you can bypass this manual process by providing a special claim token when the container is started, automatically linking the server to your account.

### How to Use It:
1. **Obtain a Claim Token**:
   - Go to [https://plex.tv/claim](https://plex.tv/claim) and log into your Plex account.
   - You'll receive a claim token in the format `claim-XXXXXXXXX`.

2. **Set the `PLEX_CLAIM` Environment Variable**:
   When you run the Plex Docker container, pass the claim token as an environment variable like this:

   ```bash
   docker run -d \
     -e PLEX_CLAIM="claim-XXXXXXXXX" \
     -e PLEX_UID=1000 \
     -e PLEX_GID=1000 \
     -v /path/to/config:/config \
     -v /path/to/media:/media \
     --name plex \
     --network host \
     plexinc/pms-docker
   ```

   Replace `"claim-XXXXXXXXX"` with the claim token you obtained.

### What Happens:
- The claim token allows Plex Media Server to authenticate with your Plex account and automatically register the server under your account without needing to open the web interface.
- Once the server is successfully claimed, the `PLEX_CLAIM` variable is no longer needed for future container starts, as the server remains linked to your Plex account.

### Important Notes:
- Claim tokens expire after about 4 minutes, so you should generate the token just before running the Docker container.
- The `PLEX_CLAIM` variable is used only during the initial setup. After that, you won't need to provide the token again unless you reinstall or reset the server configuration.




## Ports

In a Portainer stack YAML file, the **`ports`** section is used to define how Docker containers expose their internal ports to the host system. The format `ports: - "host_port:container_port"` specifies which ports on the host should be mapped to which ports on the container. Here's what each part of the `ports` section means:

### Format:
```yaml
ports:
  - "host_port:container_port"
```

- **`host_port`**: The port on the host machine that will be forwarded to the container.
- **`container_port`**: The port inside the container that will be exposed to the host.

### Example:
```yaml
ports:
  - "8080:80"
```

This means that:

- Port `8080` on the **host** will be forwarded to port `80` inside the **container**.
- When you access `http://localhost:8080` on the host, the traffic is redirected to port `80` inside the container, which is typically the default HTTP port.

### Why are there ports before and after the colon?

- The **left side** (before the colon) refers to the port on the **host** machine, which external clients will connect to.
- The **right side** (after the colon) refers to the port inside the **container** where the service is running.

This allows for flexibility. For example, if a containerized web application listens on port `80` inside the container, you could expose it on any port on the host (like `8080`, `3000`, or any other available port).

## Ports List

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