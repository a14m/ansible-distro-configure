import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

// Ethernet icon when wired, else the wifi signal strength. Click toggles wifi,
// right click opens wlctl. The tooltip shows the network and its traffic.
BarItem {
  id: root

  readonly property var connected: [...Networking.devices.values].filter(device => device.connected)
  readonly property var device: connected.find(device => device.type === DeviceType.Wired)
    ?? connected.find(device => device.type === DeviceType.Wifi)
  readonly property bool wired: device?.type === DeviceType.Wired
  readonly property var wifi: {
    if (!device || wired) return null;
    for (const network of device.networks.values) {
      if (network.connected) return network;
    }
    return null;
  }
  readonly property var signalIcons: ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]

  // Traffic per second, sampled every 5 seconds like waybar did.
  property real down: 0
  property real up: 0
  property real frequency: 0

  function speed(bytes) {
    const units = ["B/s", "kB/s", "MB/s", "GB/s"];
    let unit = 0;
    while (bytes >= 1000 && unit < units.length - 1) {
      bytes /= 1000;
      unit++;
    }
    return `${bytes.toFixed(unit ? 1 : 0)}${units[unit]}`;
  }

  text: wired ? "󰈀"
    : wifi ? signalIcons[Math.min(4, Math.floor(wifi.signalStrength * 5))]
    : "󰤮"
  tooltip: {
    const traffic = `\u21e3${speed(down)}  \u21e1${speed(up)}`;
    if (wired) return traffic;
    if (wifi) return `${wifi.name} (${frequency} GHz)\n${traffic}`;
    return "Disconnected";
  }
  onClicked: Quickshell.execDetached(["/etc/hypr/scripts/wifi.sh", "--toggle"])
  onRightClicked: tui("wlctl")
  onTooltipShownChanged: if (tooltipShown && wifi) frequencyQuery.running = true

  FileView {
    id: rx
    path: root.device ? `/sys/class/net/${root.device.name}/statistics/rx_bytes` : ""
    blockLoading: true
  }

  FileView {
    id: tx
    path: root.device ? `/sys/class/net/${root.device.name}/statistics/tx_bytes` : ""
    blockLoading: true
  }

  Timer {
    property real lastRx: 0
    property real lastTx: 0

    running: root.device !== undefined
    repeat: true
    triggeredOnStart: true
    interval: 5000
    onTriggered: {
      rx.reload();
      tx.reload();
      const rxBytes = parseInt(rx.text()) || 0;
      const txBytes = parseInt(tx.text()) || 0;
      if (lastRx) {
        root.down = (rxBytes - lastRx) / 5;
        root.up = (txBytes - lastTx) / 5;
      }
      lastRx = rxBytes;
      lastTx = txBytes;
    }
  }

  // The networking service has no frequency, so ask NetworkManager.
  Process {
    id: frequencyQuery
    command: ["nmcli", "-g", "IN-USE,FREQ", "device", "wifi", "list", "ifname", root.device?.name ?? "", "--rescan", "no"]
    stdout: StdioCollector {
      onStreamFinished: {
        const line = text.split("\n").find(line => line.startsWith("*:"));
        root.frequency = line ? parseInt(line.slice(2)) / 1000 : 0;
      }
    }
  }
}
