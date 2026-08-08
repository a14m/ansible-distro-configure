# Ansible Role: network

This role configure the basic networking functionality of a linux distro

## Role Variables

- `network_wifi_ssid` the name of the WIFI network to be configured (default: "").
- `network_wifi_pass` the passphrase of the WIFI network to be configure (default: "").
- `network_ipv4_dns` DNS server to use. When set, DNS-over-TLS/DNSSEC are
  disabled (plain DNS to that server, e.g. Pi-hole). When left undefined,
  falls back to `1.1.1.1` with DNS-over-TLS and DNSSEC enforced.

## DNS resolution

This role configures NetworkManager with `dns=systemd-resolved`, then writes
the actual resolver settings (`DNS=`, `DNSSEC=`, `DNSOverTLS=`, caching) to
`/etc/systemd/resolved.conf.d/99-custom.conf`.

`/etc/resolv.conf` itself is explicitly force-symlinked to
`/run/systemd/resolve/stub-resolv.conf` (systemd-resolved's stub listener,
`127.0.0.53`) as part of this. This isn't redundant with NetworkManager's own
`dns=systemd-resolved` reconciliation — `/etc/resolv.conf` can start out
"foreign" (most commonly: a container runtime, e.g. Podman, writes its own
copy at container-creation time, before any of this role's tasks even run).
Once systemd-resolved sees `/etc/resolv.conf` isn't its own managed symlink,
it treats it as externally-owned and defers to it rather than reclaiming it -
silently making every setting above dead code, with resolution instead
falling through to whatever resolver the runtime happened to inject. This
was the actual root cause of an intermittent, hard-to-pin-down CI failure
("Temporary failure resolving archive.ubuntu.com") that looked like generic
network flakiness but reproduced 100% of the time once traced to this: the
container's DNS was never actually the one this role configures.

`pihole` (which runs on `rpi5.local` only) does its own separate, independent
override of both files afterward - it disables the stub entirely
(`DNSStubListener=no`) and points `/etc/resolv.conf` at
`/run/systemd/resolve/resolv.conf` (the raw upstream list, which by then just
contains `127.0.0.1`) so that host resolves through Pi-hole directly. That
override is unconditional and runs later in the pipeline, so it always wins
on that one host regardless of what this role configured first - the two
roles don't need to know about each other.
