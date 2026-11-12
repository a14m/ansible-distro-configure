# Ansible Role: bazarr

Installs [Bazarr](https://www.bazarr.media/) (subtitles for Sonarr/Radarr) as the `bazarr` systemd service (its own
`bazarr` user, app and Python venv in `/opt/bazarr`, data in `/var/lib/bazarr`), and adds its web UI vhost.

## Role Variables

- `bazarr_api_key` API key for other apps (required), e.g. `openssl rand -hex 16`.
- `bazarr_username` / `bazarr_password` web UI login (required); Bazarr has none by default.
- `bazarr_sonarr` / `bazarr_radarr` `{ip, port, api_key}` connections (required).
- `bazarr_languages` subtitle languages in preference order (required); they make up the "Default" languages profile,
  used for new series and movies.
- `bazarr_providers` providers to use, each with its settings section, e.g. `opensubtitlescom: {username, password}`,
  `tvsubtitles: {}` (required).
- `bazarr_hostname` FQDN / vhost `server_name` (e.g. `subtitles.internal`). Undefined skips the proxy vhost.
- `bazarr_group` / `bazarr_group_id` primary group (and optional GID) of the bazarr user; share it with the media
  folders so subtitles can be written next to videos (default: `bazarr`). Files are group-writable (`UMask=0002`).
- `bazarr_port` web UI port on `network_ipv4_address` (default: `6767`).

## Notes

- Installed once from the latest release; after that Bazarr updates itself. Each run re-applies `requirements.txt`.
- The keys in `vars/main.yml` (bind address, port, login, API key, Sonarr/Radarr, providers, default profile,
  analytics off) are set in `config.yaml`; languages and the profile through the API. Everything else stays
  editable in the web UI.
