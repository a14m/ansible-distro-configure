# Headscale Role

Self-hosted Tailscale control server. Alpine (apk edge/community) or Debian/Ubuntu (`.deb`). Serves plain
HTTP on `headscale_port` - a reverse proxy in front terminates TLS (Caddy; not Cloudflare Tunnel, it strips
the control protocol's `Upgrade` header).

## Required Variables

```yaml
headscale_hostname: "hs.example.com"
headscale_acme_email: "you@example.com"
headscale_acme_cloudflare_api_token: "..."   # Zone.DNS:Edit scoped to the zone owning headscale_hostname
```

## Notes

- `headscale_hostname` drives both `server_url` and the proxy vhost that terminates TLS for it. The
  vhost uses a real Let's Encrypt cert (via the `acme` role, DNS-01 - no inbound port needed), not
  Caddy's internal CA, so clients trust it with no manual step.
- Reachable from outside the LAN over IPv6 only. IPv4 port-forwarding hit a Fritzbox NAT bug
  (return packets get re-sourced to a random port after the handshake, in every forwarding mode
  tried, on current firmware) - IPv6 has no NAT to hit that bug in, so the vhost's AAAA record
  is what carries external/cellular traffic. Needs `network_ipv6_method: "auto"` on the Proxmox
  host (`roles/network`) and a matching AAAA record; IPv4 access stays LAN-only.
- DERP uses Tailscale's public mesh - no port forward needed.
- MagicDNS is off - clients here run `--accept-dns=false`, use Pi-hole instead.
- `headscale_users` are created if missing; preauth keys aren't - mint manually (below).
- `headscale_policy_auto_approve_routes` auto-approves subnet routes + exit-node for a reserved
  "headscale" user this role always creates.

## Enrolling a Device

Run on the headscale host (SSH in first):

```bash
headscale users list  # find the user's numeric id
headscale preauthkeys create --user <id> --reusable --expiration 90d
```

Then on the client:

```bash
tailscale up --login-server=https://hs.example.com --authkey=<key>
```
