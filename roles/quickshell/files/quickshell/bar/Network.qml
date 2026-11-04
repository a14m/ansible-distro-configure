import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import qs

// Ethernet icon when wired, else the wifi signal strength. Click toggles wifi,
// right click opens a popup to switch wifi and pick a network. The tooltip
// shows the network and its traffic.
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
  // Wifi networks in range (scanned while the popup is open), connected one
  // first, then by signal; hidden networks have no name and are skipped.
  readonly property var wifiDevices: [...Networking.devices.values].filter(device => device.type === DeviceType.Wifi)
  readonly property var networks: {
    const all = [];
    for (const device of wifiDevices) all.push(...device.networks.values);
    const seen = new Set();
    return all
      .filter(network => network.name)
      .sort((a, b) => b.connected - a.connected || b.signalStrength - a.signalStrength)
      .filter(network => !seen.has(network.name) && seen.add(network.name))
      .slice(0, 8);
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
    : wifi ? signalIcon(wifi)
    : "󰤮"
  baseColor: popup.open ? Theme.accent : Theme.foreground
  tooltip: popup.open ? "" : tooltipText
  readonly property string tooltipText: {
    const traffic = `\u21e3${speed(down)}  \u21e1${speed(up)}`;
    if (wired) return traffic;
    if (wifi) return `${wifi.name} (${frequency} GHz)\n${traffic}`;
    return "Disconnected";
  }
  onClicked: Quickshell.execDetached(["/etc/hypr/scripts/wifi.sh", "--toggle"])
  onRightClicked: popup.open = !popup.open

  function signalIcon(network) {
    return signalIcons[Math.min(4, Math.floor(network.signalStrength * 5))];
  }

  // Connected: disconnect. Known or open: connect. New secured: needs a
  // password, so hand over to wlctl.
  function choose(network) {
    const open = network.security === WifiSecurityType.Open || network.security === WifiSecurityType.Owe;
    if (network.connected) {
      network.disconnect();
    } else if (network.known || open) {
      network.connect();
    } else {
      popup.open = false;
      tui("wlctl");
    }
  }

  BarPopup {
    id: popup
    item: root
    onOpenChanged: root.wifiDevices.forEach(device => device.scannerEnabled = open)

    PopupText {
      text: "Wi-Fi"
      highlighted: true
    }

    PopupText {
      text: Networking.wifiEnabled ? "Turn off" : "Turn on"
      clickable: true
      onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
    }

    PopupText {
      visible: root.wired
      text: "Ethernet connected"
    }

    Repeater {
      model: Networking.wifiEnabled ? root.networks : []

      PopupText {
        required property var modelData
        readonly property bool secured: modelData.security !== WifiSecurityType.Open
          && modelData.security !== WifiSecurityType.Owe

        text: `${root.signalIcon(modelData)} ${modelData.name}${secured ? " \uf023" : ""}${modelData.stateChanging ? "  ..." : ""}`
        highlighted: modelData.connected
        clickable: !modelData.stateChanging
        onClicked: root.choose(modelData)
      }
    }

    PopupText {
      text: "Open wlctl"
      clickable: true
      onClicked: {
        popup.open = false;
        root.tui("wlctl");
      }
    }
  }
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
