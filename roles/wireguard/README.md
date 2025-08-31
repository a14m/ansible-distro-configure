# Ansible Role: wireguard

This role configures WireGuard VPN connections on the target host.

## Role Variables

- `wireguard_connections` a dictionary of WireGuard connection configurations (default: `{}`).
- `wireguard_autostart_connection` the name of the connection to automatically start on boot (default: `""`).

## Example Configuration

```yaml
wireguard_connections:
  protonvpn-ch-1: |
    [Interface]
    PrivateKey = your_private_key_here
    Address = 10.2.0.2/32
    DNS = 10.2.0.1

    [Peer]
    PublicKey = server_public_key_here
    AllowedIPs = 0.0.0.0/0
    Endpoint = server.endpoint:51820

wireguard_autostart_connection: "protonvpn-ch-1"
```

## Dependencies

This role requires:

- WireGuard kernel module support
- systemd for service management

## Usage

1. Define your WireGuard connection configurations in `wireguard_connections`
1. Optionally set `wireguard_autostart_connection` to auto-start a connection on boot
1. Run the role to deploy configurations and manage services

The role will:

- Install WireGuard packages
- Create configuration files in `/etc/wireguard/`
- Stop all existing connections
- Enable and start the autostart connection (if configured)

## Notes

- Configuration files are backed up before being overwritten
- Only one connection can be set to autostart
- All connections are stopped before starting the autostart connection
- If no autostart connection is configured, no connections will be automatically started
