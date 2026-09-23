# Headscale Role

Self-hosted Tailscale control server. Alpine (apk edge/community) or Debian/Ubuntu (`.deb`). Serves plain
HTTP on `headscale_port` - a reverse proxy in front terminates TLS (not Cloudflare Tunnel, it breaks the
control protocol; Caddy works fine).

## Required Variables

```yaml
headscale_server_url: "https://hs.example.com"
```

## Notes

- DERP relay uses Tailscale's public mesh - no port forward needed for it.
- MagicDNS is off (every `tailscale` client here runs `--accept-dns=false`, uses Pi-hole instead).
- `headscale_users` are created if missing; preauth keys aren't - mint manually:
  `headscale preauthkeys create --user <numeric id> --reusable --expiration 90d`.
- Point `tailscale` clients at it via `tailscale_login_server` + a preauth key.
