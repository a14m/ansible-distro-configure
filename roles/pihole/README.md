# Ansible Role: pihole

This role configure the [pihole](https://github.com/pi-hole/pi-hole) DNS Sinkhole.

## Role Variables

- `pihole_password` the pi-hole web-server plain text password (default: `changeme`).
- `pihole_totp_secret` the pi-hole TOTP 2FA secret (default: `CHANGEME`).
- `pihole_interface` the interface to bind the pi-hole on (default: "{{ ansible_default_ipv4.interface }}").
- `pihole_dns` the list of DNS servers to use as upstreams (default: `[9.9.9.9, 1.1.1.1, 8.8.8.8]`).
- `pihole_dns_blocking_enabled` the boolean flag to toggle DNS blocking (default: true).
- `pihole_dhcp_enabled` the boolean flag to toggle DHCP on the pi-hole (default: false).
- `pihole_domain` the domain name to be configured when the pi is exposed over the internet (default: "").

## Router Setup

### [FRITZ!Box](https://docs.pi-hole.net/routers/fritzbox/)

Update the following

- Home Network > Network > Network Settings > Change Advanced Network Settings >
  - IPv6 > DNSv6 Server in the Home Network > Router advertisement enable in the LAN > Set ULA Prefix
  - IPv4 > DHCP > Local DNS Server > {{ pihole_ipv4 }}
- Internet > Account Information > DNS Server > DNSv4 Server >
  - Use Other DNSv4 Servers > {{ pihole_ipv4 }}
  - Use Other DNSv6 Servers > {{ pihole_ipv6 }}
- Internet > Filter > Unrestricted > Add Device > {{ pihole_device_name }}
- Internet > Filter > Standard > Restrictions > Filters > Add Exception > DNS
