# Ansible Role: garage

Installs [Garage](https://garagehq.deuxfleurs.fr/), an S3-compatible object store, as a single-node cluster:
downloads the binary, bootstraps the layout, provisions buckets with per-bucket keys, and optionally fronts the S3
API with a reverse-proxy vhost.

## Role Variables

### Buckets and keys

- `garage_buckets` list of `{name, access_key_id, secret_access_key}` dicts (default: `[]`). Each bucket gets its
  own key with `--read --write --owner` on that bucket **only** - no shared or admin S3 credential.

  ```yaml
  garage_buckets:
    - name: "backups"
      access_key_id: "GK_..."
      secret_access_key: "..."
  ```

### Server

- `garage_hostname` FQDN for the S3 API vhost (e.g. `s3.internal`). Undefined skips the vhost (no default).
- `garage_version` release to install (default: `2.3.0`).
- `garage_s3_port` / `garage_admin_port` S3 and admin API ports (default: `3900` / `3903`).
- `garage_rpc_bind_addr` RPC bind address (default: `127.0.0.1:3901`).
- `garage_rpc_secret` 32-byte hex RPC secret (required).
- `garage_capacity` node storage capacity, e.g. `100G` (default: `100G`).
- `garage_data_dir` / `garage_meta_dir` object data / metadata paths (default: `/mnt/backup/garage/data` /
  `/mnt/backup/garage/meta`).

### Admin API

- `garage_metrics_token` bearer token for `/metrics`. Setting it widens `api_bind_addr` to `0.0.0.0` so `/metrics`
  is remotely scrapable; undefined keeps the admin API loopback-only (default).
- `garage_admin_token` bearer token for the full admin API (buckets/keys/nodes). Undefined keeps it locked
  (Garage's default since v2.0). Does not affect `api_bind_addr`.
