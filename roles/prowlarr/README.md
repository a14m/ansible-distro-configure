# Ansible Role: prowlarr

Installs [Prowlarr](https://prowlarr.com/) (indexer manager for Sonarr/Radarr) as the `prowlarr` systemd service
(its own `prowlarr` user, app in `/opt/Prowlarr`, data in `/var/lib/prowlarr`), and adds its web UI vhost.

## Role Variables

- `prowlarr_api_key` API key for other apps (required), e.g. `openssl rand -hex 16`.
- `prowlarr_hostname` FQDN / vhost `server_name` (e.g. `search.internal`). Undefined skips the proxy vhost.
- `prowlarr_allowed_hosts` hostnames/IPs accepted in the `Host` header, e.g. the vhost name and the LAN IP other apps
  use (default: `[]`, allows all).
- `prowlarr_applications` apps to sync indexers to, `{name, implementation (Sonarr/Radarr), fields: {baseUrl, apiKey,
  syncCategories}}`; the role adds or updates these and removes others (default: `[]`).
- `prowlarr_port` web UI port on `network_ipv4_address` (default: `9696`).

## Notes

- Installed once from the latest release (Servarr's update link); after that Prowlarr updates itself.
- Login is required (forms), also on the LAN; the user is created on the first visit to the web UI.
- Only the settings in the role are managed in `config.xml`; everything else stays editable in the web UI.
