# Ansible Role: radarr

Installs [Radarr](https://radarr.video/) (movies) through the shared `servarr` app tasks (own user and service,
self-updating, login created on the first visit), and manages its root folders and qBittorrent download client
through the API.

## Role Variables

- `radarr_api_key` API key (required), e.g. `openssl rand -hex 16`.
- `radarr_qbittorrent` qBittorrent download client `{host, port, username, password}` (required); category `movies`.
- `radarr_root_folders` library folders, created and kept as root folders (default: `[]`), e.g. `/data/media/movies`.
- `radarr_prowlarr` `{url, api_key, sync_categories}` to register as an application in Prowlarr, which then
  syncs its indexers here (optional).
- `radarr_hostname` proxy vhost (e.g. `movies.internal`); unset skips it.
- `radarr_allowed_hosts` hostnames/IPs accepted in the `Host` header (default: `[]`, allows all).
- `radarr_group` / `radarr_group_id` primary group and optional GID, e.g. a shared `media` group (default: `radarr`).
- `radarr_port` web UI port (default: `7878`).

Root folders and download clients not listed are removed from Radarr (root folders never from disk).
