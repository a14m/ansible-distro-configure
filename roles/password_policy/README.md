# Ansible Role: password_policy

Enforces `pam_pwquality` password rules. See [`pam_pwquality(8)`](https://linux.die.net/man/8/pam_pwquality).

## Role Variables

- `password_policy_enabled` toggle enforcement.
- `password_policy_difok` chars that must differ from the old password (default `0` - off).
- `password_policy_minlen` min length (default `8`).
- `password_policy_dcredit` / `ucredit` / `lcredit` / `ocredit` required digits / uppercase / lowercase / other
  (default `0`).
- `password_policy_minclass` min character classes (default `0` - off).
- `password_policy_maxrepeat` max consecutive identical chars (default `0` - off).
- `password_policy_maxclassrepeat` max consecutive same-class chars (default `0` - off).
- `password_policy_gecoscheck` reject passwords containing GECOS-field words (default `0` - off).
