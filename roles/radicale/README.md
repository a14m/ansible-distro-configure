# Ansible Role: radicale

Installs [Radicale](https://radicale.org/) (CalDAV/CardDAV) with htpasswd auth, a rights file, calendar/address-book
sharing between users, and an optional reverse-proxy vhost on `proxy.home.arpa`.

## Role Variables

### Server

- `radicale_hostname` FQDN / vhost `server_name` (e.g. `caldav.example.com`). Undefined skips the vhost (no default).
- `radicale_port` bind port on `network_ipv4_address` (default: `5232`).
- `radicale_storage_dir` collections path (default: `/var/lib/radicale/collections`).
- `radicale_auth_delay` seconds throttled (average) after a failed login (default: `3`).

### Users and rights

- `radicale_users` list of `{name, password_hash}` dicts. Generate the hash yourself (the role never sees plaintext):
  `mkpasswd -m bcrypt -R 12 <password>` or `htpasswd -nbB -C 12 <user> <password> | cut -d: -f2`.
- `radicale_rights_rules` list of `{name, user, collection, permissions}` rules (default: every authenticated user
  gets `R` on the server root and full `RWrw` on their own `{user}(/.*)?` path - this is what makes
  `radicale_collections` work with no rights changes).

### Sharing

- `radicale_collections` list of `{owner, collection, members}` dicts.

  ```yaml
  radicale_collections:
    - owner: "ahmed"
      collection: "e8eb7e18-7686-7077-585e-f730c632a60e"
      members: ["anna"]
  ```

  For each entry the role symlinks the owner's collection into each member's path. Radicale checks rights on the
  request path, not the resolved path, so a symlinked collection counts as the member's own under `owner-only` - no
  per-share rights rule needed.

## Notes

- **The role never creates the collection.** `collection` is just a name; the owner creates the actual
  calendar/address book via Radicale's web UI or `MKCALENDAR`. The role only manages the sharing symlink and the
  per-user base directory, and never touches collection contents or metadata.
- **`collection` must be a flat name (no `/`).** `state: link` won't create missing parent dirs, so a nested name
  fails every run. For a nested collection, `mkdir -p` + `chown radicale:radicale` the intermediate dir on every
  member's *and* the owner's side first.
- Member symlinks back up for free via the `backup` role - restic doesn't dereference symlinks, so a shared
  collection is stored once (under the owner) and restores as a pointer, not a copy.
