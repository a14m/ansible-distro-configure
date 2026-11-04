import QtQuick
import qs

// Slider for a value between 0 and 1: click, drag, or scroll by `step`.
// It only reports `moved`; the owner applies the value.
Item {
  id: root

  property real value: 0
  property real step: 0.01
  property bool dimmed: false

  signal moved(real value)

  function move(value) {
    moved(Math.max(0, Math.min(1, value)));
  }

  width: 220
  height: 16

  Rectangle {
    anchors.verticalCenter: parent.verticalCenter
    width: parent.width
    height: 4
    radius: 2
    color: Qt.alpha(Theme.foreground, 0.2)

    Rectangle {
      width: parent.width * Math.max(0, Math.min(root.value, 1))
      height: parent.height
      radius: parent.radius
      color: root.dimmed ? Theme.inactive : Theme.accent
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onPressed: mouse => root.move(mouse.x / width)
    onPositionChanged: mouse => root.move(mouse.x / width)
    onWheel: wheel => root.move(root.value + (wheel.angleDelta.y > 0 ? root.step : -root.step))
  }
}
