# Ansible Role: locales

Generates locales and sets `/etc/locale.conf`.
See [`locale(1)`](https://manpages.debian.org/buster/manpages/locale.1.en.html),
[`locale-gen(8)`](https://manpages.debian.org/buster/locales/locale-gen.8.en.html).

## Role Variables

- `locales` list of locales to generate (default: `de_DE`).
- `locales_lang` → `LANG=` (default: `de_DE.UTF-8`).
- `locales_language` → `LANGUAGE=` (default: `de_DE.UTF-8:de:C`).
- `locales_lc_*` → the matching `LC_*` var (`ctype`, `numeric`, `time`, `collate`, `monetary`, `messages`, `paper`,
  `name`, `address`, `telephone`, `measurement`, `identification`) - all default `de_DE.UTF-8`.
