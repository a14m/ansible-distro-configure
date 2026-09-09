# Ansible Role: user

Creates the user, grants the `sudo` group full sudo, and installs the user's `authorized_keys`.

## Role Variables

- `username` **Required** name of the user to create.
- `user_default_password` fallback password (`changeme`), forced to change on first `sudo` use.
- `user_password` if set, used instead of `user_default_password` and not forced to change.
- `user_login_shell` login shell (default: `/bin/bash`).
- `user_public_keys` ssh public keys for `authorized_keys`.
- `user_groups` extra groups to create and add the user to (default: `[]`).

## Caveats

With no `user_public_keys`, the user can't log in - the hardened `ssh` role disables root and password auth. To use
password auth, edit the `ssh` role's `"Configure authentication policy"` task manually.
