# Ansible Role: ssh

This role configure the ssh functionality of a linux distro with hardening

## Role Variables

- `username` the user account to be added to the ssh allowed users.
- `ssh_port` the port number to be enabled for ssh (default: 2222)

## Internals

- ensure that ssh packages is installed and enabled
- configure ssh host keys
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
