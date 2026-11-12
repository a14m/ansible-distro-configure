# Ansible Role: prowlarr

Installs [Prowlarr](https://prowlarr.com/) (indexer manager) through the shared `servarr` app tasks (own user and
service, self-updating, login created on the first visit), and manages the apps it syncs indexers to.

## Role Variables

- `prowlarr_api_key` API key (required), e.g. `openssl rand -hex 16`.
- `prowlarr_applications` apps to sync indexers to, `{name, implementation (Sonarr/Radarr), fields: {baseUrl, apiKey,
  syncCategories}}` (default: `[]`); others are removed.
- `prowlarr_hostname` proxy vhost (e.g. `search.internal`); unset skips it.
- `prowlarr_allowed_hosts` hostnames/IPs accepted in the `Host` header (default: `[]`, allows all).
- `prowlarr_port` web UI port (default: `9696`).
