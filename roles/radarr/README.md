# Ansible Role: radarr

Installs [Radarr](https://radarr.video/) (movie manager) as the `radarr` systemd service (its own `radarr` user,
app in `/opt/Radarr`, data in `/var/lib/radarr`), and adds its web UI vhost.

## Role Variables

- `radarr_api_key` API key for other apps (required), e.g. `openssl rand -hex 16`.
- `radarr_hostname` FQDN / vhost `server_name` (e.g. `movies.internal`). Undefined skips the proxy vhost.
- `radarr_allowed_hosts` hostnames/IPs accepted in the `Host` header (default: `[]`, allows all).
- `radarr_group` / `radarr_group_id` primary group (and optional GID) of the radarr user; share it with the download
  client so imports can hardlink (default: `radarr`). Files are group-writable (`UMask=0002`).
- `radarr_root_folders` library folders to create (owned by radarr and its group) and add in Radarr (default: `[]`).
- `radarr_port` web UI port on `network_ipv4_address` (default: `7878`).

## Notes

- Installed once from the latest release; after that Radarr updates itself.
- Login is required, also on the LAN; the user is created on the first visit to the web UI.
- Only the settings in the role are managed in `config.xml`; everything else stays editable in the web UI.
- Root folders are added through the API only when missing, so web UI edits are kept; the download client is
  set up in the web UI.
