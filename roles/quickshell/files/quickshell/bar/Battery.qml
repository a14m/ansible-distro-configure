import QtQuick
import Quickshell.Services.UPower
import qs

// Laptop battery (hidden on desktops). Colors follow the old waybar style:
// accent while on power, yellow at 20%, blinking red at 10%. Right click
// opens battop.
BarItem {
  id: root

  readonly property UPowerDevice battery: UPower.displayDevice
  readonly property int level: Math.round(battery.percentage * 100)
  readonly property int step: Math.min(9, Math.floor(level / 10))
  readonly property int status: battery.state
  readonly property bool discharging: status === UPowerDeviceState.Discharging
  readonly property bool critical: discharging && level <= 10
  property bool blink: false

  readonly property var icons: ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾",
    "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
  readonly property var chargingIcons: ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝",
    "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]

  visible: battery.isLaptopBattery
  text: {
    switch (status) {
    case UPowerDeviceState.FullyCharged: return "󰂅";
    case UPowerDeviceState.Charging: return chargingIcons[step];
    case UPowerDeviceState.Discharging: return icons[step];
    case UPowerDeviceState.PendingCharge: return "";
    default: return `${level}% ${icons[step]}`;
    }
  }
  baseColor: critical ? (blink ? Theme.foreground : "#FD0E35")
    : discharging && level <= 20 ? "#F1C40F"
    : discharging ? Theme.foreground
    : Theme.accent
  tooltip: {
    const watts = Math.abs(battery.changeRate).toFixed(0);
    if (discharging) return `${watts}W\u2193 ${level}%`;
    if (status === UPowerDeviceState.Charging) return `${watts}W\u2191 ${level}%`;
    return `${level}%`;
  }
  onRightClicked: tui("battop")

  Timer {
    running: root.critical
    interval: 1000
    repeat: true
    onTriggered: root.blink = !root.blink
  }
}
