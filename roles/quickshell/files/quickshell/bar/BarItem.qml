import QtQuick
import Quickshell
import qs

// Clickable bar text, highlighted on hover, with an optional tooltip.
Text {
  id: root

  property int padding: 10
  property color baseColor: Theme.foreground
  property string tooltip: ""
  readonly property bool tooltipShown: tooltipWindow.visible

  signal clicked
  signal rightClicked

  // Opens a terminal app (wlctl, bluetui, ...) in its own floating window.
  function tui(app) {
    Quickshell.execDetached(["/etc/hypr/scripts/launch-tui", app]);
  }

  height: parent.height
  leftPadding: padding
  rightPadding: padding
  verticalAlignment: Text.AlignVCenter
  color: hover.hovered ? Theme.accent : baseColor
  font.family: Theme.monoFont
  font.pixelSize: 14

  HoverHandler {
    id: hover
    cursorShape: Qt.PointingHandCursor
  }

  TapHandler {
    acceptedButtons: Qt.LeftButton
    onTapped: root.clicked()
  }

  TapHandler {
    acceptedButtons: Qt.RightButton
    onTapped: root.rightClicked()
  }

  // Shown below the item after hovering for a moment.
  Timer {
    id: tooltipDelay
    running: hover.hovered
    interval: 500
  }

  PopupWindow {
    id: tooltipWindow
    visible: hover.hovered && !tooltipDelay.running && root.tooltip !== ""
    anchor.item: root
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.bottom: -5
    implicitWidth: label.implicitWidth + 20
    implicitHeight: label.implicitHeight + 12
    color: "transparent"
    mask: Region {}

    Panel {
      anchors.fill: parent
      border.width: 1

      Text {
        id: label
        anchors.centerIn: parent
        text: root.tooltip
        color: Theme.foreground
        font.family: Theme.monoFont
        font.pixelSize: 13
      }
    }
  }
}
