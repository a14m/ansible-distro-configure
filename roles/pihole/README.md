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

#### No IPv6 Support

- Home Network > Network > Network Settings > Change Advanced Network Settings > IPv6 >
  - Router advertisement enable in the LAN > ❌
  - DNSv6 Server in the Home Network > Also announce DNSv6 server via router advertisement (RFC5006) > ❌

- Internet > Account Information > IPv6 > IPv6 Support > ❌

#### With IPv6 Support

- Home Network > Network > Network Settings > Change Advanced Network Settings > IPv6 >
  - Router advertisement enable in the LAN > ✅
    - Always assign unique local addresses (ULA) > ❌
    - Allow IPv6 prefixes announced by other IPv6 routers in the home network > ❌
    - This FRITZ!Box provides the standard internet connection > ✅
    - Set the priority of the router advertisement > High
  - DNSv6 Server in the Home Network >
    - Also announce DNSv6 server via router advertisement (RFC5006) > ✅
    - Local DNSv6 server > {{ pihole_ipv6 }}
  - DHCPv6 Server in the home network >
    - Enable DHCPv6 server in the FRITZ!Box for the home network > ✅
      - Only assign DNS server > ✅

- Internet > Account Information >
  - IPv6 > IPv6 Support > ✅
  - IPv6 > IPv6 Connectivity > Native IPv6 connection
  - IPv6 > Connection Settings > Automatically negotiate a global address
  - IPv6 > Connection Settings > Use DHCPv6 Rapid Commit > ✅
  - DNS Server > DNSv6 Server > Use Other DNSv6 Servers > {{ pihole_ipv6 }}
