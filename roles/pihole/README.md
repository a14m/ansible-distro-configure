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

#### No IPv6 Support (default)

- Home Network > Network > Network Settings > Change Advanced Network Settings > IPv6 >
  - Router advertisement enable in the LAN > ❌
  - DNSv6 Server in the Home Network > Also announce DNSv6 server via router advertisement (RFC5006) > ❌

- Internet > Account Information > IPv6 > IPv6 Support > ❌

#### With IPv6 Support

> **Note:** Full IPv6 gateway support (all devices including WiFi) requires FritzBox to be the IPv6 border
> router. Pi can only act as IPv6 gateway for wired hosts with static `network_ipv6_gateway` config.
> radvd is deployed by the `gateway` role when `network_ipv6_address` is defined on the Pi.

- Internet > Account Information >
  - IPv6 > IPv6 Support > ✅
  - IPv6 > IPv6 Connectivity > Native IPv4 connection > Use IPv6 via landline connection oor Mobile network > ✅
  - IPv6 > Connection Settings > Use DHCPv6 Rapid Commit > ❌
  - IPv6 > Connection Settings > Require certain length of the LAN prefix > ❌
  - DNS Server > DNSv6 Server > Use Other DNSv6 Servers > {{ pihole_ipv6 }}

- Home Network > Network > Network Settings > Change Advanced Network Settings > IPv6 >
  - Router advertisement enable in the LAN > ❌
  - DNSv6 Server in the Home Network >
    - Also announce DNSv6 server via router advertisement (RFC5006) > ❌
  - DHCPv6 Server in the home network >
    - Disable DHCPv6 server in the FRITZ!Box for the home network > ✅
      - There are no other DHCPv6 servers in the home network. > ✅
