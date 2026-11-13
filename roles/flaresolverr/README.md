# Ansible Role: flaresolverr

Installs [FlareSolverr](https://github.com/FlareSolverr/FlareSolverr) (solves Cloudflare challenges for Prowlarr
indexers) as the `flaresolverr` systemd service, listening on `127.0.0.1` only.

## Role Variables

- `flaresolverr_version` release tag to hold or roll back (e.g. `v3.5.2`); `latest` (default) upgrades on the next
  run after a new release, since FlareSolverr doesn't update itself and an outdated one stops working.
- `flaresolverr_port` port on `127.0.0.1` (default: `8191`).

## Notes

- Each release goes to `/opt/flaresolverr-<tag>`, `/opt/flaresolverr` points at the current one, older ones are
  removed.
- In Prowlarr: Settings > Indexers > Indexer Proxies > FlareSolverr, host `http://127.0.0.1:8191/`, with a tag; tag
  the indexers that need it.
