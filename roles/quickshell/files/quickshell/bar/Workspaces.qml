import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs

// Workspaces of this monitor: the ones its Hyprland workspace rules assign to it
// (1-4 without rules), plus any other workspace currently on it.
Row {
  id: root

  required property ShellScreen screen
  readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)
  property var rules: []

  readonly property var ids: {
    const ruled = rules.filter(rule => matches(rule.monitor)).map(rule => parseInt(rule.workspaceString));
    const current = [...Hyprland.workspaces.values].filter(ws => ws.monitor === monitor).map(ws => ws.id);
    const ids = new Set([...(ruled.length ? ruled : [1, 2, 3, 4]), ...current]);
    return [...ids].filter(id => id > 0).sort((a, b) => a - b);
  }

  // A rule's monitor is either "desc:<description prefix>" or an output name.
  function matches(ruleMonitor) {
    return ruleMonitor.startsWith("desc:")
      ? monitor.description.startsWith(ruleMonitor.slice(5))
      : monitor.name === ruleMonitor;
  }

  height: parent.height

  Process {
    id: rulesProcess
    running: true
    command: ["hyprctl", "workspacerules", "-j"]
    stdout: StdioCollector {
      onStreamFinished: root.rules = JSON.parse(text)
    }
  }

  // Rules can change when Hyprland reloads its config.
  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (event.name === "configreloaded") rulesProcess.running = true;
    }
  }

  Repeater {
    model: root.ids

    BarItem {
      required property int modelData
      readonly property bool active: root.monitor.activeWorkspace?.id === modelData

      padding: 3
      text: active ? "" : ""
      // Accent only on the focused monitor; elsewhere the shown workspace stays filled but dim.
      // (HyprlandMonitor.focused never updates here; focusedMonitor does.)
      baseColor: active && Hyprland.focusedMonitor === root.monitor ? Theme.accent : Theme.inactive
      // Focusing a workspace also moves focus to its monitor.
      onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${modelData} })`)
    }
  }
}
