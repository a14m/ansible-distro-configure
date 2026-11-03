import QtQuick
import Quickshell.Io

// Only shown where the laptop panel backlight exists.
BarItem {
  id: root

  readonly property string device: "/sys/class/backlight/intel_backlight"
  property int percent: 0

  visible: brightness.loaded
  text: "\ue30d"
  tooltip: `Brightness: ${percent}% \ue30d`
  onTooltipShownChanged: {
    if (!tooltipShown) return;
    brightness.reload();
    percent = Math.round(parseInt(brightness.text()) * 100 / parseInt(maxBrightness.text()));
  }

  FileView {
    id: brightness
    path: `${root.device}/brightness`
    blockLoading: true
    printErrors: false
  }

  FileView {
    id: maxBrightness
    path: `${root.device}/max_brightness`
    blockLoading: true
    printErrors: false
  }
}
