# Ansible Distro Configure Playbooks

Ansible roles and playbooks to configure different *nix distros.

## Prerequisite

- [mise][mise] - `mise install` then `uv sync` installs the pinned `ansible-core` / `ansible-lint` / `molecule`.
  Run via `uv run`, e.g. `uv run ansible-playbook site.yml --ask-become-pass`.
- [`git-crypt`][git-crypt] - optional, for encrypted `host_vars/*.yml`. Not using it:
  `rm .gitattributes && cp host_vars/laptop.local.yml.example host_vars/laptop.local.yml` (per host).

[mise]: https://mise.jdx.dev/
[git-crypt]: https://github.com/AGWA/git-crypt

## Playbook: distro-install

See [`distro-install`](https://git.sr.ht/~a14m/ansible-distro-install).

## Playbook: distro-configure

Configure SSH login (user/key/port) for `username` in `~/.ssh/config`, then:

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

## Services

`*.home.arpa` resolves straight to a host's own IP - direct, plain HTTP, no vhost. `*.internal` goes through the
central Caddy on `proxy.home.arpa` - no port, self-signed TLS via Caddy's internal CA (`.internal` is IANA-reserved
for this, RFC 9476). Override any `*.internal` name with the role's `*_hostname` var. FQDNs resolve via Pi-hole
(`pihole_dns_hosts` in `host_vars/rpi5.local.yml`).

### On `rpi5.local`

| Service | `*.home.arpa` | `*.internal` | Description |
|---|---|---|---|
| Pi-hole | [`dns.home.arpa`](http://dns.home.arpa:8081/) | [`dns.internal`](https://dns.internal) | DNS filtering and ad blocking |
| WireGuard Portal | [`vpn.home.arpa`](http://vpn.home.arpa:8080/) | [`vpn.internal`](https://vpn.internal) | WireGuard VPN management UI |
| Garage S3 API | [`s3.home.arpa`](http://s3.home.arpa:3900/) | [`s3.internal`](https://s3.internal) | S3-compatible object store API |
| Garage webui | [`s3.home.arpa`](http://s3.home.arpa:3909/) | [`web.s3.internal`](https://web.s3.internal) | Garage admin UI |

### LXC containers on `pve.local`

| Service | `*.home.arpa` | `*.internal` | Description |
|---|---|---|---|
| Grafana | [`monitor.home.arpa`](http://monitor.home.arpa:3000/) | [`monitor.internal`](https://monitor.internal) | Metrics dashboards |
| Prometheus | [`metrics.home.arpa`](http://metrics.home.arpa:9090/) | [`metrics.internal`](https://metrics.internal) | Metrics collection |
| cgit | [`git.home.arpa`](http://git.home.arpa:3000/) | - | Git browsing and SSH push/clone |
| Radicale | [`caldav.home.arpa`](http://caldav.home.arpa:5232/.web/) | - | CalDAV/CardDAV server |
| Tailscale | `tailscale.home.arpa` | - | Tailscale subnet router (no HTTP vhost) |
| Loki | `logs.home.arpa` | - | Log aggregation (queried directly on port 3100) |
| Wallos | [`subscriptions.home.arpa`](http://subscriptions.home.arpa:8282/) | [`subscriptions.internal`](https://subscriptions.internal) | Subscription/recurring-cost tracker |
| CouchDB | `notes.home.arpa` | [`notes.internal`](https://notes.internal) | Backend for Obsidian LiveSync |
| Proxmox VE | [`pve.local`](https://pve.local:8006/) | [`vm.internal`](https://vm.internal) | PVE hypervisor web UI (on `pve.local` itself) |

`cgit_hostname` / `radicale_hostname` can instead be a public domain, for access outside the LAN via the
`cloudflared` tunnel (`cgit_clone_prefix` keeps the LAN clone URL separate).

## Trusting the Internal CA

`*.internal` certs come from Caddy's local CA, so devices warn until they trust it once. The `caddy-ca` role serves
it at `http://proxy.home.arpa/certificate` (plain HTTP - it has to work before anything is trusted). Open that URL
on the device (LAN or via the `tailscale.home.arpa` subnet router) and import it; on macOS an explicit
"Always Trust" is required. Full per-platform steps in `roles/caddy-ca/README.md`.

## Firewall

Every host runs `ufw` (`roles/ufw`), deny-all inbound, with explicit `ufw_rules` per host. **Every host's
`ufw_rules` must include its own `ssh_port` allow entry** - there's no implicit default, and applying the role
without one locks the host out over SSH (recover via `pve.local`'s console for LXCs, physical/BMC console
otherwise). Copy the SSH entry from an existing `host_vars/*.yml`.

Most container admin UIs only allow `proxy.home.arpa` as source. For direct browser access to a locked-down
service, use an SSH local forward instead of widening the rule:

```bash
ssh -L 8080:localhost:5232 caldav.home.arpa   # then open http://localhost:8080/.web/
```

## Special Thanks

- [Jeff Geerling](https://www.jeffgeerling.com/), whose open-source work I learned a **LOT** from.
