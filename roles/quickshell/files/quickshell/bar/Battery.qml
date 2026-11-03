import QtQuick
import Quickshell.Services.UPower
import qs

// Laptop battery (hidden on desktops). Colors follow the old waybar style:
// accent while on power, yellow at 20%, blinking red at 10%. Right click
// opens a popup with the details.
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
  readonly property string stateName: ({
    [UPowerDeviceState.Charging]: "charging",
    [UPowerDeviceState.Discharging]: "discharging",
    [UPowerDeviceState.FullyCharged]: "full",
    [UPowerDeviceState.PendingCharge]: "plugged in",
  })[status] ?? ""
  readonly property string watts: Math.abs(battery.changeRate).toFixed(0)

  tooltip: popup.open ? ""
    : discharging ? `${watts}W\u2193 ${level}%`
    : status === UPowerDeviceState.Charging ? `${watts}W\u2191 ${level}%`
    : `${level}%`
  onRightClicked: popup.open = !popup.open

  function duration(seconds) {
    const minutes = Math.round(seconds / 60);
    return `${Math.floor(minutes / 60)}h ${minutes % 60}m`;
  }

  BarPopup {
    id: popup
    item: root

    PopupText {
      text: "Battery"
      highlighted: true
    }

    PopupText {
      text: root.stateName ? `${root.level}%, ${root.stateName}` : `${root.level}%`
    }

    PopupText {
      visible: root.battery.changeRate !== 0
      text: `Power: ${Math.abs(root.battery.changeRate).toFixed(1)} W`
    }

    PopupText {
      visible: root.battery.timeToEmpty > 0
      text: `Empty in: ${root.duration(root.battery.timeToEmpty)}`
    }

    PopupText {
      visible: root.battery.timeToFull > 0
      text: `Full in: ${root.duration(root.battery.timeToFull)}`
    }

    PopupText {
      visible: root.battery.healthSupported
      text: `Health: ${Math.round(root.battery.healthPercentage)}%`
    }

    PopupText {
      text: "Open battop"
      clickable: true
      onClicked: {
        popup.open = false;
        root.tui("battop");
      }
    }
  }

  Timer {
    running: root.critical
    interval: 1000
    repeat: true
    onTriggered: root.blink = !root.blink
  }
}
