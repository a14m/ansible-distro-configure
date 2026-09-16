# Cloudflare DDNS Role

Keeps one Cloudflare A record pointed at the home WAN IP. Reads the IP from the Fritz!Box over TR-064
(not this host's own egress - avoids VPN-gateway rerouting), PATCHes Cloudflare only on change.

## Required Variables

```yaml
cloudflare_ddns_api_token: "..."      # Zone.DNS:Edit scoped to the zone below
cloudflare_ddns_zone_id: "..."
cloudflare_ddns_record_name: "hs.example.com"

cloudflare_ddns_fritzbox_url: "http://192.168.178.1:49000"
cloudflare_ddns_fritzbox_username: "..."   # Fritz!Box user with "FRITZ!Box Settings" permission
cloudflare_ddns_fritzbox_password: "..."
```

## Notes

- The A record must already exist - this role only updates it, never creates it.
- Every update forces `proxied: false`.
- Credentials live in `/etc/credstore/cloudflare-ddns.env`, root-only.
