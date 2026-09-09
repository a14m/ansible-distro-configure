# Ansible Role: obsidian-livesync

Installs the [Self-hosted LiveSync](https://github.com/vrtmrz/obsidian-livesync) plugin into an existing vault,
syncing against this repo's `couchdb` role. Depends on the `obsidian` role - Arch and Ubuntu/Debian only (no macOS).

Downloads the pinned plugin release, then seeds `data.json` with the CouchDB connection, E2EE, and the plugin's own
self-hosted-CouchDB preset (`PREFERRED_BASE` + `PREFERRED_SETTING_SELF_HOSTED`[^preset]) **once** - after first run
the plugin owns that file. To reconfigure, delete `data.json` first. Seeding the full preset means new devices
converge with far fewer in-app "Config doctor" prompts.

## Role Variables

- `obsidian_livesync_vault_path` vault path (required, per-host).
- `obsidian_livesync_uri` CouchDB URI, e.g. `https://notes.internal` (required). Must be HTTPS for Obsidian Mobile -
  the reverse-proxied hostname, not `couchdb_bind_address`.
- `obsidian_livesync_user` / `obsidian_livesync_password` CouchDB credentials (required) - one `couchdb_users` entry.
- `obsidian_livesync_dbname` database to sync against (default: `obsidian`) - that user's own database.
- `obsidian_livesync_passphrase` E2EE passphrase (required). Encryption + path obfuscation are always on; the remote
  only ever sees ciphertext, including file/folder names.
- `obsidian_livesync_plugin_version` release tag (default: `1.0.24`).

## CouchDB-side requirements

- A user + database from `couchdb_users` matching the credentials above.
- **CORS enabled** - set `couchdb_cors_origins` to `app://obsidian.md`, `capacitor://localhost`, `http://localhost`.
  The `couchdb` role doesn't know LiveSync exists, so this lives in `host_vars/notes.home.arpa.yml.example`.

## Notes

- The `couchdb` server has no public domain and serves plain HTTP; LAN, Tailscale, and the HTTPS mobile needs all
  come from the Caddy `vhost` with a self-signed cert:
  - **On the LAN**: any device on `10.0.0.0/24` reaches the proxy directly.
  - **Over Tailscale**: `tailscale.home.arpa` advertises `10.0.0.0/24` to the tailnet - same LAN address works.
  - Every syncing device must trust the self-signed cert on first connect.
- No `become` - manages files under a user's vault, not a system service.
- The role doesn't enable the plugin or disable Restricted Mode (Obsidian settings UI only): Settings → Community
  plugins → disable Restricted Mode → enable "Self-hosted LiveSync".
- Devices meant to sync the same vault must authenticate as the *same* CouchDB user - the per-user-database model
  means different users never share a database.

[^preset]: Seeded field names and values were taken from the plugin's source, not the settings-UI docs (which label
    the same fields differently). Connection/encryption fields (`couchDB_URI`, `couchDB_USER`, `remoteType`, …) are
    `CouchDBConnection`/`EncryptionSettings` in
    [`livesync-commonlib` `setting.type.ts`](https://github.com/vrtmrz/livesync-commonlib/blob/main/src/common/models/setting.type.ts),
    with `remoteType` set to the `REMOTE_COUCHDB` constant (an empty string, not `"COUCHDB"`) from
    [`setting.const.ts`](https://github.com/vrtmrz/livesync-commonlib/blob/main/src/common/models/setting.const.ts).
    The tuning fields (`syncMaxSizeInMB`, `chunkSplitterVersion`, `usePluginSyncV2`, `handleFilenameCaseSensitive`,
    `E2EEAlgorithm`, `customChunkSize`, `sendChunksBulkMaxSize`, `concurrencyOfReadChunksOnline`,
    `minimumIntervalOfReadChunksOnline`) are `PREFERRED_BASE` + `PREFERRED_SETTING_SELF_HOSTED` from
    [`setting.const.preferred.ts`](https://github.com/vrtmrz/livesync-commonlib/blob/main/src/common/models/setting.const.preferred.ts) -
    the preset for a self-hosted CouchDB remote specifically (`PREFERRED_SETTING_CLOUDANT` and
    `PREFERRED_JOURNAL_SYNC` differ, notably on `customChunkSize`).
