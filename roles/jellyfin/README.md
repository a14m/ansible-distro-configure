# Ansible Role: jellyfin

Installs [Jellyfin](https://jellyfin.org/) (media server) from its apt repository, so it updates with the system,
and adds its web UI vhost.

## Role Variables

- `jellyfin_local_networks` subnets treated as local (required), e.g. `192.168.0.0/24`. Remote access is off, so
  clients from elsewhere are refused; reach it through the proxy (LAN or Tailscale).
- `jellyfin_known_proxies` reverse proxy IPs whose `X-Forwarded-For` is trusted (default: `[]`).
- `jellyfin_hostname` proxy vhost (e.g. `streaming.internal`); unset skips it.
- `jellyfin_port` HTTP port on `network_ipv4_address` (default: `8096`).

## Notes

- `network.xml` keys set by the role: LAN bind, port, local subnets, known proxies, remote access, IPv6, discovery and
  UPnP off. Everything else (admin user, libraries, users) is set up in the first-run wizard and the web UI.
- Libraries only need read access: give the media folders world-read (e.g. `UMask=0002` on the writers) or mount
  them read-only.
