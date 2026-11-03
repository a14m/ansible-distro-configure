import QtQuick
import qs

// Clickable bar text, highlighted on hover.
Text {
  id: root

  property int padding: 10
  property color baseColor: Theme.foreground

  signal clicked
  signal rightClicked

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
