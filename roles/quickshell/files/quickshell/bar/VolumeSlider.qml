import QtQuick
import Quickshell.Services.Pipewire
import qs

// One audio node: its name, then mute toggle, slider and percentage.
// Clicking the name calls `selected` (used to make a device the default).
Column {
  id: root

  required property PwNode node
  // App streams carry their app's name; devices their short nickname.
  readonly property string label: node.properties["application.name"]
    || node.nickname || node.description || node.name
  property bool current: false
  property string icon: "\uf028"
  property string mutedIcon: "\ueee8"
  readonly property PwNodeAudio audio: node.audio

  signal selected

  width: 300
  spacing: 4

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

    Slider {
      anchors.verticalCenter: parent.verticalCenter
      value: root.audio.volume
      dimmed: root.audio.muted
      onMoved: value => root.audio.volume = value
    }

    PopupText {
      width: 40
      horizontalAlignment: Text.AlignRight
      text: `${Math.round(root.audio.volume * 100)}%`
    }
  }
}
