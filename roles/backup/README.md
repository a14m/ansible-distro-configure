# Backup Role

Mounts a dedicated backup drive on the target host.

## Overview

Prepares a dedicated storage device as the local backup destination S3-compatible object store (ex. Garage).

## Configuration

### Required Variables

```yaml
backup_device: "PARTLABEL=backup"  # no default — must set in host_vars
```

### Optional Variables

```yaml
backup_mount_point: "/backup"
backup_fstype: "ext4"
backup_mount_options: "defaults,noatime"
```

## Preparing the Drive

### 1. Install parted

```bash
sudo apt install parted
```

### 2. Partition with a named label

```bash
# check device name
lsblk

# create GPT partition table + single labeled partition
sudo parted /dev/sdX --script mklabel gpt mkpart backup ext4 0% 100%
sudo parted /dev/nvme0nX --script mklabel gpt mkpart backup ext4 0% 100%

# verify label
sudo parted /dev/sdX print
sudo parted /dev/nvme0nX print
```

### 3. Format as ext4

```bash
sudo mkfs.ext4 /dev/sdX1
sudo mkfs.ext4 /dev/nvme0nXp1

# verify
sudo blkid /dev/sdX1
sudo blkid /dev/nvme0nXp1

ls /dev/disk/by-partlabel/
```

### 4. Set host variable

In `host_vars/rpi5.local.yml`:

```yaml
backup_device: "PARTLABEL=backup"
```

`PARTLABEL` is stable across reboots regardless of device enumeration order (`/dev/sda` vs `/dev/sdb`).
`ansible.posix.mount` handles `PARTLABEL=` values natively.

## Notes

- `noatime` mount option reduces unnecessary write cycles on the drive
- Role adds a persistent fstab entry — drive auto-mounts on reboot
