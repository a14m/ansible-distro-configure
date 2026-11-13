# Ansible Role: sonarr

Installs [Sonarr](https://sonarr.tv/) (TV shows) through the shared `servarr` app tasks (own user and service, self-
updating, login created on the first visit), and manages its root folders and qBittorrent download client through
the API.

## Role Variables

- `sonarr_api_key` API key (required), e.g. `openssl rand -hex 16`.
- `sonarr_qbittorrent` qBittorrent download client `{host, port, username, password}` (required); category `tv`.
- `sonarr_root_folders` library folders, created and kept as root folders (default: `[]`), e.g. `/data/media/tv`.
- `sonarr_prowlarr` `{url, api_key, sync_categories}` to register as an application in Prowlarr, which then
  syncs its indexers here (optional).
- `sonarr_hostname` proxy vhost (e.g. `shows.internal`); unset skips it.
- `sonarr_allowed_hosts` hostnames/IPs accepted in the `Host` header (default: `[]`, allows all).
- `sonarr_group` / `sonarr_group_id` primary group and optional GID, e.g. a shared `media` group (default: `sonarr`).
- `sonarr_port` web UI port (default: `8989`).

Root folders and download clients not listed are removed from Sonarr (root folders never from disk).
