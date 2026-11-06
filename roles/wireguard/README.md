# Ansible Role: wireguard

Deploys WireGuard configs. Needs the WireGuard kernel module and systemd.

## Role Variables

- `wireguard_connections` dict of `name: config` (raw `wg-quick` file contents) (default: `{}`). `name` is used as is
  for `/etc/wireguard/<name>.conf` and the interface (max 15 characters, must start with `wg`: the `gateway` role
  only handles `wg*` interfaces).
- `wireguard_autostart_connection` name of the connection to enable at boot and start (default: unset, starts none).

## Example

```yaml
wireguard_connections:
  wg-proton-ch1: |
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

- The role owns `/etc/wireguard/*.conf` entirely: files are overwritten in place (no backup), and any
  `<name>.conf` not present in `wireguard_connections` is deleted.
- Only `wireguard_autostart_connection` is enabled and started; other tunnels are never started, stopped or disabled.
  A name missing from `wireguard_connections` fails the start (no config file). Config changes need a manual
  `systemctl restart wg-quick@<name>`.
