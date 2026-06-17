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
with your own version.<br>
Ex. `rm .gitattributes && cp host_vars/laptop.local.yml.example host_vars/laptop.local.yml`

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
cp /opt/distro-configure/host_vars/${HOSTNAME}.yml.example /opt/distro-configure/host_vars/${HOSTNAME}.yml

cd /opt/distro-configure
ansible-galaxy install -r requirements.yml

ansible-playbook site.yml --ask-become-pass --limit ${HOSTNAME}
```

## Raspberry Pi Services

Services deployed on `rpi5.local` and their default FQDNs (resolved via Pi-hole DNS):

| Service | Default FQDN | Description |
|---|---|---|
| Pi-hole | `dns.home.arpa` | DNS filtering and ad blocking |
| WireGuard Portal | `vpn.home.arpa` | WireGuard VPN management UI |
| Grafana | `monitor.home.arpa` | Metrics dashboards |
| Prometheus | `metrics.home.arpa` | Metrics collection |

DNS records are managed via `pihole_dns_hosts` in `host_vars/rpi5.local.yml`.
Override the default FQDN per service using `pihole_hostname`, `wg_portal_hostname`,
`grafana_hostname`, or `prometheus_hostname`.

## Special Thanks to

- [Jeff Geerling](https://www.jeffgeerling.com/), who I learned a **LOT** from his open-source work.
