pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Screen temperature from hyprsunset. sunset.sh calls
// `qs ipc call hyprsunset refresh` after changing it.
Singleton {
  id: root

  property int temperature: 0
  // Night shift is on while the GTK color-scheme is prefer-dark, whatever the temperature.
  property bool on: false

  Process {
    running: true
    command: ["sh", "-c", "gsettings get org.gnome.desktop.interface color-scheme;"
      + " exec gsettings monitor org.gnome.desktop.interface color-scheme"]
    stdout: SplitParser {
      onRead: line => root.on = line.includes("prefer-dark")
    }
  }

  function refresh() {
    query.running = true;
  }

  // Sets the temperature at most every 100ms, so dragging a slider doesn't
  // start a process per pixel.
  function set(value) {
    temperature = value;
    if (!throttle.running) throttle.start();
  }

  Timer {
    id: throttle
    interval: 100
    onTriggered: Quickshell.execDetached(["hyprctl", "hyprsunset", "temperature", `${root.temperature}`])
  }

  Process {
    id: query
    command: ["hyprctl", "hyprsunset", "temperature"]
    stdout: StdioCollector {
      onStreamFinished: root.temperature = parseInt(text) || 0
    }
  }

  // hyprsunset may start after the shell; retry until it answers.
  Timer {
    running: root.temperature === 0
    repeat: true
    triggeredOnStart: true
    interval: 5000
    onTriggered: root.refresh()
  }

  IpcHandler {
    target: "hyprsunset"
    function refresh(): void { root.refresh(); }
  }
}
