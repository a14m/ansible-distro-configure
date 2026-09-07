# Ansible Distro Configure Playbooks

Ansible roles and playbooks to configure different *nix distros.

## Prerequisite

- [mise][mise] — `mise install` then `uv sync` installs the pinned `ansible-core`/`ansible-lint`/`molecule`. Run
  commands via `uv run`, e.g. `uv run ansible-playbook site.yml --ask-become-pass`.
- [`git-crypt`][git-crypt] optional, for encrypted `host_vars/*.yml`.

[mise]: https://mise.jdx.dev/
[git-crypt]: https://github.com/AGWA/git-crypt

Using `git-crypt`: set up your key, then override `host_vars/*.yml` with your own version.
Not using it: `rm .gitattributes && cp host_vars/laptop.local.yml.example host_vars/laptop.local.yml` (per host).

## Playbook: distro-install

Check [`distro-install`](https://git.sr.ht/~a14m/ansible-distro-install).

## Playbook: distro-configure

1. Configure SSH login (user/key/port) for `username` in `~/.ssh/config`.
2. Install ansible dependencies, configure `host_vars`, run the playbook.

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

Pi-hole and WireGuard Portal run directly on `rpi5.local`:

| Service | `*.home.arpa` (direct, no TLS) | `*.internal` (proxied, with TLS) | Description |
|---|---|---|---|
| Pi-hole | [`dns.home.arpa`](http://dns.home.arpa:8081/) | [`dns.internal`](https://dns.internal) | DNS filtering and ad blocking |
| WireGuard Portal | [`vpn.home.arpa`](http://vpn.home.arpa:8080/) | [`vpn.internal`](https://vpn.internal) | WireGuard VPN management UI |
| Garage S3 API | [`s3.home.arpa`](http://s3.home.arpa:3900/) | [`s3.internal`](https://s3.internal) | Garage S3-compatible object store API |
| Garage webui | [`s3.home.arpa`](http://s3.home.arpa:3909/) | [`web.s3.internal`](https://web.s3.internal) | Garage S3-compatible object store admin UI |

Override the `*.internal` names with `pihole_hostname`/`wg_portal_hostname`/`garage_hostname`/`garage_webui_hostname`.

## Container Services

LXC containers on `pve.local`. FQDNs resolve via Pi-hole (`pihole_dns_hosts` in `host_vars/rpi5.local.yml`).

| Service | `*.home.arpa` (direct, no TLS) | `*.internal` (proxied, with TLS) | Description |
|---|---|---|---|
| Grafana | [`monitor.home.arpa`](http://monitor.home.arpa:3000/) | [`monitor.internal`](https://monitor.internal) | Metrics dashboards |
| Prometheus | [`metrics.home.arpa`](http://metrics.home.arpa:9090/) | [`metrics.internal`](https://metrics.internal) | Metrics collection |
| cgit | [`git.home.arpa`](http://git.home.arpa:3000/) | - | Git repository browsing and SSH push/clone |
| Radicale | [`caldav.home.arpa`](http://caldav.home.arpa:5232/.web/) | - | CalDAV/CardDAV server |
| Tailscale | `tailscale.home.arpa` | - | Tailscale subnet router (no HTTP vhost) |
| Loki | `logs.home.arpa` | - | Log aggregation (no HTTP vhost; queried directly on port 3100) |
| Wallos | [`subscriptions.home.arpa`](http://subscriptions.home.arpa:8282/) | [`subscriptions.internal`](https://subscriptions.internal) | Subscription/recurring-cost tracker |
| CouchDB | `notes.home.arpa` | [`notes.internal`](https://notes.internal) | Backend for Obsidian LiveSync (`obsidian-livesync` role, on `desktop`/`laptop`/`macbook`) |
| Proxmox VE | [`pve.local`](https://pve.local:8006/) | [`vm.internal`](https://vm.internal) | PVE hypervisor web UI (runs on `pve.local` itself, not an LXC; override with `pve_hostname`) |

`*.home.arpa` always resolves straight to a container's own IP - direct, plain HTTP, no vhost. `*.internal` goes
through the centralized Caddy on `proxy.home.arpa` instead: no port, self-signed TLS via Caddy's internal CA
(`.internal` is IANA-reserved for this, per RFC 9476). Override `*.internal` names with `grafana_hostname` /
`prometheus_hostname` / `wallos_hostname` etc.

`cgit_hostname`/`radicale_hostname` can be set to a public domain instead, for access outside the LAN via the
`cloudflared` tunnel (`cgit_clone_prefix` then keeps the LAN clone URL separate). Loki has no vhost at all - reached
directly at `http://logs.home.arpa:3100`, since only Grafana/Alloy on the LAN ever query it.

## Trusting the Internal CA

`*.internal` sites get their TLS cert from Caddy's own local CA (`local_certs`), not a public one - so devices show
a self-signed warning until they trust that CA once. The `caddy-ca` role exposes it for download at
`http://proxy.home.arpa/certificate` (plain HTTP - fetching the cert has to work before anything is trusted yet).

Visit that URL on the device (same LAN, or via the `tailscale.home.arpa` subnet router): **desktop** imports the
file into the OS/browser trust store (Firefox uses its own, not the OS's); **mobile** prompts to install a profile -
iOS needs Safari specifically, plus a manual follow-up toggle (Settings → General → About → Certificate Trust
Settings → enable full trust). See `roles/caddy-ca/README.md` for the mechanism and full per-platform steps.

Verify by visiting `https://*.internal` afterward and checking the padlock shows secure.

## Firewall

Every host runs `ufw` (`roles/ufw`), deny-all inbound by default, with explicit allow rules via each host's
`ufw_rules`. **Every host's `ufw_rules` must include its own `ssh_port` allow entry** - no implicit default, and
applying the role without one locks that host out over SSH (recoverable only via `pve.local`'s console for LXCs, or
physical/BMC console otherwise). Copy the SSH entry from an existing `host_vars/*.yml` when adding a new host.

Beyond SSH, most container admin UIs only allow `proxy.home.arpa` as the source, not the whole LAN. For direct
browser access to a locked-down service, use an SSH local port forward instead of widening the firewall rule:

```bash
ssh -L 8080:localhost:5232 caldav.home.arpa
# then open http://localhost:8080/.web/ in your browser
```

Works for any host/port with no firewall change - the service is always reachable from itself over loopback, `ufw`
only filters inbound network traffic, and the tunnel only lives as long as the SSH session.

## Special Thanks to

- [Jeff Geerling](https://www.jeffgeerling.com/), who I learned a **LOT** from his open-source work.
