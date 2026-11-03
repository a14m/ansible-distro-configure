pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Colors come from the active hyprtheme; the defaults below are only used
// until the file loads (or when it is missing).
Singleton {
  id: root

  readonly property color accent: json.accent
  readonly property color inactive: json.inactive
  readonly property color foreground: json.foreground
  readonly property color background: json.background
  readonly property color critical: json.critical
  readonly property string font: json.font
  readonly property string monoFont: json.monoFont

  FileView {
    id: file
    path: Quickshell.env("HOME") + "/.config/hyprtheme/current/quickshell.json"
    watchChanges: true
    onFileChanged: reload()

    adapter: JsonAdapter {
      id: json
      property string accent: "#888888"
      property string inactive: "#444444"
      property string foreground: "#ffffff"
      property string background: "#000000"
      property string critical: "#ff0000"
      property string font: "sans-serif"
      property string monoFont: "monospace"
    }
  }

  // `current` is a symlink that theme.sh swaps, so the file watch can miss it.
  IpcHandler {
    target: "theme"
    function reload(): void { file.reload(); }
  }
}
