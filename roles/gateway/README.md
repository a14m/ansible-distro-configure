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
- **Client Configuration**: Devices must use Pi as default gateway (192.168.1.254)
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
iptables -L -n -v
iptables -t nat -L -n -v

# Check WireGuard interface detection
ip link show | grep wg

# Test traffic routing
curl -4 ifconfig.co  # Should show VPN IP when VPN active
curl -6 ifconfig.co  # Should show VPN IPv6 when VPN active
```
