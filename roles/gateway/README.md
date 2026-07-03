# Gateway Role

Configures a system as a network gateway with dynamic VPN routing capabilities.

## Overview

This role makes a system (typically Raspberry Pi) into a network gateway.
Paired with `wireguard`, and `wg-portal` roles, this can control network VPN transparently.

## Configuration

### Required Variables

```yaml
gateway_enabled: true
gateway_local_ipv4_subnet: "192.168.1.0/24"
gateway_router_interface: "end0"
```

### IPv6 Support (Optional)

IPv6 gateway is enabled by setting both `network_ipv6_address` and `gateway_local_ipv6_subnet`:

```yaml
network_ipv6_address: "2a02:xxxx:xxxx:xxxx::254/64"   # Pi's IPv6 address
gateway_local_ipv6_subnet: "2a02:xxxx:xxxx:xxxx::/64" # LAN IPv6 subnet (advertised via radvd)
```

When `network_ipv6_address` is defined, the role:
- Enables IPv6 forwarding (`net.ipv6.conf.all.forwarding=1`)
- Sets `accept_ra=2` on `gateway_router_interface` so Pi keeps receiving RAs from the router while forwarding
- Configures and starts `radvd` — Pi sends Router Advertisements to the LAN advertising itself as the IPv6 default gateway with `AdvDefaultPreference high`
- Announces Pi-hole (Pi's IPv6) as RDNSS so all devices use it for DNS over IPv6

This mirrors the IPv4 setup: all LAN devices (including phones) auto-configure Pi as their IPv6 gateway via SLAAC. No static configuration needed on clients.

To disable IPv6 entirely, remove `network_ipv6_address` and `gateway_local_ipv6_subnet` from `host_vars`. The role will:
- Omit `accept_ra` sysctl
- Skip IPv6 iptables masquerade rules
- Stop and disable radvd, remove its config
- Leave `net.ipv6.conf.all.forwarding=0`

**Note:** `accept_ra` is set per-interface (`gateway_router_interface`) only when IPv6 is enabled.
This prevents rogue RA acceptance on WireGuard and LAN interfaces.

**FritzBox:** Set RA priority to **Low** (Home Network → Network → IPv6 → Router advertisement → priority) so Pi's `high` priority RA wins. Pi becomes the sole IPv6 default gateway for all LAN devices.

## Network Architecture

```txt
Client Devices (192.168.1.0/24)
              ↓
┌─────────────────────────────┐
│    Raspberry Pi Gateway     │
│      (192.168.1.254)        │
└─────────────────────────────┘
              ↓
┌─────────────┬───────────────┐
│  VPN Mode   │ Direct Mode   │
│             │               │
│ WireGuard   │ ISP Router    │
│ Tunnel      │ (192.168.1.1) │
│ wg-*        │               │
└─────────────┴───────────────┘
        ↓              ↓
    VPN Server ────────┴───── Internet
```

**VPN Mode:**

- All traffic NAT'd through `wg+` interfaces
- Pi and client traffic both use VPN exit IP
- Most VPN providers IPv4/IPv6 protocol routing automatically

**Direct Mode Characteristics:**

- All traffic NAT'd through router interface (`end0`)
- Direct IPv4/IPv6 routing to ISP
- Standard internet routing

## Requirements

- **WireGuard Interfaces**: Must follow `wg*` naming pattern (`wg0`, `wg-us1`, etc.)
- **Client Configuration**: IPv4 devices use Pi as gateway via Pi-hole DHCP; IPv6 devices auto-configure via radvd RAs
- **IP Forwarding**: Kernel IP forwarding must be enabled (`net.ipv4.ip_forward=1`)
- **WireGuard Config**: Use default routing (`Table=auto` or unset, NOT `Table=off`)

## Operation

### Event-Based System

```bash
# Check udev rules
cat /etc/udev/rules.d/99-wireguard-gateway.rules

# Monitor VPN mode service
systemctl status gateway-vpn-mode.service
journalctl -u gateway-vpn-mode.service -f

# Monitor direct mode service
systemctl status gateway-direct-mode.service
journalctl -u gateway-direct-mode.service -f

# Test manual execution
/usr/local/bin/gateway-apply-rules vpn
/usr/local/bin/gateway-apply-rules direct
```

### Troubleshooting

```bash
# Verify iptables rules
sudo iptables -L -n -v
sudo iptables -t nat -L -n -v

# Check WireGuard interface detection
ip link show | grep wg

# Test traffic routing
curl -4 ifconfig.co  # Should show VPN IP when VPN active
curl -6 ifconfig.co  # Should show VPN IPv6 when VPN active
```
