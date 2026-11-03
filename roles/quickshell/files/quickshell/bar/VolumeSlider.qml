import QtQuick
import Quickshell.Services.Pipewire
import qs

// One audio node: its name, then mute toggle, slider and percentage.
// Clicking the name calls `selected` (used to make a device the default).
Column {
  id: root

  required property PwNode node
  required property string label
  property bool current: false
  property string icon: "\uf028"
  property string mutedIcon: "\ueee8"
  readonly property PwNodeAudio audio: node.audio

  signal selected

  width: 300
  spacing: 4

  function setVolume(volume) {
    audio.volume = Math.max(0, Math.min(1, volume));
  }

  PopupText {
    width: parent.width
    text: root.label
    highlighted: root.current
    clickable: true
    onClicked: root.selected()
  }

  Row {
    spacing: 10

    PopupText {
      width: 20
      text: root.audio.muted ? root.mutedIcon : root.icon
      clickable: true
      onClicked: root.audio.muted = !root.audio.muted
    }

    Item {
      width: 220
      height: 16
      anchors.verticalCenter: parent.verticalCenter

      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 4
        radius: 2
        color: Qt.alpha(Theme.foreground, 0.2)

        Rectangle {
          width: parent.width * Math.min(root.audio.volume, 1)
          height: parent.height
          radius: parent.radius
          color: root.audio.muted ? Theme.inactive : Theme.accent
        }
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onPressed: mouse => root.setVolume(mouse.x / width)
        onPositionChanged: mouse => root.setVolume(mouse.x / width)
        onWheel: wheel => root.setVolume(root.audio.volume + (wheel.angleDelta.y > 0 ? 0.01 : -0.01))
      }
    }

    PopupText {
      width: 40
      horizontalAlignment: Text.AlignRight
      text: `${Math.round(root.audio.volume * 100)}%`
    }
  }
}
