# Ansible Role: settings

This role configure the machine settings (locales/timezone/password policy/etc.)

## Role Variables

- `settings_timezone` the timezone default `CET`

- `settings_locales` the list of locales to be generated. (default: `de_DE`)
- `settings_locales_lang`:                `LANG=`              default  `de_DE.UTF-8`
- `settings_locales_language`:            `LANGUAGE=`          default  `de_DE.UTF-8:de:C`
- `settings_locales_lc_ctype`:            `LC_CTYPE=`          default  `de_DE.UTF-8`
- `settings_locales_lc_numeric`:          `LC_NUMERIC=`        default  `de_DE.UTF-8`
- `settings_locales_lc_time`:             `LC_TIME=`           default  `de_DE.UTF-8`
- `settings_locales_lc_collate`:          `LC_COLLATE=`        default  `de_DE.UTF-8`
- `settings_locales_lc_monetary`:         `LC_MONETARY=`       default  `de_DE.UTF-8`
- `settings_locales_lc_messages`:         `LC_MESSAGES=`       default  `de_DE.UTF-8`
- `settings_locales_lc_paper`:            `LC_PAPER=`          default  `de_DE.UTF-8`
- `settings_locales_lc_name`:             `LC_NAME=`           default  `de_DE.UTF-8`
- `settings_locales_lc_address`:          `LC_ADDRESS=`        default  `de_DE.UTF-8`
- `settings_locales_lc_telephone`:        `LC_TELEPHONE=`      default  `de_DE.UTF-8`
- `settings_locales_lc_measurement`:      `LC_MEASUREMENT=`    default  `de_DE.UTF-8`
- `settings_locales_lc_identification`:   `LC_IDENTIFICATION=` default  `de_DE.UTF-8`

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

- https://manpages.debian.org/buster/manpages/locale.1.en.html
- https://manpages.debian.org/buster/locales/locale-gen.8.en.html
- https://manpages.debian.org/buster/manpages/localedef.1.en.html
- https://linux.die.net/man/8/pam_pwquality
