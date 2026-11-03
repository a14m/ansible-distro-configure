pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// Layout and caps lock of Hyprland's main keyboard. Hyprland sends no event for
// caps lock, so devices are polled every second (like waybar's keyboard-state).
Singleton {
  id: root

  // Configured layouts ("us", "de") and the index of the active one.
  property var layouts: []
  property int active: 0
  property bool capsLock: false

  readonly property string layout: layouts[active] ?? ""
  readonly property string shortLayout: describe(layout).short

  // Short name and description xkb gives a layout ("us" -> "en", "English (US)").
  function describe(code) {
    const match = new RegExp(`<name>${code}</name>\\s*(<!--.*?-->\\s*)?`
      + `<shortDescription>([^<]+)</shortDescription>\\s*<description>([^<]+)<`).exec(rules.text());
    return match ? { short: match[2], name: match[3] } : { short: code, name: code };
  }

  function select(index) {
    Quickshell.execDetached(["hyprctl", "switchxkblayout", "all", `${index}`]);
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
        // Only replace the list when it changed, so the popup isn't rebuilt every poll.
        if (keyboard.layout !== root.layouts.join(",")) root.layouts = keyboard.layout.split(",");
        root.active = keyboard.active_layout_index;
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
