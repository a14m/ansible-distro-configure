# Ansible RC Playbooks

Ansible roles and playbooks to install different distros and configure `.rc`.

## Prerequisite

- [Ansible][ansible]
- [`sshpass`][sshpass] **required** for `--ask-pass`
- [`git-crypt`][git-crypt] **optional** for keeping encrypted configurations.

[sshpass]: https://man.freebsd.org/cgi/man.cgi?query=sshpass
[ansible]: https://docs.ansible.com/ansible/latest/index.html
[git-crypt]: https://github.com/AGWA/git-crypt

If you are using `git-crypt`, setup your key, and override the encrypted files (`host_vars/*.yml`)
with your own version.

If you are not using `git-crypt`, delete the `.gitattributes` file and override the encrypted files
with your own version.
Ex. `rm .gitattributes && cp host_vars/ubuntuiso.local.yml.example host_vars/ubuntuiso.local.yml`

## Boot distro live image

- [Arch Linux](./archlinux.md)
- [Debian Ubuntu](./ubuntu.md)

## Playbook: distro-install

- Optional: Clone the [`distro-configure`](https://git.sr.ht/~a14m/ansible-distro-configure) playbook
- Optional: Configure the desired `host_vars` in the `distro-configure` playbook
- Follow the pre-install guides for desired distro in "Boot distro live image"
- Install ansible required dependencies
- Configure the desired `host_vars` in this playbook
- Run the playbook

**Example**:

```bash
git clone https://git.sr.ht/~a14m/ansible-distro-configure /opt/distro-configure
cp /opt/distro-configure/host_vars/${DISTRO}.local.yml.example /opt/distro-configure/host_vars/${DISTRO}.local.yml

git clone https://git.sr.ht/~a14m/ansible-distro-install /opt/distro-install
cp /opt/distro-install/host_vars/${DISTRO}iso.local.yml.example /opt/distro-install/host_vars/${DISTRO}iso.local.yml

ansible-galaxy install -r requirements.yml
cd /opt/distro-install

ansible-playbook site.yml --ask-pass --extra-vars '{"configure_playbook_dir":"/opt/distro-configure"}'
```

## Special Thanks to

- [Jeff Geerling](https://www.jeffgeerling.com/), who I learned a **LOT** from his open-source work.
