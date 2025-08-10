# Ansible Role: locales

This role configure the machine locales.

## Role Variables

- `locales` the list of locales to be generated. (default: `de_DE`)
- `locales_lang`:                `LANG=`              default  `de_DE.UTF-8`
- `locales_language`:            `LANGUAGE=`          default  `de_DE.UTF-8:de:C`
- `locales_lc_ctype`:            `LC_CTYPE=`          default  `de_DE.UTF-8`
- `locales_lc_numeric`:          `LC_NUMERIC=`        default  `de_DE.UTF-8`
- `locales_lc_time`:             `LC_TIME=`           default  `de_DE.UTF-8`
- `locales_lc_collate`:          `LC_COLLATE=`        default  `de_DE.UTF-8`
- `locales_lc_monetary`:         `LC_MONETARY=`       default  `de_DE.UTF-8`
- `locales_lc_messages`:         `LC_MESSAGES=`       default  `de_DE.UTF-8`
- `locales_lc_paper`:            `LC_PAPER=`          default  `de_DE.UTF-8`
- `locales_lc_name`:             `LC_NAME=`           default  `de_DE.UTF-8`
- `locales_lc_address`:          `LC_ADDRESS=`        default  `de_DE.UTF-8`
- `locales_lc_telephone`:        `LC_TELEPHONE=`      default  `de_DE.UTF-8`
- `locales_lc_measurement`:      `LC_MEASUREMENT=`    default  `de_DE.UTF-8`
- `locales_lc_identification`:   `LC_IDENTIFICATION=` default  `de_DE.UTF-8`

## Docs

- https://manpages.debian.org/buster/manpages/locale.1.en.html
- https://manpages.debian.org/buster/locales/locale-gen.8.en.html
- https://manpages.debian.org/buster/manpages/localedef.1.en.html
