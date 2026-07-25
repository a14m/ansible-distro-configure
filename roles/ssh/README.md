# Ansible Role: ssh

This role configure the ssh functionality of a linux distro with hardening

## Role Variables

- `username` the user account to be added to the ssh allowed users.
- `ssh_port` the port number to be enabled for ssh (default: 2222)
- `ssh_private_key` pre-generated Ed25519 host private key, unique per host. Generate with:
  `ssh-keygen -t ed25519 -f host_key -C '' -N ''`
- `ssh_public_key` matching pre-generated Ed25519 host public key

## Internals

- ensure that ssh packages is installed and enabled
- deploy pre-generated ssh host keys (stable across reprovision/reimage, no key regeneration on each setup)
- configure ssh defaults
  - disable keyboard interactive authentication
  - disable PAM authentication
- configure ssh authentication policy (hardened)
  - configure custom ssh port
  - disable password authentication
  - require public key authentication
  - disable root login
- add user (username) to allowed authentication users
- TBA: `fail2ban`
