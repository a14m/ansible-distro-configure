# Gateway Role

Makes a host (typically the Pi) a NAT gateway for the local subnet, switching the exit path between a WireGuard
tunnel ("VPN mode") and the ISP router ("direct mode") based on whether a `wg*` interface is up. Pair with the
`wireguard` and `wg_portal` roles.

## Required Variables

```yaml
gateway_enabled: true
gateway_local_ipv4_subnet: "192.168.1.0/24"
gateway_router_interface: "end0"
```

## Requirements

- WireGuard interfaces named `wg*` (`wg0`, `wg-us1`, …).
- Client devices using the gateway as their default route.
- Kernel IP forwarding enabled (`net.ipv4.ip_forward=1`).
- WireGuard configs using default routing (`Table=auto` or unset, **not** `Table=off`).

## Operation

A udev rule (`/etc/udev/rules.d/99-wireguard-gateway.rules`) triggers `gateway-vpn-mode.service` /
`gateway-direct-mode.service` on `wg*` up/down, each running `/usr/local/bin/gateway-apply-rules <vpn|direct>`.

```bash
systemctl status gateway-vpn-mode.service
journalctl -u gateway-vpn-mode.service -f
/usr/local/bin/gateway-apply-rules vpn        # apply manually

sudo iptables -L -n -v && sudo iptables -t nat -L -n -v
curl -4 ifconfig.co                           # shows the VPN IP when VPN mode is active
```
