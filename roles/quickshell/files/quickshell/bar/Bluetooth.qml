import QtQuick
import Quickshell
import Quickshell.Bluetooth

// Hidden without an adapter. Click toggles bluetooth, right click opens a popup
// to switch it and connect paired devices (pairing new ones is left to bluetui).
BarItem {
  id: root

  readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
  readonly property var connected: [...Bluetooth.devices.values].filter(device => device.connected)
  readonly property var paired: [...Bluetooth.devices.values].filter(device => device.paired)

  function battery(device) {
    return device.batteryAvailable ? `  ${Math.round(device.battery * 100)}%` : "";
  }

  visible: adapter !== null
  text: !adapter?.enabled ? "󰂲" : connected.length ? "󰂴" : "󰂯"
  tooltip: connected.length
    ? `Devices connected: ${connected.length}\n` + connected
      .map(device => `- ${device.name}` + (device.batteryAvailable ? `\t${Math.round(device.battery * 100)}% 󰂁` : ""))
      .join("\n")
    : `Bluetooth ${adapter?.enabled ? "on" : "off"}`
  onClicked: Quickshell.execDetached(["/etc/hypr/scripts/bluetooth.sh", "--toggle"])
  popup: popup

  BarPopup {
    id: popup
    item: root
    title: "Bluetooth"
    tui: "bluetui"

    PopupText {
      text: root.adapter?.enabled ? "Turn off" : "Turn on"
      clickable: true
      onClicked: root.adapter.enabled = !root.adapter.enabled
    }

    PopupText {
      visible: root.adapter?.enabled ?? false
      text: root.paired.length ? "Paired devices" : "No paired devices"
      highlighted: true
    }

    // Click a device to connect or disconnect it.
    Repeater {
      model: root.adapter?.enabled ? root.paired : []

      PopupText {
        required property BluetoothDevice modelData
        readonly property bool busy: modelData.state === BluetoothDeviceState.Connecting
          || modelData.state === BluetoothDeviceState.Disconnecting

        text: `${modelData.name}${root.battery(modelData)}${busy ? "  ..." : ""}`
        highlighted: modelData.connected
        clickable: !busy
        onClicked: modelData.connected = !modelData.connected
      }
    }
  }
}
