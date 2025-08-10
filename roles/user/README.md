# Ansible Role: User

This role creates the user and configures the `sudo` group for the user

## Role Variables

- `username` **Required** name of the user to be created.
- `user_password` created user default password (default: `changeme`).
- `user_login_shell` the path to default user login shell (default: `/bin/bash`)
- `user_public_keys` the list of ssh public keys to be added to user authorized_keys
- `user_groups` extra groups to be created and user added to them (default: [])

## Internals

- ensure `sudo` installed.
- configure `sudoers` file to grant `%sudo ALL=(ALL:ALL) ALL` for `sudo` group.
- create user and add to the `username`, `sudo`, extra `user_groups` groups.
- require user password change on first use of `sudo` command.
- configure the user authorized keys to allow public key authentication (if configured).

### Caveats

If no public key authentication is configured by this role,
the user won't be able to login (since the hardened ssh role disable root and password authentication).

For this reason, if you want to enable the insecure password authentication,
please update the ssh role `"Configure authentication policy"` manually to
allow for password/root authentication, These features are disabled by default.
