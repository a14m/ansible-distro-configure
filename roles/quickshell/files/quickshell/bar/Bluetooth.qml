import QtQuick
import Quickshell
import Quickshell.Bluetooth

// Hidden without an adapter. Click toggles bluetooth, right click opens bluetui.
BarItem {
  readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
  readonly property bool connected: [...Bluetooth.devices.values].some(device => device.connected)

  visible: adapter !== null
  text: !adapter?.enabled ? "󰂲" : connected ? "󰂴" : "󰂯"
  onClicked: Quickshell.execDetached(["/etc/hypr/scripts/bluetooth.sh", "--toggle"])
  onRightClicked: tui("bluetui")
}
