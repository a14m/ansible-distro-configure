import QtQuick
import Quickshell.Io

// Only shown where the laptop panel backlight exists.
BarItem {
  visible: backlight.loaded
  text: ""

  FileView {
    id: backlight
    path: "/sys/class/backlight/intel_backlight/brightness"
    printErrors: false
  }
}
