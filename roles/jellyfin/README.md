# Ansible Role: jellyfin

Installs [Jellyfin](https://jellyfin.org/) (media server) from its apt repository, so it updates with the system,
and adds its web UI vhost.

## Role Variables

- `jellyfin_local_networks` subnets treated as local (required), e.g. `192.168.0.0/24`. Remote access is off, so
  clients from elsewhere are refused; reach it through the proxy (LAN or Tailscale).
- `jellyfin_known_proxies` reverse proxy IPs whose `X-Forwarded-For` is trusted (default: `[]`).
- `jellyfin_users` `{name, password, admin}` created at first-time setup (required); the first with `admin: true`
  is the setup admin the role logs in as, so the list needs at least one admin.
- `jellyfin_libraries` `{name, type (movies/tvshows), path}` created at first-time setup (default: `[]`).
- `jellyfin_server_name`, `jellyfin_ui_culture`, `jellyfin_metadata_language`, `jellyfin_metadata_country` first-time
  setup defaults (default: hostname, `en-US`, `en`, `US`).
- `jellyfin_hostname` proxy vhost (e.g. `streaming.internal`); unset skips it.
- `jellyfin_port` HTTP port on `network_ipv4_address` (default: `8096`).

## Notes

- `network.xml` keys set by the role (it creates the file, as Jellyfin only writes it on a save): LAN bind, port,
  local subnets, known proxies, remote access, IPv6, discovery and UPnP off.
- First-time setup runs through the wizard's API (server name, languages, users, libraries with nothing saved into
  the media folders) only while Jellyfin isn't set up; afterwards, users and libraries are managed in the web UI.
- Libraries only need read access: give the media folders world-read (e.g. `UMask=0002` on the writers) or mount
  them read-only.
