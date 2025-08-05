# Ansible Role: network

This role configure the basic networking functionality of a linux distro

## Role Variables

- `hostname` the hostname to be configure if provided.
- `network_wifi_ssid` the name of the WIFI network to be configured (default: "").
- `network_wifi_pass` the passphrase of the WIFI network to be configure (default: "").
- `network_packages` the packages to install for a distro (default in distro vars).
- `network_packages_removed` the packages to remove from a distro (default in distro vars).
- `network_services` the services names to start/enable for a distro (default in distro vars).
