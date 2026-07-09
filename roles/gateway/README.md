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

IPv6 gateway is enabled by setting `gateway_local_ipv6_subnet` to the ULA prefix advertised by radvd:

```yaml
gateway_local_ipv6_subnet: "fd00:xxxx:xxxx:xxxx::/64"  # ULA prefix (stable, router-independent)
```

When set, this role:
- Enables `net.ipv6.conf.all.forwarding=1` and `accept_ra=2` on `gateway_router_interface`
- Deploys radvd advertising the ULA prefix with `AdvDefaultPreference high` — Pi wins as IPv6 default router
- Adds ip6tables MASQUERADE/FORWARD rules so all client IPv6 traffic is forwarded through Pi
- Drops outbound ICMPv6 Redirect messages — prevents Pi from redirecting clients to bypass the gateway

**ICMPv6 Redirect suppression is critical.** Pi, the ISP router (FritzBox), and LAN clients share the same L2
segment. When Pi forwards a packet to an external destination and the kernel determines the ISP router is a
"better" next-hop on the same link, it sends an ICMPv6 Redirect to the client. The client then sends
subsequent connections directly to the ISP router — bypassing Pi's masquerade and content filtering entirely.
The first connection attempt fails (Pi forwarded nothing, just redirected), giving the symptom of "first
request fails every ~30-60s." Dropping Redirect messages in ip6tables OUTPUT fixes this.

To disable IPv6, leave `gateway_local_ipv6_subnet: ""` (default). The role skips all ip6tables rules and disables radvd.

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
- Most VPN providers handle IPv4/IPv6 protocol routing automatically

**Direct Mode Characteristics:**

- IPv4 traffic NAT'd through router interface (`end0`)
- IPv6 traffic masqueraded through router interface — clients appear as Pi's GUA to the ISP router,
  preventing ISP-router-level content filtering from applying per-device rules
- ICMPv6 Redirects suppressed so clients always route through Pi

## IPv6 Architecture Notes

### Why masquerade IPv6 in direct mode?

Clients have globally routable GUA addresses (assigned by ISP router SLAAC). Without masquerade, the ISP
router sees each client's real GUA and can apply per-device content filtering. With masquerade, all client
traffic appears to originate from Pi's GUA — bypassing per-device filtering consistently.

### Why suppress ICMPv6 Redirects?

When Pi, the ISP router, and clients share the same L2 segment (single broadcast domain), the Linux kernel
sends ICMPv6 Redirect messages when it detects a "better" next-hop for a destination on the same link. For
external GUA destinations reachable via the ISP router directly, Linux redirects clients from Pi to the ISP
router. This causes:
1. First SYN from client arrives at Pi — Pi sends Redirect, does NOT forward the packet
2. Client receives Redirect, caches ISP router as next-hop for that destination
3. Subsequent connections go directly to ISP router — masquerade and filtering bypassed

Dropping `icmpv6-type redirect` in ip6tables OUTPUT prevents this entirely.

### Why radvd with `AdvDefaultPreference high`?

The ISP router (FritzBox) also sends RAs with default preference `medium` (or `low` if configured).
Pi's radvd sends `AdvDefaultPreference high`, so clients prefer Pi as their IPv6 default router.
Without this, clients split or prefer the ISP router depending on RA timing.

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
sudo iptables -L -n -v
sudo iptables -t nat -L -n -v

# Verify ip6tables rules (redirect DROP must be first in OUTPUT)
sudo ip6tables -L OUTPUT -n -v --line-numbers
sudo ip6tables -t nat -L -n -v

# Confirm no ICMPv6 Redirects being sent
sudo tcpdump -i end0 -n 'icmp6 and ip6[40] == 137'

# Verify clients route through Pi (not ISP router)
# On client: ip -6 route show default
# On Pi: sudo tcpdump -i end0 -n -e ip6 and host <client-GUA>

# Test traffic routing
curl -4 ifconfig.co  # Should show VPN IP when VPN active
curl -6 ifconfig.co  # Should show Pi's GUA in direct mode, VPN IPv6 in VPN mode
```
