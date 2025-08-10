# Ansible Role: password_policy

This role configure the machine password quality policy

## Role Variables

- `password_policy_enabled` boolean to enable or disable the enforcement of password policy
- `password_policy_difok` the number of differences between new and old password (default 0 - disabled)
- `password_policy_minlen` min password length (default 8)
- `password_policy_dcredit` required digits in password (default 0)
- `password_policy_ucredit` required uppercase chars in password (default 0)
- `password_policy_ocredit` required other chars in password (default 0)
- `password_policy_lcredit` required lowercase chars in password (default 0)
- `password_policy_minclass` required minimum classes in password upper/lower/digit/other (default 0 - disabled)
- `password_policy_maxrepeat` allowed maximum repeats in password (default 0 - disabled)
- `password_policy_maxclassrepeat` maximum allowed consecutive class repeats (default 0 -disabled)
- `password_policy_gecoscheck` (default 0 - disabled)

## Docs

- https://linux.die.net/man/8/pam_pwquality
