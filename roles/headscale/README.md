# Headscale Role

Self-hosted Tailscale control server. Alpine (apk edge/community) or Debian/Ubuntu (`.deb`). Serves plain
HTTP on `headscale_port` - a reverse proxy in front terminates TLS (not Cloudflare Tunnel, it breaks the
control protocol; Caddy works fine).

## Required Variables

```yaml
headscale_server_url: "https://hs.example.com"
```

## Notes

- DERP uses Tailscale's public mesh - no port forward needed.
- MagicDNS is off - clients here run `--accept-dns=false`, use Pi-hole instead.
- `headscale_users` are created if missing; mint preauth keys manually:
  `headscale preauthkeys create --user <numeric id> --reusable --expiration 90d`.
- `headscale_policy_auto_approve_routes` auto-approves subnet routes + exit-node for a reserved
  "headscale" user this role always creates.
