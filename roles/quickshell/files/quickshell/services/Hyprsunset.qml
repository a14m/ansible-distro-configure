pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Screen temperature from hyprsunset. sunset.sh calls
// `qs ipc call hyprsunset refresh` after changing it.
Singleton {
  id: root

  // Same threshold as sunset.sh: below 6000K night shift is on.
  readonly property int offTemperature: 6000
  property int temperature: 0
  readonly property bool on: temperature > 0 && temperature < offTemperature

  function refresh() {
    query.running = true;
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
