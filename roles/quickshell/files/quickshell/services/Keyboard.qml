pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// Layout and caps lock of Hyprland's main keyboard. Hyprland sends no event for
// caps lock, so devices are polled every second (like waybar's keyboard-state).
Singleton {
  id: root

  property string layout: ""
  property bool capsLock: false

  // Short name xkb gives a layout ("us" -> "en"), as waybar showed it.
  readonly property string shortLayout: {
    const match = new RegExp(`<name>${layout}</name>\\s*(<!--.*?-->\\s*)?<shortDescription>([^<]+)<`).exec(rules.text());
    return match ? match[2] : layout;
  }

  function refresh() {
    devices.running = true;
  }

  FileView {
    id: rules
    path: "/usr/share/X11/xkb/rules/evdev.xml"
    blockLoading: true
  }

  Process {
    id: devices
    command: ["hyprctl", "devices", "-j"]
    stdout: StdioCollector {
      onStreamFinished: {
        const keyboard = JSON.parse(text).keyboards.find(keyboard => keyboard.main);
        if (!keyboard) return;
        root.layout = keyboard.layout.split(",")[keyboard.active_layout_index] ?? "";
        root.capsLock = keyboard.capsLock;
      }
    }
  }

  Timer {
    running: true
    repeat: true
    triggeredOnStart: true
    interval: 1000
    onTriggered: root.refresh()
  }

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (event.name === "activelayout") root.refresh();
    }
  }
}
