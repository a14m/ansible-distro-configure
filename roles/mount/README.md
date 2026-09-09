# Mount Role

Mounts a drive and adds a persistent fstab entry (auto-mounts on reboot).

## Variables

```yaml
mount_device: "PARTLABEL=backup"        # required, no default - set in host_vars
mount_point: "/backup"
mount_fstype: "ext4"
mount_options: "defaults,noatime"
```

## Preparing the drive

```bash
lsblk                                                              # find the device
sudo parted /dev/sdX --script mklabel gpt mkpart backup ext4 0% 100%
sudo parted /dev/sdX print                                         # verify the partition label
sudo mkfs.ext4 /dev/sdX1
sudo blkid /dev/sdX1                                               # verify the filesystem
ls /dev/disk/by-partlabel/                                         # verify the partlabel resolves
```

Then set `mount_device: "PARTLABEL=backup"` in the host's vars.

## Notes

- `PARTLABEL` is stable across reboots regardless of device enumeration order; `ansible.posix.mount` handles
  `PARTLABEL=` natively.
- `noatime` reduces write cycles on the drive.
