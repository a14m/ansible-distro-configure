import QtQuick
import Quickshell
import Quickshell.Networking

// Ethernet icon when wired, else the wifi signal strength. Click toggles wifi,
// right click opens wlctl.
BarItem {
  readonly property var connected: [...Networking.devices.values].filter(device => device.connected)
  readonly property bool wired: connected.some(device => device.type === DeviceType.Wired)
  readonly property var wifi: {
    for (const device of connected) {
      if (device.type !== DeviceType.Wifi) continue;
      for (const network of device.networks.values) {
        if (network.connected) return network;
      }
    }
    return null;
  }
  readonly property var signalIcons: ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]

  text: wired ? "󰈀"
    : wifi ? signalIcons[Math.min(4, Math.floor(wifi.signalStrength * 5))]
    : "󰤮"
  onClicked: Quickshell.execDetached(["/etc/hypr/scripts/wifi.sh", "--toggle"])
  onRightClicked: tui("wlctl")
}
