# Ansible Role: qbittorrent

Installs [qBittorrent-nox](https://www.qbittorrent.org/) as `qbittorrent-nox@qbittorrent` (its own `qbittorrent`
user, home `/var/lib/qbittorrent`), binds it to a WireGuard VPN, and sets its web UI address and login.

## Role Variables

- `qbittorrent_password` web UI password (required, plaintext); the role writes it as qBittorrent's PBKDF2
  hash.
- `qbittorrent_username` web UI username (default: `admin`).
- `qbittorrent_save_path` directory torrents download to (default: `/var/lib/qbittorrent/Downloads`).
- `qbittorrent_group` / `qbittorrent_group_id` primary group (and optional GID) owning downloads; share it across
  containers that bind-mount the same folder (default: `qbittorrent`). Downloads are group-writable (`UMask=0002`).
- `qbittorrent_max_ratio` share ratio after which torrents stop seeding (default: `-1`, no limit).
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
