import QtQuick
import qs

// Text in a bar popup; `clickable` makes it react to hover and clicks.
Text {
  id: root

  property bool clickable: false
  property bool highlighted: false
  signal clicked

  color: highlighted || (clickable && hover.hovered) ? Theme.accent : Theme.foreground
  font.family: Theme.monoFont
  font.pixelSize: 14
  elide: Text.ElideRight

  HoverHandler {
    id: hover
    enabled: root.clickable
    cursorShape: Qt.PointingHandCursor
  }

  TapHandler {
    enabled: root.clickable
    onTapped: root.clicked()
  }
}
