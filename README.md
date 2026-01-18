# Ansible Distro Configure Playbooks

Ansible roles and playbooks to configure different *nix distros.

## Prerequisite

- [Ansible][ansible]
- [`git-crypt`][git-crypt] **optional** for keeping encrypted configurations.

[ansible]: https://docs.ansible.com/ansible/latest/index.html
[git-crypt]: https://github.com/AGWA/git-crypt

If you are using `git-crypt`, setup your key, and override the encrypted files (`host_vars/*.yml`)
with your own version.

If you are not using `git-crypt`, delete the `.gitattributes` file and override the encrypted files
with your own version.
Ex. `rm .gitattributes && cp host_vars/ubuntuiso.local.yml.example host_vars/ubuntuiso.local.yml`

## Playbook: distro-install

Check [`distro-install`](https://git.sr.ht/~a14m/ansible-distro-install) playbook

## Playbook: distro-configure

- Configure the ssh login (user/key/port/etc) in your `~/.ssh/config` for the `username` you want to run.
- Install ansible required dependencies
- Configure the desired `host_vars` in this playbook
- Run the playbook

**Example**:

```bash
tee ~/.ssh/config << EOF
Host *.local
  User u53rnam3
  Port 1337
  ForwardAgent yes
  StreamLocalBindUnlink yes
EOF

git clone https://git.sr.ht/~a14m/ansible-distro-configure /opt/distro-configure
cp /opt/distro-configure/host_vars/${DISTRO}.local.yml.example /opt/distro-configure/host_vars/${DISTRO}.local.yml

cd /opt/distro-configure
ansible-galaxy install -r requirements.yml

ansible-playbook site.yml --ask-become-pass
```

## Special Thanks to

- [Jeff Geerling](https://www.jeffgeerling.com/), who I learned a **LOT** from his open-source work.
