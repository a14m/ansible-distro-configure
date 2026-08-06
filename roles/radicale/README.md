# Ansible Role: radicale

Installs and configures [Radicale](https://radicale.org/), a CalDAV/CardDAV server, including
htpasswd-based auth, a rights file, and an optional reverse-proxy vhost on `proxy.home.arpa`.

## Role Variables

### Server

- `radicale_hostname` FQDN Radicale is reached at (e.g. `caldav.example.com`). Also used as the
  reverse-proxy vhost's `server_name`/site block — leave undefined to skip the proxy vhost
  entirely (no default).
- `radicale_port` port Radicale binds on `network_ipv4_address` (default: `5232`).
- `radicale_storage_dir` filesystem path where collections are stored (default:
  `/var/lib/radicale/collections`).
- `radicale_auth_delay` seconds throttled (average) after each failed/denied login attempt
  (default: `3`).

### Users and rights

- `radicale_users` list of `{name, password_hash}` dicts, written as `name:password_hash` lines
  to `/etc/radicale/users`. Generate the hash yourself, this role never sees a plaintext
  password:
  ```bash
  mkpasswd -m bcrypt -R 12 <password>
  # or
  htpasswd -nbB -C 12 <user> <password> | cut -d: -f2
  ```
- `radicale_rights_rules` list of `{name, user, collection, permissions}` rules written to
  `/etc/radicale/rights` (default: a `root` rule giving every authenticated user `R` on the
  server root, and an `owner-only` rule giving every user full `RWrw` on their own
  `{user}(/.*)?` path — this is what makes `radicale_collections` below work without any rights
  changes).

### Sharing a calendar/address book between users

- `radicale_collections` list of `{owner, collection, members}` dicts.

  ```yaml
  radicale_collections:
    - owner: "ahmed"
      collection: "e8eb7e18-7686-7077-585e-f730c632a60e"
      members: ["anna"]
  ```

  For each entry, the role symlinks
  `collection-root/{{ owner }}/{{ collection }}` into
  `collection-root/{{ member }}/{{ collection }}` for every listed member. Since Radicale's
  rights checks operate on the request path, not the resolved filesystem path, a symlinked
  path is indistinguishable from "the member's own path" as far as `owner-only` is concerned —
  no per-share rights rule is ever needed, this scales to any number of shared collections for
  free.

  **This role never creates the actual collection.** `collection` is just a name — the real
  calendar/address book at that path is created by the owner through Radicale's own web UI (or
  a raw `MKCALENDAR` request), same as any personal, unshared collection. Ansible only manages
  the sharing symlink and the per-user base directory it lives under; it has no opinion on the
  collection's contents, type, or metadata (title, color, description — all set through the
  client/web UI as normal, and untouched by this role on every converge).

  **`collection` must be a flat name — no `/`.** `ansible.builtin.file` with `state: link` does
  not create missing parent directories for the symlink's destination, so a nested collection
  (e.g. `"team/uuid"`) would fail every run with the member's `team/` directory missing. If you
  need a nested/grouped collection, create the intermediate directory yourself on **every**
  member's side before the collection is used, e.g.:
  ```bash
  mkdir -p {{ radicale_storage_dir }}/collection-root/anna/team
  chown radicale:radicale {{ radicale_storage_dir }}/collection-root/anna/team
  ```
  then this role's symlink task will place the leaf symlink inside it as usual. The owner's own
  side needs the same treatment before `MKCALENDAR`/the web UI will accept a nested path — its
  parent collection has to exist first, same WebDAV requirement as for any other client.

## Backup

Radicale's filesystem storage backend means member symlinks back up for free through the
`backup` role — `restic` doesn't dereference symlinks by default, so a shared collection is
backed up once (under the owner's path) and every member's symlink to it restores as a small
metadata pointer, not a duplicate copy.
