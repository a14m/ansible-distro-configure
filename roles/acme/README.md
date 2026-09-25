# ACME Role

Obtains and auto-renews a Let's Encrypt certificate via Cloudflare DNS-01 - no inbound port needed.
Uses `acme.sh` (pinned git clone, not `curl | sh`), not a Caddy plugin build, so the consuming
service keeps its stock package.

## Required Variables

```yaml
acme_domain: "hs.example.com"
acme_email: "you@example.com"
acme_cloudflare_api_token: "..."   # Zone.DNS:Edit scoped to the zone owning acme_domain
acme_cert_group: "caddy"           # consuming service's group - no default
```

## Notes

- Certs land at `acme_cert_dir/acme_domain.{fullchain,key}.pem` - one shared `0755` directory for
  every domain, access controlled per-file (`0640`, group per-domain).
- `acme_reload_command` is auto-derived from `vhost_proxy_type` (`caddy reload ...` or `nginx -s reload`) -
  only pass it explicitly for a non-vhost consumer.
- Always delegates to `vhost_proxy_host` - include it the same way callers include `vhost`.
- Includes `git`/`cron`/`openssl`/`curl` explicitly, not as `meta/main.yml` dependencies, since those
  wouldn't inherit the delegation.
