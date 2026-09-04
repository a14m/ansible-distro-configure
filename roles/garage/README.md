# Ansible Role: garage

Installs [Garage](https://garagehq.deuxfleurs.fr/), an S3-compatible object store, as a
single-node cluster: downloads the binary, bootstraps the cluster layout, and provisions
buckets with per-bucket keys. Optionally fronts the S3 API with a reverse-proxy vhost.

## Role Variables

### Buckets and keys

- `garage_buckets` list of `{name, access_key_id, secret_access_key}` dicts (default: `[]`).
  Each bucket gets its own key, granted `--read --write --owner` on that bucket **only** — a
  key for one bucket cannot read or write another. There's no shared/admin S3 credential; every
  consumer (restic backups, a sync client, etc.) gets a key scoped to just the bucket it needs.

  ```yaml
  garage_buckets:
    - name: "backups"
      access_key_id: "GK_..."
      secret_access_key: "..."
    - name: "obsidian"
      access_key_id: "GK_..."
      secret_access_key: "..."
  ```

### Server

- `garage_hostname` FQDN for the S3 API vhost (e.g. `sync.internal`). Required for S3 clients
  that need HTTPS (e.g. Obsidian Mobile) — leave undefined to skip vhost creation entirely (no
  default).
- `garage_version` release to install (default: `2.3.0`).
- `garage_s3_port` / `garage_admin_port` ports for the S3 and admin APIs (default: `3900` /
  `3903`).
- `garage_rpc_bind_addr` RPC bind address (default: `127.0.0.1:3901`).
- `garage_rpc_secret` 32-byte hex RPC secret shared across nodes (required, no default).
- `garage_capacity` storage capacity for this node, e.g. `100G` (default: `100G`).
- `garage_data_dir` / `garage_meta_dir` filesystem paths for object data and metadata (default:
  `/mnt/backup/garage/data` / `/mnt/backup/garage/meta`).

### Admin API

- `garage_metrics_token` bearer token required to read `/metrics`. Leave undefined to keep the
  admin API loopback-only (default) — setting this widens `api_bind_addr` to `0.0.0.0` so
  `/metrics` is remotely scrapable, gated by this token.
- `garage_admin_token` bearer token required for the full admin API (buckets/keys/nodes), e.g.
  for a locally-running admin UI. Leave undefined to keep the admin API fully locked (Garage's
  default since v2.0). Does not affect `api_bind_addr` — only `garage_metrics_token` controls
  that.
