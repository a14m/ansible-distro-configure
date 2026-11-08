# Ansible Role: qbittorrent

Installs [qBittorrent-nox](https://www.qbittorrent.org/) as `qbittorrent-nox@qbittorrent` (its own `qbittorrent`
user, home `/var/lib/qbittorrent`), binds it to a WireGuard VPN, and sets its web UI address and login.

## Role Variables

- `qbittorrent_webui_password_pbkdf2` web UI password hash (required). Generate it yourself (OpenSSL 3 + `xxd`; the
  role never sees plaintext):

  ```bash
  read -rs -p "Password: " PW; echo
  SALT=$(openssl rand -hex 16)
  KEY=$(openssl kdf -keylen 64 -kdfopt digest:SHA512 -kdfopt pass:"$PW" \
        -kdfopt hexsalt:"$SALT" -kdfopt iter:100000 PBKDF2 | tr -d ':\n')
  echo "$(echo "$SALT" | xxd -r -p | base64):$(echo "$KEY" | xxd -r -p | base64 | tr -d '\n')"
  unset PW
  ```

- `qbittorrent_webui_username` web UI username (default: `admin`).
- `qbittorrent_webui_port` web UI port on `network_ipv4_address` (default: `8080`).
- `qbittorrent_hostname` FQDN / vhost `server_name` (e.g. `downloads.internal`). Undefined skips the proxy vhost.
- `qbittorrent_trusted_proxy` reverse proxy IP trusted for the client IP in `X-Forwarded-For`, so failed logins ban
  the client instead of the proxy (optional; unset leaves reverse proxy support off).
- `qbittorrent_vpn_connection` WireGuard interface torrent traffic is bound to, e.g. `wg-vpn` (required).

## Notes

- Torrent traffic only uses the VPN interface: with the tunnel down it stalls instead of falling back to other
  interfaces, and resumes when the tunnel is back.
- Only the settings above are managed in `qBittorrent.conf`; qBittorrent rewrites the file on exit, so they're
  applied while it's stopped. Everything else stays editable in the web UI.
- Downloads go to `/var/lib/qbittorrent/Downloads` by default.
