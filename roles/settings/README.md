# Ansible Role: settings

This role configure the machine settings (locales/timezone/password policy/etc.)

## Role Variables

- `settings_timezone` the timezone default `CET`

- `settings_pw_policy_enabled` boolean to enable or disable the enforcement of password policy
- `settings_pw_policy_difok` the number of differences between new and old password (default 0 - disabled)
- `settings_pw_policy_minlen` min password length (default 8)
- `settings_pw_policy_dcredit` required digits in password (default 0)
- `settings_pw_policy_ucredit` required uppercase chars in password (default 0)
- `settings_pw_policy_ocredit` required other chars in password (default 0)
- `settings_pw_policy_lcredit` required lowercase chars in password (default 0)
- `settings_pw_policy_minclass` required minimum classes in password upper/lower/digit/other (default 0 - disabled)
- `settings_pw_policy_maxrepeat` allowed maximum repeats in password (default 0 - disabled)
- `settings_pw_policy_maxclassrepeat` maximum allowed consecutive class repeats (default 0 -disabled)
- `settings_pw_policy_gecoscheck` (default 0 - disabled)

## Docs

- https://linux.die.net/man/8/pam_pwquality
