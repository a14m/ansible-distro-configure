# Ansible Role: pihole

Configures the [Pi-hole](https://github.com/pi-hole/pi-hole) DNS sinkhole.

## Role Variables

- `pihole_admin_password` double-SHA256 hash of the web password. Compute inline, never store the plaintext:
  `{{ ('yourpassword' | hash('sha256') | hash('sha256'))[:64] }}` (default: hash of `changeme`).
- `pihole_totp_secret` TOTP 2FA secret (default: `CHANGEME`).
- `pihole_interface` bind interface (default: `{{ ansible_default_ipv4.interface }}`).
- `pihole_dns` upstream DNS servers (default: `[9.9.9.9, 1.1.1.1, 8.8.8.8]`).
- `pihole_dns_blocking_enabled` toggle DNS blocking (default: `true`).
- `pihole_dhcp_enabled` toggle the Pi-hole DHCP server (default: `false`).
- `pihole_domain` domain to configure when the Pi is exposed to the internet (default: `""`).

## Router Setup

### [FRITZ!Box](https://docs.pi-hole.net/routers/fritzbox/)

- Home Network > Network > Network Settings > Change Advanced Network Settings > IPv4 >
  - Home network >
    - IPv4 address > {{ router_ipv4 }}
    - Subnet mask > {{ router_subnet_mask }}
  - DHCP > Enable DHCP server > ❌

- Internet > Filter >
  - Lists > Network Applications > Add Network Application >
    - Name: DNS, Protocol: UDP, Source Port: Any, Destination Port: 53
    - Name: DNS, Protocol: TCP, Source Port: Any, Destination Port: 53

  - Prioritization > Real-Time Applications > Create New Rule
    - Device: {{ pihole_device_name }}, Application: DNS

  - Parental Controls > Unrestricted > Add Device > {{ pihole_device_name }}
  - Parental Controls > Standard > Edit > Filters >
    - Filter for network applications > all network applications are permitted
    - Add Exceptions > DNS

- Internet > Account Information > DNS Server > DNSv4 Server > Use Other DNSv4 Servers > {{ pihole_ipv4 }}

- Home Network > Network > Network Settings > Change Advanced Network Settings > IPv6 >
  - Router advertisement enable in the LAN > ❌
  - DNSv6 Server in the Home Network > Also announce DNSv6 server via router advertisement (RFC5006) > ❌

- Internet > Account Information > IPv6 > IPv6 Support > ❌
