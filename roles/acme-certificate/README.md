# ACME Certificate Role

Obtains a Let's Encrypt certificate on `vhost_proxy_host` via Cloudflare DNS-01 - no inbound port needed.
Included by the role that needs it, like `vhost`. Uses `acme.sh` (from the `acme-sh` role in the proxy's play),
not a Caddy plugin build, so the consuming service keeps its stock package. acme.sh's cron job renews it.

## Required Variables

```yaml
acme_certificate_domain: "hs.example.com"
acme_certificate_email: "you@example.com"
acme_certificate_cloudflare_api_token: "..."   # Zone.DNS:Edit scoped to the zone owning the domain
acme_certificate_group: "caddy"                # consuming service's group - no default
```

## Notes

- Certs land at `acme_certificate_dir/<domain>.{fullchain,key}.pem` - one shared `0755` directory for every
  domain, access controlled per-file (`0640`, group per-domain).
- `acme_certificate_reload_command` is derived from `vhost_proxy_type` - only pass it for a non-vhost consumer.
- Only OS-independent tasks, all delegated: delegation keeps the caller's facts, so anything OS-specific lives
  in `acme-sh`. Fails early if acme.sh isn't installed on the proxy.
- `acme_certificate_email` registers the proxy's single Let's Encrypt account on first issue; later issues reuse
  it. Change it with `acme.sh --update-account --email ...` on the proxy.
