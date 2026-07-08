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

> **Note:** IPv6 support is currently disabled due to ISP compatibility issues. The steps below are kept
> for future reference. IPv6 on the network template defaults to `method=disabled`.
> To enable: set `method=auto` in `roles/network/templates/eth0-connection.nmconnection.j2` and follow
> the steps below to obtain a stable ULA address via SLAAC.
> Use the `mngtmpaddr` address from `ip address | grep "inet6 fd"` as `{{ pihole_ipv6 }}` — not the `temporary` one.

- Internet > Account Information >
  - IPv6 > IPv6 Support > ✅
  - IPv6 > IPv6 Connectivity > Native IPv4 connection > Use IPv6 via landline connection or Mobile network > ✅
  - IPv6 > Connection Settings > Use DHCPv6 Rapid Commit > ❌
  - IPv6 > Connection Settings > Require certain length of the LAN prefix > ❌

- Home Network > Network > Network Settings > Change Advanced Network Settings > IPv6 >
  - Router advertisement enable in the LAN > ✅
    - Always assign ULA addresses > ✅
    - Set ULA prefix > https://www.unique-local-ipv6.com/ example: `fd00:1234:5678::` > ✅
    - This FRITZ!Box provides the standard internet connection > Low
  - DNSv6 Server in the Home Network >
    - Also announce DNSv6 server via router advertisement (RFC5006) > ✅
    - Local DNSv6 Server > {{ pihole_ipv6 `ip address | grep "inet6 fd"`}}
  - DHCPv6 Server in the home network >
    - Disable DHCPv6 server in the FRITZ!Box for the home network > ✅
      - There are no other DHCPv6 servers in the home network. > ✅
- Internet > Account Information > Internet DNS Server > DNSv6 Server > Use Other DNSv6 Servers > {{ pihole_ipv6 }}
