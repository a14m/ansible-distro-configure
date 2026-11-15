# Ansible Role: seerr

Builds [Seerr](https://seerr.dev/) (media requests; Jellyseerr's and Overseerr's successor) from a git tag, runs it
as its own user on the LAN address, and adds its web UI vhost.

## Role Variables

- `seerr_jellyfin` `{host, port, username, password}` of a Jellyfin admin (required); it becomes Seerr's admin.
- `seerr_servarr` `{type (sonarr/radarr), host, port, api_key, quality_profile, root_folder, external_url}`
  (required), added as default servers.
- `seerr_hostname` proxy vhost (e.g. `requests.internal`); unset skips it.
- `seerr_version` git tag (default: `v3.5.2`); changing it rebuilds.
- `seerr_node_version` node, through the `nodejs` role (default: `22`).
- `seerr_port` HTTP port on `network_ipv4_address` (default: `5055`).

## Notes

- First-time setup runs through the wizard's API only while Seerr isn't set up: Jellyfin admin sign-in, all
  libraries, Sonarr and Radarr. If it stops halfway, empty `/var/lib/seerr` and run again. Afterwards it's all in
  the web UI; any Jellyfin user can sign in, with request permission only.
- The build needs ~2 GB RAM and a few GB of disk. Source and build in `/opt/seerr` (root-owned); settings, database
  and logs in `/var/lib/seerr`. Node lives in `/opt/mise`, outside root's home, so the service can run it.
