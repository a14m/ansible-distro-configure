# Ansible Role

This role manages multiple versions of ansible-core and molecule using pipx,
allowing you to install different versions side-by-side and switch between them easily.

## Variables

### Required Variables

**Ansible-core:**

- `ansible_core_versions`: List of ansible-core versions to install
- `ansible_core_default_version`: The version to use as default (must be in the versions list)

**Molecule:**

- `molecule_versions`: List of molecule versions to install
- `molecule_default_version`: The version to use as default (must be in the versions list)

### Example Configuration

```yaml
ansible_core_versions:
  - "2.18.7"
ansible_core_default_version: "2.18.7"

molecule_versions:
  - "25.7.0"
molecule_default_version: "25.7.0"
```

## Usage

### Installed Commands

After running this role, you'll have:

**Ansible version-specific commands:**

- `ansible2.18.7`, `ansible-playbook2.18.7`, `ansible-galaxy2.18.7`, etc.

**Molecule version-specific commands:**

- `molecule25.7.0` (includes docker and podman drivers via molecule-plugins)

**Default commands (symlinked to default version):**

- `ansible` → `ansible2.18.7`
- `ansible-playbook` → `ansible-playbook2.18.7`
- `ansible-galaxy` → `ansible-galaxy2.18.7`
- `molecule` → `molecule25.7.0`
- And all other ansible commands

### Switching Default Version

To switch the default version:

1. Update `ansible_core_default_version` and/or `molecule_default_version` in your variables
2. Re-run the playbook

The symlinks will be updated to point to the new default versions.

## Manual Cleanup

This role does not automatically remove unused versions. To manually clean up old installations:

### List installed versions

```bash
pipx list --short
```

### Remove specific versions

```bash
# Remove ansible-core versions
pipx uninstall ansible-core2.18.0

# Remove molecule versions
pipx uninstall molecule25.7.0
```

## Requirements

- pipx must be installed and available at `/home/linuxbrew/.linuxbrew/bin/pipx`
- The `community.general` Ansible collection for the pipx module

These requirements are satisfied with the `homebrew` and `python` roles (added as dependencies)

## Example Playbook

```yaml
- hosts: all
  roles:
    - role: ansible
      vars:
        ansible_core_versions:
          - "2.18.7"
          - "2.19.1"
        ansible_core_default_version: "2.19.1"
```
