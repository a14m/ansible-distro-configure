# Ansible Role: wireguard

Deploys WireGuard configs and manages their services. Needs the WireGuard kernel module and systemd.

## Role Variables

- `wireguard_connections` dict of `name: config` (raw `wg-quick` file contents) (default: `{}`).
- `wireguard_autostart_connection` name of the connection to start on boot; empty starts none (default: `""`).

## Example

```yaml
wireguard_connections:
  protonvpn-ch-1: |
    [Interface]
    PrivateKey = <key>
    Address = 10.2.0.2/32
    DNS = 10.2.0.1

    [Peer]
    PublicKey = <server key>
    AllowedIPs = 0.0.0.0/0
    Endpoint = server.endpoint:51820

wireguard_autostart_connection: "protonvpn-ch-1"
```

## Notes

- The role owns `/etc/wireguard/wg-*.conf` entirely: files are overwritten in place (no backup), and any
  `wg-<name>.conf` not present in `wireguard_connections` is deleted.
- All connections are brought down on every run; only `wireguard_autostart_connection` is then enabled and started.
- `wireguard_autostart_connection` must name a key in `wireguard_connections` or the run fails.
