# Ansible Role: caddy-ca

Exposes Caddy's own local CA root certificate at `http://{{ inventory_hostname }}/certificate`,
to trust `*.internal` domains.

## What it does

Writes `/etc/caddy/sites/caddy-ca.caddy`:

- Served over **plain HTTP only** - fetching the root cert has to work before anything is trusted yet.
- `/certificate` serves `root.crt` in place via `file_server`, never copied elsewhere. The `rewrite * /root.crt` is
  unconditional, so `root.key` (the CA's private key, same directory) is never reachable through this route.
- `Content-Type: application/x-x509-ca-cert` forced on the response, so mobile browsers treat it as an installable
  certificate rather than a plain download. `Content-Disposition: attachment; filename=root.crt` forces a proper
  filename/extension too - the URL is extensionless (`/certificate`), so without this some browsers save it as a
  bare `certificate` file with no `.crt` suffix, which import dialogs (e.g. Firefox's) then refuse to select.
- Reads the file rather than Caddy's admin API (`GET /pki/ca/local/certificates`) because that endpoint bundles
  root+intermediate into one PEM blob, which iOS can't parse as a single installable cert.

## Notes

- Caddy generates its CA lazily, on first use - `/certificate` 404s on a brand-new `proxy.home.arpa` until some
  `*.internal` site elsewhere has converged. Resolves itself once that happens.
- **Trusting it - desktop Linux** (system-wide trust store, covers curl/wget/Chromium/most apps):
  - Arch: `sudo trust anchor --store root.crt`
  - Debian/Ubuntu/Alpine: `sudo cp root.crt /usr/local/share/ca-certificates/ && sudo update-ca-certificates`
  - Fedora/RHEL: `sudo cp root.crt /etc/pki/ca-trust/source/anchors/ && sudo update-ca-trust extract`
  - **Firefox** (any OS/distro) uses its own NSS store, not the system one, regardless of the above:
    `about:preferences#privacy` -> Certificates -> View Certificates -> Authorities -> Import -> check "Trust this
    CA to identify websites".
- **Trusting it - macOS/Windows**: import the file into Keychain Access / `certutil`-Group Policy respectively.
- **Trusting it - mobile**: the browser prompts to install a profile - iOS needs Safari specifically (not Chrome) to
  trigger this, plus a separate manual step afterward (Settings -> General -> About -> Certificate Trust Settings ->
  enable full trust); if nothing prompts, try opening the downloaded file from Files, or AirDrop/Mail it instead of
  downloading in-browser.
