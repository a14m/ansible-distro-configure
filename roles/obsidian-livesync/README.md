# Ansible Role: obsidian-livesync

Installs and configures the [Self-hosted LiveSync](https://github.com/vrtmrz/obsidian-livesync) plugin into an
existing vault, syncing against this repo's `couchdb` role rather than an S3-compatible bucket. Depends on the
`obsidian` role - Arch Linux and Ubuntu/Debian only, same as `obsidian` itself (no macOS support; `obsidian` has no
install path for it, so this role doesn't either).

## What it does

- Downloads `main.js`/`manifest.json`/`styles.css` from a pinned GitHub release into
  `<vault>/.obsidian/plugins/obsidian-livesync/`.
- Seeds `<vault>/.obsidian/plugins/obsidian-livesync/data.json` with the CouchDB connection, encryption, and
  recommended-tweak settings - **once only**. After the plugin has run, it owns that file and rewrites it with its
  own state (sync checkpoints, etc.); this role never overwrites it again once it exists. To reconfigure, delete
  `data.json` (or hand-edit it) first.

The settings field names (`couchDB_URI`, `couchDB_USER`, `remoteType`, etc.) were confirmed against the plugin's
actual source - `CouchDBConnection`/`EncryptionSettings` in
[`vrtmrz/livesync-commonlib`'s `setting.type.ts`](https://github.com/vrtmrz/livesync-commonlib/blob/main/src/common/models/setting.type.ts),
and the `REMOTE_COUCHDB` constant (an empty string, not a `"COUCHDB"` literal) in
[`setting.const.ts`](https://github.com/vrtmrz/livesync-commonlib/blob/main/src/common/models/setting.const.ts) - not
the settings UI docs, which describe the same fields under different labels.

The remaining seeded fields (`syncMaxSizeInMB`, `chunkSplitterVersion`, `usePluginSyncV2`, `handleFilenameCaseSensitive`,
`E2EEAlgorithm`, `customChunkSize`, `sendChunksBulkMaxSize`, `concurrencyOfReadChunksOnline`,
`minimumIntervalOfReadChunksOnline`) are `PREFERRED_BASE` + `PREFERRED_SETTING_SELF_HOSTED` from
[`setting.const.preferred.ts`](https://github.com/vrtmrz/livesync-commonlib/blob/main/src/common/models/setting.const.preferred.ts) -
the plugin's own canonical preset for a self-hosted CouchDB remote specifically (`PREFERRED_SETTING_CLOUDANT` and
`PREFERRED_JOURNAL_SYNC` use different values for IBM Cloudant and journal/S3 sync respectively - notably a
different `customChunkSize`, since chunk-size economics differ per backend). This is exactly what the plugin's own
in-app "Config doctor" prompts you to fix, one setting at a time, on every new device otherwise (e.g. "Per-file-saved
customization sync" for `usePluginSyncV2`, "Enhance chunk size" for `customChunkSize`) - seeding the whole preset up
front means new devices should converge with drastically fewer doctor prompts.

## Role Variables

- `obsidian_livesync_vault_path` filesystem path to the vault (required, no default - inherently per-host).
- `obsidian_livesync_uri` CouchDB URI, e.g. `https://notes.internal` (required). Must be HTTPS for Obsidian Mobile -
  this is the hostname the `couchdb` role's database is reverse-proxied under, not `couchdb_bind_address` directly.
- `obsidian_livesync_user` / `obsidian_livesync_password` CouchDB credentials (required) - one entry of the
  `couchdb` role's `couchdb_users`.
- `obsidian_livesync_dbname` database name to sync against (default: `obsidian`) - that user's own database, per the
  `couchdb` role's one-database-per-user model.
- `obsidian_livesync_passphrase` end-to-end encryption passphrase (required). This role always enables encryption
  and path obfuscation together - the remote CouchDB only ever sees ciphertext, including file/folder names, never
  plaintext paths alongside encrypted content.
- `obsidian_livesync_plugin_version` GitHub release tag to install (default: `1.0.24`).

## CouchDB-side requirements

This role only touches the vault/plugin side - the CouchDB server it points at (e.g. this repo's `couchdb` role)
needs:

- A user + database from `couchdb_users` matching `obsidian_livesync_user`/`_password`/`_dbname`.
- **CORS enabled**, since the plugin talks to CouchDB directly from the app's own origin (a cross-origin request
  from the app's point of view): set `couchdb_cors_origins` to include `app://obsidian.md` (desktop),
  `capacitor://localhost` (mobile), and `http://localhost`. The `couchdb` role has no idea LiveSync exists, so this
  is supplied at the point where you configure that server for this use, not something either role wires up on its
  own - see `host_vars/notes.home.arpa.yml.example` in this repo for where that lives in practice.

## Reaching the CouchDB server from any device on the network

The `couchdb` role's server has no public domain and only serves plain HTTP directly - LAN and Tailscale
reachability, plus the HTTPS Obsidian Mobile requires, both come from putting it behind this repo's `vhost` role
(Caddy) with a self-signed certificate, the same way `radicale` and other internal services in this repo are
exposed:

- **Physically on the LAN**: any device on `10.0.0.0/24` reaches the proxy host directly.
- **Over Tailscale**: this repo's `tailscale.home.arpa` container runs as a subnet router advertising `10.0.0.0/24`
  to the tailnet, so a device connected to the tailnet (without running Tailscale on the proxy/CouchDB hosts
  themselves) can reach the same LAN address.
- A self-signed cert means every device doing the sync (desktop Obsidian and, especially, mobile) needs to trust it
  manually on first connect - there's no public CA involved since there's no public domain.

## Notes

- No `become` anywhere - this manages files under a user's own vault, not a system service.
- This role does not enable the plugin or turn off Restricted Mode - both only live in Obsidian's own settings UI
  (Restricted Mode isn't stored in any vault file at all), so you'll be in that screen regardless. Open Settings ->
  Community plugins, turn off Restricted Mode, and toggle "Self-hosted LiveSync" on.
- Give each syncing device's Obsidian instance the *same* `obsidian_livesync_user` (and the matching `couchdb_users`
  entry on the server) if they're meant to sync the same vault against each other - the `couchdb` role's per-user
  database model means two different users never share a database, so two devices syncing the same vault must
  authenticate as the same CouchDB user.
