# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Core Commands

**Install dependencies:**

```bash
ansible-galaxy install -r requirements.yml
```

**Run playbook:**

```bash
ansible-playbook site.yml --ask-become-pass
```

**Test connectivity:**

```bash
ansible all -m ping
```

## Architecture Overview

This is an Ansible configuration management repository for multiple Linux distributions
(Arch Linux, Ubuntu, Raspberry Pi).
The playbook configures systems with essential services, networking, user management, and security policies.

**Key Components:**

- `site.yml` - Main playbook with primary plays:
  - "Distro bootstrap configure" (runs on all hosts): hostname, network, user, ssh, password_policy
  - "Dev machines configure" (archlinux.local, ubuntu.local): locales, timezone, wireguard, homebrew, python, go, docker, podman
  - "Raspberry Pi configure" (rpi5.local): locales, timezone, wireguard, gateway, pihole

- `inventory/hosts.yml` - Defines homelab hosts (archlinux.local, ubuntu.local, rpi5.local)

- `host_vars/` - Host-specific variables (encrypted with git-crypt)
  - Contains network configuration, WireGuard VPN settings, user SSH keys
  - Example files available for each supported distro

- `group_vars/all.yml` - Global variables (encrypted with git-crypt)
  - User configuration, SSH settings, locale/timezone, password policies, Python versions

- `roles/` - Ansible roles for specific functionality:
  - Core: hostname, network, user, ssh, password_policy
  - System: locales, timezone, python, homebrew, docker, podman
  - Network: wireguard, gateway, pihole

**Security & Encryption:**

- Host and group variables are encrypted using git-crypt
- SSH key-based authentication with configurable ports
- Password policies enforced via PAM
- WireGuard VPN configurations for secure networking

**Network Topology:**

The infrastructure uses a hub-and-spoke network topology with the Raspberry Pi as the central gateway:

```
Internet
    ↕
Router (192.168.178.1)
    ↕
Raspberry Pi Gateway (192.168.178.254)
    ↕ ← Pi-hole DNS filtering
    ↕ ← NAT masquerading for local traffic  
    ↕ ← WireGuard VPN tunnel (optional)
    ↕
Local Devices (192.168.178.0/24)
├── archlinux.local (192.168.178.201)
└── ubuntu.local (192.168.178.202)
```

**Traffic Flow:**
- **DNS Resolution**: All devices → Pi-hole (192.168.178.254) → Upstream DNS
- **Internet Traffic**: Local devices → Pi Gateway (NAT) → Router → Internet
- **VPN Traffic** (when enabled): Local devices → Pi Gateway → WireGuard tunnel → Internet
- **Container Registry Access**: Configured for Docker Hub via `/etc/containers/registries.conf`

**Gateway Role Features:**
- Permanent NAT masquerading for direct internet access (always active)
- Optional WireGuard VPN routing (controlled by `gateway_enabled` variable)
- IPv4/IPv6 traffic forwarding with persistent iptables rules
- Automatic rule restoration via `iptables-persistent` on boot

**Target Systems:**

- Development machines (Arch Linux, Ubuntu) - with development tools (Python, Go, Docker, Podman)
- Raspberry Pi infrastructure (Pi-hole DNS filtering, NAT gateway, WireGuard VPN)
- All systems configured via SSH with standard homelab naming (.local domains)

## Configuration Notes

- Configure SSH access in `~/.ssh/config` before running playbooks
- Copy and customize example files from `host_vars/*.yml.example` and `group_vars/all.yml.example`
- If not using git-crypt, remove `.gitattributes` and work with plaintext configs
- Requires community.general collection (`>=10.7.0, <11.0.0`)

## Coding Conventions

- Respect `.editorconfig`
- Respect linting rules (using `yamllint` and `ansible-lint`)

## CLI Rules

- Ask me to clarify if the prompt isn't clear enough
- If a task sounds wrong, please tell me so, and what are the best practices in that case

