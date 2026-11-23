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
- `qbittorrent_natpmp_gateway` VPN gateway answering NAT-PMP, e.g. `10.2.0.1` for Proton VPN with NAT-PMP on
  (optional; unset or empty leaves port forwarding off).

## Notes

- New torrents use automatic torrent management, so a torrent with a category is saved in `<save path>/<category>`.
- Torrent traffic only uses the VPN interface: with the tunnel down it stalls instead of falling back to other
  interfaces, and resumes when the tunnel is back.
- With `qbittorrent_natpmp_gateway`, the `qbittorrent-natpmp` service (running only while the VPN does) renews the
  mapping every 45 s and sets the gateway's port as the listen port; qBittorrent's own UPnP/NAT-PMP is off. The
  firewall must let peers in on the VPN interface (e.g. ufw `allow in on wg-vpn`). Unsetting it removes the service
  and its files and turns UPnP/NAT-PMP back on; remove the firewall rule with it.
- Only the settings above are managed in `qBittorrent.conf`; qBittorrent rewrites the file on exit, so they're
  applied while it's stopped. Everything else stays editable in the web UI.
