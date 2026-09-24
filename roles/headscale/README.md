# Headscale Role

Self-hosted Tailscale control server. Alpine (apk edge/community) or Debian/Ubuntu (`.deb`). Serves plain
HTTP on `headscale_port` - a reverse proxy in front terminates TLS (Caddy; not Cloudflare Tunnel, it strips
the control protocol's `Upgrade` header).

## Required Variables

```yaml
headscale_hostname: "hs.example.com"
```

## Notes

- `headscale_hostname` drives both `server_url` and the proxy vhost that terminates TLS for it,
  using Caddy's default internal CA - clients must trust that CA.
- LAN-only for now - exposing it via the home router's port-forward hit a Fritzbox NAT bug
  (return packets get re-sourced to a random port after the handshake, in every forwarding mode
  tried, on current firmware).
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
