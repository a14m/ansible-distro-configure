# Ansible Role: caddy-ca

Serves Caddy's local CA root certificate at `http://{{ inventory_hostname }}/certificate` so clients can trust
`*.internal` domains.

## What it does

Writes `/etc/caddy/sites/caddy-ca.caddy`, serving `root.crt` in place over **plain HTTP** (trust has to bootstrap
before HTTPS works):

- `rewrite * /root.crt` is unconditional, so the sibling `root.key` is never reachable.
- `Content-Type: application/x-x509-ca-cert` + `Content-Disposition: attachment; filename=root.crt` so browsers
  treat it as an installable cert with a `.crt` name (the URL is extensionless).
- Serves the file, not the admin API (`/pki/ca/local/certificates`) - that bundles root+intermediate, which iOS
  can't install as one cert.

## Notes

- Caddy generates its CA on first use - `/certificate` 404s until some `*.internal` site has converged.
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
