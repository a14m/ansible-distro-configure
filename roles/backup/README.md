# Ansible Role: backup

Backs up a set of paths to an S3-compatible restic repository on a schedule, and restores a snapshot on demand
(explicit `--tags restore` only). The scheduled job runs as an unprivileged `backup_user`; restore runs as root.

## Role Variables

### Identity

- `backup_name` unique job name - used for the unit/cron entry, script name, and a sub-path in the repo so multiple
  jobs share one bucket (default: `"backup"`). **Required if a host runs more than one job.**
- `backup_user` / `backup_group` system account the scheduled job runs as (default: `"backup"`).

### What / when / retention

- `backup_paths` **Required** list of paths to back up.
- `backup_systemd_schedule` `OnCalendar` value on systemd hosts (default: `"daily"`).
- `backup_cron_schedule` cron value on OpenRC hosts (default: `"0 0 * * *"`).
- `backup_retention_daily` / `_weekly` / `_monthly` snapshots to keep (default: `7` / `4` / `6`).

### Restic repository

- `backup_repo` **Required** repo URL, e.g. `s3:http://machine.local:3900/backups`. The role appends
  `/{{ backup_name }}`.
- `backup_access_key_id` / `backup_secret_access_key` **Required** S3 credentials.
- `backup_password` **Required** restic encryption password. Losing it makes every snapshot unrecoverable - it's
  stored only in the target host's credential file.

### Restore (`--tags restore` only)

- `restore_target` **Required for restore** directory to restore into.
- `backup_restore_id` snapshot ID or `"latest"` (default: `"latest"`).

## Backup process

- Creates the `backup_user` system account (`nologin`, no home); restic never runs as root for backups.
- Writes credentials to `/etc/credstore/{{ backup_name }}-backup.env` (root:root, `0600`), quoted, under inert
  `BACKUP_*` names - not the ambient `RESTIC_*`/`AWS_*` names, so a stray `source` elsewhere can't hijack them.
- Dedicated restic cache at `/var/cache/{{ backup_name }}-backup` (no home dir for the account).
- Scheduling:
  - **systemd**: `LoadCredential=` service + timer - the secret never lands in the unit's tracked environment.
  - **OpenRC**: append-only `blockinfile` entry in `/etc/crontabs/root`; script runs as root, reads the credential
    file, drops to `backup_user` via `su -p` before touching restic.
- Script: `restic snapshots` (init on first run), `restic backup`, `restic forget --prune` per retention.

## Manual backup

**systemd** - run the *service*, not the script (the script needs `$CREDENTIALS_DIRECTORY`, set only by the unit):

```bash
sudo systemctl start {{ backup_name }}-backup.service   # blocks until done
journalctl -u {{ backup_name }}-backup.service -n 50
```

**OpenRC** - the script reads the fixed credential path, so run it directly:
`sudo /usr/local/bin/{{ backup_name }}-backup`

Verify a snapshot landed:

```bash
source /etc/credstore/{{ backup_name }}-backup.env
export RESTIC_REPOSITORY="$BACKUP_REPO" RESTIC_PASSWORD="$BACKUP_PASSWORD" \
       AWS_ACCESS_KEY_ID="$BACKUP_ACCESS_KEY_ID" AWS_SECRET_ACCESS_KEY="$BACKUP_SECRET_ACCESS_KEY"
restic --cache-dir "/var/cache/{{ backup_name }}-backup" snapshots
```

## Restore process

Every restore task is tagged `["never", "restore"]` - a normal run doesn't even deploy the restore script.

```bash
# latest snapshot
ansible-playbook service.yml --tags restore -e restore_target=/var/restore/git
# specific snapshot (find IDs with the restic snapshots command above)
ansible-playbook service.yml --tags restore \
  -e restore_target=/var/restore/git -e backup_restore_id=<snapshot-id>
```

### Caveats

- Restore runs `restic restore --delete`: `restore_target` ends up matching the snapshot exactly - anything added
  under the backed-up paths since is removed. `--delete` only prunes within the backed-up paths, not the rest of
  `restore_target`.
- Restore runs as root (not `backup_user`) - it must write into other service accounts' paths and restore their
  original UID/GID/permissions.
- `restore_target` has no default - restore is destructive if misdirected, so the target is a conscious choice
  every time.
