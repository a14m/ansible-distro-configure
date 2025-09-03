# Ansible Role: wireguard_gateway

This role configures a Linux host as a WireGuard VPN gateway,
routing all traffic from local network clients through the VPN connection.

## Role Variables

- `wireguard_gateway_enabled`: Boolean flag to enable/disable gateway functionality (default: `false`)

## What This Role Does

When `wireguard_gateway_enabled` is `true`, the role:

- Sets `net.ipv4.ip_forward=1` and `net.ipv6.conf.all.forwarding=1` in `/etc/sysctl.conf`
- Creates custom routing table (100) to route traffic through VPN
- Routes IPv4 and IPv6 traffic from local subnet through VPN interface
- Allows traffic forwarding and established connections

When `wireguard_gateway_enabled` is `false`, the role:

- Removes all routing rules and iptables configurations
- Disables IP forwarding in sysctl configuration
- Cleans up custom routing tables

## Example Configuration

```yaml
# In host_vars/gateway.yml
wireguard_gateway_enabled: true
wireguard_autostart_connection: "protonvpn-us-1"

# WireGuard connection configuration
wireguard_connections:
  protonvpn-us-1: |
    [Interface]
    PrivateKey = your_private_key_here
    Address = 10.2.0.2/32
    DNS = 10.2.0.1

    [Peer]
    PublicKey = server_public_key
    AllowedIPs = 0.0.0.0/0, ::/0
    Endpoint = vpn.example.com:51820
```

## Client Configuration

For client machines to route through the VPN gateway:

1. **IPv4**: Set gateway to VPN gateway host's IP
2. **IPv6**: Set IPv6 gateway to VPN gateway host's IPv6 address
3. **Manual network config**: Disable auto-configuration to use custom gateway

Example client network configuration:

```yaml
network_ipv4_address: "192.168.1.100"
network_ipv4_gateway: "192.168.1.254"  # VPN gateway host
network_ipv6_address: "2001:db8::100/64"
network_ipv6_gateway: "2001:db8::254"   # VPN gateway host
```

## Technical Details

### Routing Rules Created

```bash
# Policy routing rules (priority 200)
ip rule add iif eth0 table 100 priority 200
ip -6 rule add iif eth0 table 100 priority 200

# Custom routing table (table 100)
ip route add default dev wg-connection table 100
ip -6 route add default dev wg-connection table 100
```

### iptables Rules Created

```bash
# IPv4 NAT masquerading
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o wg-connection -j MASQUERADE

# IPv4 FORWARD rules
iptables -A FORWARD -s 192.168.1.0/24 -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# IPv6 equivalent rules
ip6tables -t nat -A POSTROUTING -s 2001:db8::/64 -o wg-connection -j MASQUERADE
ip6tables -A FORWARD -s 2001:db8::/64 -j ACCEPT
ip6tables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
```

## Troubleshooting

- **Check VPN connection**: `sudo wg show` should show active connection
- **Verify routing**: `ip rule show` and `ip route show table 100`
- **Test connectivity**: `curl ip.me` should show VPN IP from client machines
- **Check iptables**: `sudo iptables -t nat -L -n -v` should show masquerading rules
