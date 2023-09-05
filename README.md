# alpine-tor

Tor built and run on [Alpine Linux](https://hub.docker.com/_/alpine).  
Set up a hidden service, exit relay or a socks proxy by deploying a container and editing the torrc-file directly.


## Application Setup

A valid torrc-file needs to be available inside the container at `/home/tor/torrc`, see torrc.example or [the official sample](https://github.com/torproject/tor/blob/main/src/config/torrc.sample.in) for more info.  
The whole directory `/home/tor` should be mounted to a persistent volume or bind-mount.  
The container is run by user id 99, and mounted directory `/path/to/config:/home/tor` with its files will have to have the same owner id.  
```bash
sudo chown -R 99 /path/to/config
```

## Usage

Some snippets to get you started.

### docker-compose

```yaml
services:
  tor:
    image: ghcr.io/lanjelin/alpine-tor:latest
    container_name: tor
    environment:
      - TZ=Europe/Berlin
    ports:
      - "9050:9050" #socks
      - "9051:9051" #control port
    volumes:
      - /path/to/config:/home/tor
    restart: unless-stopped
```

### docker cli

```bash
docker run -d \
  --name=tor \
  -e TZ=Europe/Berlin \
  -p 9050:9050 \
  -v /path/to/config:/home/tor \
  --restart unless-stopped \
  ghcr.io/lanjelin/alpine-tor:latest
```
