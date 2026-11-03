import QtQuick
import Quickshell
import qs

// Clickable bar text, highlighted on hover.
Text {
  id: root

  property int padding: 10
  property color baseColor: Theme.foreground

  signal clicked
  signal rightClicked

  // Opens a terminal app (wlctl, bluetui, ...) in its own floating window.
  function tui(app) {
    Quickshell.execDetached(["/etc/xdg/waybar/scripts/launch-tui", app]);
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
}
