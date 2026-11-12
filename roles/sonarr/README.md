# Ansible Role: sonarr

Installs [Sonarr](https://sonarr.tv/) (TV series manager) as the `sonarr` systemd service (its own `sonarr` user,
app in `/opt/Sonarr`, data in `/var/lib/sonarr`), and adds its web UI vhost.

## Role Variables

- `sonarr_api_key` API key for other apps (required), e.g. `openssl rand -hex 16`.
- `sonarr_hostname` FQDN / vhost `server_name` (e.g. `shows.internal`). Undefined skips the proxy vhost.
- `sonarr_allowed_hosts` hostnames/IPs accepted in the `Host` header (default: `[]`, allows all).
- `sonarr_group` / `sonarr_group_id` primary group (and optional GID) of the sonarr user; share it with the download
  client so imports can hardlink (default: `sonarr`). Files are group-writable (`UMask=0002`).
- `sonarr_root_folders` library folders to create (owned by sonarr and its group) and add in Sonarr (default: `[]`).
- `sonarr_qbittorrent` qBittorrent download client `{host, port, username, password}`; the only download
  client kept (required).
- `sonarr_port` web UI port on `network_ipv4_address` (default: `8989`).

## Notes

- Installed once from the latest v4 release; after that Sonarr updates itself.
- Login is required, also on the LAN; the user is created on the first visit to the web UI.
- Only the settings in the role are managed in `config.xml`; everything else stays editable in the web UI.
- The role is the source of truth for root folders and download clients: listed ones are added or updated through
  the API, others are removed (root folders only from the app, never their files).
