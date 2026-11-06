# Ansible Role: wireguard

Deploys WireGuard configs. Needs the WireGuard kernel module and systemd.

## Role Variables

- `wireguard_connections` dict of `name: config` (raw `wg-quick` file contents) (default: `{}`).

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
```

## Notes

- The role owns `/etc/wireguard/wg-*.conf` entirely: files are overwritten in place (no backup), and any
  `wg-<name>.conf` not present in `wireguard_connections` is deleted.
- The role never starts or enables tunnels. Use `systemctl start wg-quick@wg-<name>`, or have a service that needs
  the tunnel pull it in (`Requires=`/`BindsTo=wg-quick@wg-<name>.service`).
