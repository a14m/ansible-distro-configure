# Cloudflare DDNS Role

Keeps Cloudflare A/AAAA records pointed at this host's WAN addresses. IPv4 is read from the Fritz!Box over
TR-064 (not this host's own egress - avoids VPN-gateway rerouting); IPv6 has no NAT to hide behind, so it's
read straight off this host's own interface instead. PATCHes Cloudflare only on change.

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

- The A record must already exist - this role only updates it, never creates it. Same for AAAA if
  `cloudflare_ddns_ipv6_interface` is set.
- `cloudflare_ddns_ipv6_interface` (e.g. `"eth0"`) also keeps an AAAA record in sync - unset (default)
  skips IPv6 entirely.
- Every update forces `proxied: false`.
- Credentials live in `/etc/credstore/cloudflare-ddns.env`, root-only.
