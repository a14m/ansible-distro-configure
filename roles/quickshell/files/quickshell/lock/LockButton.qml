import QtQuick
import qs

// Clickable icon or text on the lock screen.
Text {
  id: root

  signal clicked

  color: hover.hovered ? Theme.accent : Qt.alpha(Theme.foreground, 0.8)
  font.family: Theme.monoFont
  font.pixelSize: 24

  HoverHandler {
    id: hover
    cursorShape: Qt.PointingHandCursor
  }

  TapHandler {
    onTapped: root.clicked()
  }
}
