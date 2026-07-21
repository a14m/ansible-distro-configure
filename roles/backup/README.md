# Ansible Role: backup

This role backs up a set of paths to an S3-compatible restic repository, on a schedule,
and can restore a snapshot back on demand.

## Role Variables

### Identity

- `backup_name` **Required for multiple jobs** unique name for this backup job — used
  for the systemd unit/cron entry, script name, and as a sub-path in the restic
  repository so multiple jobs can share one bucket (default: `"backup"`).
- `backup_user` / `backup_group` unprivileged system account the scheduled backup job
  runs as (default: `"backup"` / `"backup"`). Restore does not use this account — see
  Restore Process below.

### What to back up

- `backup_paths` **Required** list of paths to back up.

### Schedule

- `backup_systemd_schedule` systemd `OnCalendar` schedule (e.g. `daily`, `weekly`,
  `*-*-* 02:00`) — used on systemd hosts (default: `"daily"`).
- `backup_cron_schedule` cron schedule (e.g. `0 0 * * *`) — used on OpenRC hosts,
  since there's no systemd timer there (default: `"0 0 * * *"`).

### Retention

- `backup_retention_daily` number of daily snapshots to keep (default: `7`).
- `backup_retention_weekly` number of weekly snapshots to keep (default: `4`).
- `backup_retention_monthly` number of monthly snapshots to keep (default: `6`).

### Restic repository

- `backup_repo` **Required** restic repository URL (e.g.
  `s3:http://machine.local:3900/backups`). The role appends `/{{ backup_name }}` to
  this automatically, so multiple jobs can share one bucket.
- `backup_access_key_id` **Required** S3 access key ID.
- `backup_secret_access_key` **Required** S3 secret access key.
- `backup_password` **Required** restic repository encryption password. Losing this
  makes existing snapshots unrecoverable — it's not stored anywhere except the target
  host's credential file.

### Restore (only used with `--tags restore`, see below)

- `restore_target` **Required for restore** directory to restore snapshot contents
  into.
- `backup_restore_id` snapshot ID to restore, or `"latest"` (default: `"latest"`).

## Backup Process

- Creates the `backup_user`/`backup_group` system account (`nologin` shell, no home
  directory) — restic never runs as root.
- Deploys credentials to `/etc/credstore/{{ backup_name }}-backup.env`, root:root,
  mode `0600`. Values are quoted so `source`-ing the file can't be broken or exploited
  by special characters in a password. Variable names are `BACKUP_*`, not `RESTIC_*`/
  `AWS_*` — those are ambient names every S3/restic-aware tool auto-picks up from the
  environment, so keeping the on-disk file under inert names avoids a stray `source`
  elsewhere on the host silently redirecting some other tool's credentials.
- Creates a dedicated restic cache directory (`/var/cache/{{ backup_name }}-backup`),
  owned by `backup_user`, since that account has no home directory for restic to use
  by default.
- Schedules the actual backup job, split by init system:
  - **systemd**: a `LoadCredential=`-based service + timer. `LoadCredential` copies
    the credential file into a private, tmpfs-backed, per-run directory — the secret
    never lands in the unit's own tracked environment (unlike `EnvironmentFile=`,
    which would make it visible via `systemctl show`).
  - **OpenRC**: a `blockinfile`-managed entry in `/etc/crontabs/root` (append-only —
    won't clobber Alpine's default periodic maintenance jobs already in that file).
    Since there's no systemd credential broker, the script itself runs as root,
    reads the credential file directly, then drops to `backup_user` via `su -p`
    before ever touching restic or the backup paths.
- The backup script itself: `restic snapshots` (init the repo if this is the first
  run), `restic backup <paths>`, then `restic forget --prune` using the configured
  retention.

## Restore Process

Restore never runs automatically — every restore-related task is tagged
`["never", "restore"]`, Ansible's idiom for "only run when explicitly asked." A normal
`ansible-playbook` run touches none of it, not even deploying the restore script.

Restore always runs `restic restore --delete`, so `restore_target` ends up matching
the restored snapshot exactly — anything under the backed-up paths that was added
since the snapshot was taken gets removed, not just overlaid. `--delete` only prunes
within the backed-up paths themselves (e.g. `/srv/git`), not the rest of
`restore_target` even when that's `/`.

To restore, run the play with `--tags restore` and supply `restore_target`:

```bash
ansible-playbook service.yml --tags restore -e restore_target=/var/restore/git
```

To restore a specific snapshot instead of the latest one, also pass
`backup_restore_id`. To find available snapshot IDs, on the target host:

```bash
source /etc/credstore/{{ backup_name }}-backup.env
export RESTIC_REPOSITORY="$BACKUP_REPO" RESTIC_PASSWORD="$BACKUP_PASSWORD" \
       AWS_ACCESS_KEY_ID="$BACKUP_ACCESS_KEY_ID" AWS_SECRET_ACCESS_KEY="$BACKUP_SECRET_ACCESS_KEY"
restic --cache-dir "/var/cache/{{ backup_name }}-backup" snapshots
```

Then:

```bash
ansible-playbook service.yml --tags restore \
  -e restore_target=/var/restore/git -e backup_restore_id=<snapshot-id>
```

### Caveats

- Unlike backup, restore runs as root rather than dropping to `backup_user`. It needs
  to write into paths owned by other service accounts and restore their original
  ownership/permissions (restic records each file's original UID/GID and restores it
  by default, which requires root). This is a deliberately different privilege model
  from the scheduled, unattended backup job — restore only ever runs when explicitly
  invoked via `--tags restore`, a human decision each time, not something that runs
  on its own.
- `restore_target` is always required explicitly — there's no default. This is
  deliberate: restore is destructive if pointed at the wrong place, so the target
  must be a conscious choice every time, not something that silently falls back to
  a default path.
