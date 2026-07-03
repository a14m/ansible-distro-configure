# ethtool Role

Installs ethtool and configures Wake-on-LAN (WoL) via a systemd service.

## Variables

```yaml
ethtool_wol_interface: "eth0"      # Network interface to enable WoL on
ethtool_lid_ac_action: "suspend"   # HandleLidSwitchExternalPower (ignore/suspend/hibernate/lock/poweroff)
```

## Usage

```yaml
- role: "ethtool"
  vars:
    ethtool_wol_interface: "enp0s25"
```

## Enabling Wake-on-LAN

Three steps required:

### 1. BIOS Configuration (manual)

**ThinkPad:**
1. Reboot → press `Enter` then `F1` at Lenovo splash
2. **Config** → **Network** → **Wake On LAN** → `AC Only` or `AC and Battery`
3. `F10` to save

**Other systems:** look in BIOS under **Power** → **APM** or **Advanced Power Management** → **Wake on LAN**.
Also disable **ErP/EuP Ready** to keep NIC powered during sleep.

### 2. Ansible (this role)

Enables WoL on the NIC via ethtool on every boot. Add to your play with the correct interface:

```yaml
ethtool_wol_interface: "enp0s25"
```

### 3. Lid behavior (laptops)

Role configures `HandleLidSwitchExternalPower` via `ethtool_lid_ac_action` (default: `suspend`). Set to `ignore` for WoL use case — lid close on AC won't re-suspend after wake. No effect on desktops.

### 4. Suspend the host

WoL is most reliable from suspend (S3). Shutdown (S5) requires BIOS "WoL from S5" support.

```bash
systemctl suspend
```

## Sending the Magic Packet

From another host or FritzBox UI (**Home Network → Network → device → Wake on LAN**).

## Verify WoL is enabled

```bash
ethtool enp0s25 | grep Wake
# Wake-on: g   ← means WoL is active
# Wake-on: d   ← means WoL is disabled
```
