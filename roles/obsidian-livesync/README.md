# Ansible Role: obsidian-livesync

Installs and configures the [Self-hosted LiveSync](https://github.com/vrtmrz/obsidian-livesync)
plugin into an existing vault, syncing against an S3-compatible bucket (e.g. this repo's
`garage` role) rather than CouchDB. Depends on the `obsidian` role — Arch Linux and Ubuntu/Debian
only, same as `obsidian` itself (no macOS support; `obsidian` has no install path for it, so
this role doesn't either).

## What it does

- Downloads `main.js`/`manifest.json`/`styles.css` from a pinned GitHub release into
  `<vault>/.obsidian/plugins/obsidian-livesync/`.
- Seeds `<vault>/.obsidian/plugins/obsidian-livesync/data.json` with the S3 connection and
  encryption settings — **once only**. After the plugin has run, it owns that file and
  rewrites it with its own state (sync checkpoints, etc.); this role never overwrites it again
  once it exists. To reconfigure, delete `data.json` (or hand-edit it) first.

The settings field names (`remoteType`, `accessKey`, `bucket`, `forcePathStyle`, etc.) were
confirmed against the plugin's actual source — `BucketSyncSetting` in
[`vrtmrz/livesync-commonlib`'s `setting.type.ts`](https://github.com/vrtmrz/livesync-commonlib/blob/main/src/common/models/setting.type.ts)
— not the settings UI docs, which describe the same fields under different labels.

## Role Variables

- `obsidian_livesync_vault_path` filesystem path to the vault (required, no default — inherently
  per-host).
- `obsidian_livesync_endpoint` S3-compatible endpoint URL, e.g. `https://s3.internal` (required).
  Must be HTTPS for Obsidian Mobile.
- `obsidian_livesync_access_key` / `obsidian_livesync_secret_key` S3 credentials (required).
- `obsidian_livesync_bucket` bucket name (default: `obsidian`).
- `obsidian_livesync_region` S3 region to sign requests with (default: `garage`).
- `obsidian_livesync_bucket_prefix` prefix within the bucket, acting like a folder — useful if
  multiple vaults share one bucket (default: `""`, syncs at the bucket root).
- `obsidian_livesync_use_custom_request_handler` use Obsidian's internal API instead of browser
  fetch, bypassing CORS (default: `true`). Turn off only if the bucket has CORS configured.
- `obsidian_livesync_passphrase` end-to-end encryption passphrase (required). This role always
  enables encryption and path obfuscation together — the remote bucket only ever sees
  ciphertext, including file/folder names, never plaintext paths alongside encrypted content.
- `obsidian_livesync_plugin_version` GitHub release tag to install (default: `1.0.24`).

## Notes

- No `become` anywhere — this manages files under a user's own vault, not a system service.
- This role does not enable the plugin or turn off Restricted Mode — both only live in
  Obsidian's own settings UI (Restricted Mode isn't stored in any vault file at all), so you'll
  be in that screen regardless. Open Settings → Community plugins, turn off Restricted Mode,
  and toggle "Self-hosted LiveSync" on.
- The dedicated, per-bucket S3 key from the `garage` role's `garage_buckets` is what should go
  in `obsidian_livesync_access_key`/`_secret_key` — never a key that also has access to other
  buckets (e.g. the restic backups one).
