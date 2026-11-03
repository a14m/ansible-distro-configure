import QtQuick
import qs

// Rounded, half transparent group of bar items.
Rectangle {
  default property alias items: row.data

  implicitWidth: row.implicitWidth + 10
  height: parent.height
  radius: height / 2
  color: Qt.alpha(Theme.background, 0.5)

  Row {
    id: row
    anchors.centerIn: parent
    height: parent.height
  }
}
