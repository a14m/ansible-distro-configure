# Ansible Role: caddy

Installs Caddy with an internal CA (`cert_issuer internal`) and imports vhosts from `/etc/caddy/sites/*.caddy`.

## Variables

- `caddy_metrics_port` dedicated `/metrics`-only listener; empty (default) disables it.
- `caddy_acme_email` Let's Encrypt account email for vhosts using a real ACME issuer.
- `caddy_pki_root_cert` / `caddy_pki_root_key` PEM root pair pinned for the internal CA (optional, set both).

## CA root certificate

Serves the internal CA root at `http://{{ inventory_hostname }}/certificate` over **plain HTTP** (trust has to
bootstrap before HTTPS works):

- `rewrite * /root.crt` is unconditional, so the sibling `root.key` is never reachable.
- `Content-Type: application/x-x509-ca-cert` + `Content-Disposition: attachment; filename=root.crt` so browsers
  treat it as an installable cert with a `.crt` name (the URL is extensionless).
- Serves the file, not the admin API (`/pki/ca/local/certificates`) - that bundles root+intermediate, which iOS
  can't install as one cert.

Unpinned, Caddy generates the root on first use (`/certificate` 404s until some `*.internal` site has converged)
and a rebuilt host gets a new one, so every device has to re-trust it.

## Pinned CA root

The pair is deployed to `/etc/caddy/pki/` and the `pki` app points at it, so a rebuilt host keeps the root devices
already trust. Intermediate and leaf certs stay in Caddy's storage and are reissued from it.

Generate a pair (root lifetime must exceed the intermediate's, 7 days by default):

```sh
openssl ecparam -name prime256v1 -genkey -noout -out root.key
openssl req -x509 -new -key root.key -sha256 -days 3650 -subj "/CN=Home Local Authority" \
  -addext "basicConstraints=critical,CA:TRUE,pathlen:1" \
  -addext "keyUsage=critical,keyCertSign,cRLSign" \
  -out root.crt
```

## Trusting the root

- **Linux** (system store - curl/wget/Chromium):
  - Arch: `sudo trust anchor --store root.crt`
  - Debian/Ubuntu/Alpine: `sudo cp root.crt /usr/local/share/ca-certificates/ && sudo update-ca-certificates`
  - Fedora/RHEL: `sudo cp root.crt /etc/pki/ca-trust/source/anchors/ && sudo update-ca-trust extract`
- **Firefox** (any OS) uses its own store: Settings -> Certificates -> Authorities -> Import -> trust for websites.
- **macOS**: a plain Keychain import isn't trusted by Chrome/Safari (`ERR_CERT_AUTHORITY_INVALID`); set explicit
  trust: `sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain root.crt`, then
  restart the browser. Homebrew `curl` may pass without this (own CA bundle). With corporate TLS inspection
  (e.g. Netskope) it can still fail - needs an IT steering bypass for `*.internal`.
- **Windows**: `certutil` / Group Policy.
- **Mobile**: install via the browser's profile prompt (iOS: Safari only, then Settings -> General -> About ->
  Certificate Trust Settings -> enable full trust). If nothing prompts, open the file from Files or send it by mail.
