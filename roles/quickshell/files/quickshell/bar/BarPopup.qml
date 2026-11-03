import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs

// Panel under a bar item. Clicking anywhere outside it (or the bar) closes it.
//
// It is a layer window rather than a PopupWindow: Hyprland's focus grab only
// works with layer windows, and a popup's own grab is lost whenever another
// layer (the OSD, a notification) appears or disappears.
PanelWindow {
  id: root

  required property Item item
  property bool open: false
  default property alias content: column.data

  readonly property var bar: item.QsWindow.window

  screen: bar?.screen ?? null
  visible: open
  anchors {
    top: true
    left: true
  }
  margins.top: 5
  exclusiveZone: 0
  WlrLayershell.namespace: "quickshell-popup"
  implicitWidth: column.implicitWidth + 30
  implicitHeight: column.implicitHeight + 30
  color: "transparent"

  // Centered under the item and kept on screen, also when the content changes
  // width while open. The item's position is read on open (it isn't bindable).
  property real itemCenter: 0
  margins.left: Math.max(10, Math.min(itemCenter - implicitWidth / 2, (screen?.width ?? 0) - implicitWidth - 10))
  onOpenChanged: if (open) itemCenter = bar.margins.left + item.mapToItem(null, item.width / 2, 0).x
  onVisibleChanged: grab.active = visible

  Rectangle {
    anchors.fill: parent
    radius: 5
    color: Theme.background
    border.width: 2
    border.color: Theme.accent

    Column {
      id: column
      x: 15
      y: 15
      spacing: 10
    }
  }

  HyprlandFocusGrab {
    id: grab
    windows: [root, root.bar]
    onCleared: root.open = false
  }
}
