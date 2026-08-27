# Ansible Distro Configure Playbooks

Ansible roles and playbooks to configure different *nix distros.

## Prerequisite

- [mise][mise] — run `mise install` to get `uv`, then `uv sync` to install the pinned
  `ansible-core`/`ansible-lint`/`molecule` (see `pyproject.toml`). Invoke commands via
  `uv run`, e.g. `uv run ansible-playbook site.yml --ask-become-pass`.
- [`git-crypt`][git-crypt] **optional** for keeping encrypted configurations.

[mise]: https://mise.jdx.dev/
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

Pi-hole and WireGuard Portal run directly on `rpi5.local`:

| Service | `*.home.arpa` (direct, no TLS) | `*.internal` (via proxy, TLS) | Description |
|---|---|---|---|
| Pi-hole | `dns.home.arpa` | `dns.internal` | DNS filtering and ad blocking |
| WireGuard Portal | `vpn.home.arpa` | `vpn.internal` | WireGuard VPN management UI |
| Garage webui | `s3.home.arpa` | `s3.internal` | Garage S3-compatible object store admin UI |

Override the default hostnames with `pihole_hostname`/`wg_portal_hostname`/`garage_webui_hostname` (the `*.internal` name) -
the `*.home.arpa` alias to `rpi5.local` itself is a separate, fixed entry in `pihole_dns_hosts`.

## Container Services

Services deployed as LXC containers on `pve.local`. FQDNs resolve via Pi-hole
(`pihole_dns_hosts` in `host_vars/rpi5.local.yml`).

| Service | `*.home.arpa` (direct, no TLS) | `*.internal` (via proxy, TLS) | Description |
|---|---|---|---|
| Grafana | `monitor.home.arpa` | `monitor.internal` | Metrics dashboards |
| Prometheus | `metrics.home.arpa` | `metrics.internal` | Metrics collection |
| cgit | `git.home.arpa` | - | Git repository browsing and SSH push/clone |
| Radicale | `caldav.home.arpa` | - | CalDAV/CardDAV server |
| Tailscale | `tailscale.home.arpa` | - | Tailscale subnet router (no HTTP vhost) |
| Loki | `logs.home.arpa` | - | Log aggregation (no HTTP vhost; queried directly on port 3100) |
| Wallos | `subscriptions.home.arpa` | `subscriptions.internal` | Subscription/recurring-cost tracker |
| Proxmox VE | - | `vm.internal` | PVE hypervisor web UI (runs on `pve.local` itself, not an LXC) |

Proxmox VE is the one entry above that isn't an LXC guest - it's `pve.local` itself. Its `8006`
backend is HTTPS-only with a self-signed cert, so its `*.internal` vhost skips upstream cert
verification instead of proxying plain HTTP like the others. Override the name with
`pve_hostname`.

For every service, `*.home.arpa` always resolves straight to that container's own IP - useful for
direct access, but plain HTTP only (no vhost behind it for Grafana/Prometheus, since their Caddy
vhost lives on the separate `proxy.home.arpa` host). `*.internal` is the new, unified way to reach
a service through the single centralized Caddy on `proxy.home.arpa`: no port, self-signed TLS via
Caddy's internal CA (`.internal` is IANA-reserved for exactly this per RFC 9476, safer than an
unreserved `.lan`). Override the `*.internal` name with `grafana_hostname`/`prometheus_hostname`/
`wallos_hostname`.

`cgit_hostname` and `radicale_hostname` can instead be set to a public domain for access outside
the LAN via the `cloudflared` tunnel on `proxy.home.arpa`; `cgit_clone_prefix` then keeps the LAN
clone URL separate. Loki has no reverse-proxy vhost - `logs.home.arpa` resolves straight to its
LXC's own IP, and it's reached at `http://logs.home.arpa:3100` (or by IP), since it's only ever
consumed by Grafana and Alloy on the LAN, not exposed externally.

## Firewall

Every host runs `ufw` (`roles/ufw`) with deny-all inbound by default, plus explicit allow
rules per flow, set via `ufw_rules` in each host's `host_vars/*.yml`. There is no implicit
default: **every host's `ufw_rules` must include its own explicit `ssh_port` allow entry**,
or applying the role locks that host out over SSH (recoverable only via `pve.local`'s
console for LXCs, or physical/BMC console otherwise). Copy the SSH entry from an existing
`host_vars/*.yml` when adding a new host.

Beyond SSH, most container admin UIs only allow `proxy.home.arpa` as the source, not the
whole LAN.

If you need direct browser access to a locked-down service - debugging with the proxy
down, or just poking at something without going through the vhost - use an SSH local port
forward instead of widening the firewall rule:

```bash
ssh -L 8080:localhost:5232 caldav.home.arpa
# then open http://localhost:8080/.web/ in your browser
```

This works for any host/port and doesn't require any firewall change: the service is
always reachable from itself over loopback, `ufw` only filters inbound traffic from the
network, and the tunnel only exists for as long as the SSH session is open.

## Special Thanks to

- [Jeff Geerling](https://www.jeffgeerling.com/), who I learned a **LOT** from his open-source work.
