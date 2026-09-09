# ethtool Role

Installs ethtool and enables Wake-on-LAN on a NIC via a systemd service (re-applied every boot).

## Variables

```yaml
ethtool_wol_interface: "eth0"      # interface to enable WoL on
ethtool_lid_ac_action: "suspend"   # HandleLidSwitchExternalPower: ignore/suspend/hibernate/lock/poweroff
```

## Enabling Wake-on-LAN

1. **BIOS (manual)** - enable Wake on LAN. ThinkPad: `F1` at splash → Config → Network → Wake On LAN → `AC Only` or
   `AC and Battery` → `F10`. Others: Power / APM → Wake on LAN; also disable ErP/EuP Ready.
2. **This role** - set `ethtool_wol_interface` to the right NIC.
3. **Laptops** - set `ethtool_lid_ac_action: ignore` so a lid close on AC doesn't re-suspend after wake. No effect
   on desktops.
4. **Suspend the host** (`systemctl suspend`). WoL from S3 is reliable; S5 needs BIOS "WoL from S5" support.

## Notes

- Send the magic packet from another host or the FritzBox UI (Home Network → Network → device → Wake on LAN).
- Verify: `ethtool <iface> | grep Wake` - `Wake-on: g` means active, `d` means disabled.
