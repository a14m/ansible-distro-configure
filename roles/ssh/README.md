# Ansible Role: ssh

Installs and hardens the SSH server: custom port, public-key auth only (no root login, no password /
keyboard-interactive / PAM auth), `username` the sole allowed user.

## Role Variables

- `username` account added to `AllowUsers`.
- `ssh_port` listen port (default: `2222`).
- `ssh_private_key` / `ssh_public_key` pre-generated Ed25519 host key, unique per host, stable across reimage.
  Generate: `ssh-keygen -t ed25519 -f host_key -C '' -N ''`.
