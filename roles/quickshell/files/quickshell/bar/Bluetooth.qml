import QtQuick
import Quickshell
import Quickshell.Bluetooth

// Hidden without an adapter. Click toggles bluetooth, right click opens bluetui.
BarItem {
  readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
  readonly property var connected: [...Bluetooth.devices.values].filter(device => device.connected)

  visible: adapter !== null
  text: !adapter?.enabled ? "󰂲" : connected.length ? "󰂴" : "󰂯"
  tooltip: connected.length
    ? `Devices connected: ${connected.length}\n` + connected
      .map(device => `- ${device.name}` + (device.batteryAvailable ? `\t${Math.round(device.battery * 100)}% 󰂁` : ""))
      .join("\n")
    : `Bluetooth ${adapter?.enabled ? "on" : "off"}`
  onClicked: Quickshell.execDetached(["/etc/hypr/scripts/bluetooth.sh", "--toggle"])
  onRightClicked: tui("bluetui")
}
