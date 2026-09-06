# Ansible Role: couchdb

Installs [Apache CouchDB](https://couchdb.apache.org/) from the project's own apt repository
(Debian's own repos don't reliably carry it), configured as a single standalone node, plus a list
of users each scoped to their own database. Generic - has no knowledge of, or dependency on,
whatever ends up talking to it (e.g. this repo's `obsidian-livesync` role).

## What it does

- Adds the Apache CouchDB apt repository and installs the `couchdb` package, preseeding the
  installer via debconf so it never prompts (standalone mode, bind address, cookie, admin password).
- Writes `/opt/couchdb/etc/local.ini` with the bind address/port, max document size, and (optionally) CORS settings.
- For each entry in `couchdb_users`, creates the CouchDB user, creates its named database, and
  sets that database's `_security` so only that user (and admins) can read/write it.
- Optionally creates a reverse-proxy vhost (nginx/caddy, via this repo's `vhost` role).

## Role Variables

- `couchdb_hostname` FQDN CouchDB is reached at (e.g. `notes.internal`). Also used as the
  reverse-proxy vhost's `server_name`/site block - leave undefined to skip the proxy vhost entirely (no default).
- `couchdb_bind_address` address CouchDB's HTTP API binds on (default: `{{ network_ipv4_address }}`).
- `couchdb_port` port CouchDB's HTTP API binds on (default: `5984`).
- `couchdb_cookie` Erlang distribution cookie (required, no default). Only meaningful for clustering,
  but the `.deb` installer always asks for one at first configure.
- `couchdb_admin_password` password for the bootstrap admin user (required, no default).
  The `.deb` installer hardcodes that user's name to `admin` - there's no debconf question to change it.
- `couchdb_cors_origins` list of origins allowed through CORS (default: `[]`, which leaves CORS disabled).
  Only needed if some client talks to CouchDB directly from a browser/app origin - e.g. `obsidian-livesync` needs
  its app's origins listed here (see that role's README).
- `couchdb_max_document_size` max document size in bytes (default: `50000000`) - large vault attachments need
  headroom over CouchDB's own default.
- `couchdb_users` list of `{name, password, database}` dicts (default: `[]`), each field required.

## Notes

- **Admin password and cookie are one-shot.** Both are only ever read by the `.deb` postinst
  script the first time the package is configured. Changing `couchdb_admin_password` or
  `couchdb_cookie` afterwards updates the debconf database but has no effect on the already
  running node - rotate the admin password through CouchDB itself (the `_config/admins` HTTP API,
  authenticated as the current admin), or purge and reinstall the package to start over.
- **User passwords are one-shot too.** Creating a user that already exists is a no-op (CouchDB
  returns 409, which this role treats as success) - this role never updates an existing user's
  password. To rotate one, delete the user doc first (`DELETE /_users/org.couchdb.user:<name>?rev=<rev>`)
  or update it directly through the API, then converge again.
- CouchDB itself only ever speaks plain HTTP - TLS (self-signed, since there's no public domain)
  comes entirely from the proxy this role optionally puts in front of it via `couchdb_hostname`.
  See `obsidian-livesync`'s README for how LAN and Tailscale clients both reach it.
