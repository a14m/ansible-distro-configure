# Ansible Role: ansible

Installs multiple ansible-core and molecule versions side-by-side via `uv tool` (through `mise`), with
version-suffixed commands and symlinked defaults. Also installs `ansible_lint_version`. Requires `mise`/`uv` and
`python` (from the `python` role).

## Variables

- `ansible_core_versions` / `molecule_versions` lists of versions to install.
- `ansible_core_default_version` / `molecule_default_version` the default (must be in the matching list).
- `ansible_lint_version` ansible-lint version to install.

```yaml
ansible_core_versions: ["2.18.7", "2.19.1"]
ansible_core_default_version: "2.19.1"
molecule_versions: ["25.7.0"]
molecule_default_version: "25.7.0"
```

## Notes

- Per-version commands: `ansible2.19.1`, `ansible-playbook2.19.1`, `molecule25.7.0`, etc. (molecule includes the
  docker and podman drivers).
- Bare `ansible`, `ansible-playbook`, `ansible-galaxy`, `molecule`, … are symlinks to the default version.
- To switch default: change `*_default_version` and re-run; the symlinks are repointed.
