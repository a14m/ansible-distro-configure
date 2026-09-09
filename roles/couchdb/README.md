# Ansible Role: couchdb

Installs [Apache CouchDB](https://couchdb.apache.org/) from the project's apt repo (Debian's own repos don't
reliably carry it) as a single standalone node, provisions users each scoped to their own database, and optionally
puts a reverse-proxy vhost in front (via the `vhost` role). Generic - knows nothing about what talks to it.

## Role Variables

- `couchdb_hostname` FQDN / vhost `server_name` (e.g. `notes.internal`). Undefined skips the proxy vhost (no default).
- `couchdb_bind_address` HTTP API bind address (default: `{{ network_ipv4_address }}`).
- `couchdb_port` HTTP API port (default: `5984`).
- `couchdb_cookie` Erlang cookie (required). Only matters for clustering, but the `.deb` installer always asks.
- `couchdb_admin_password` bootstrap admin password (required). The installer hardcodes the username to `admin`.
- `couchdb_cors_origins` origins allowed through CORS (default: `[]` - CORS off). Needed only for browser/app
  clients, e.g. `obsidian-livesync`.
- `couchdb_max_document_size` bytes (default: `50000000`) - headroom over CouchDB's default for large attachments.
- `couchdb_users` list of `{name, password, database}` dicts (default: `[]`), all fields required.

## Notes

- **Admin password and cookie are one-shot** - read only by the `.deb` postinst on first configure. Changing them
  later has no effect on the running node; rotate the admin password via CouchDB's `_config/admins` API, or purge
  and reinstall.
- **User passwords are one-shot too** - creating an existing user is a no-op (409, treated as success). To rotate,
  delete the user doc (`DELETE /_users/org.couchdb.user:<name>?rev=<rev>`) or edit it via the API, then converge.
- CouchDB speaks plain HTTP only; TLS (self-signed) comes entirely from the optional proxy vhost. See
  `obsidian-livesync`'s README for how LAN and Tailscale clients reach it.
