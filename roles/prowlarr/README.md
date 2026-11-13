# Ansible Role: prowlarr

Installs [Prowlarr](https://prowlarr.com/) (indexer manager) through the shared `servarr` app tasks (own user and
service, self-updating, login created on the first visit). Sonarr and Radarr register themselves as its apps.

## Role Variables

- `prowlarr_api_key` API key (required), e.g. `openssl rand -hex 16`.
- `prowlarr_hostname` proxy vhost (e.g. `search.internal`); unset skips it.
- `prowlarr_allowed_hosts` hostnames/IPs accepted in the `Host` header (default: `[]`, allows all).
- `prowlarr_port` web UI port (default: `9696`).
