import QtQuick
import Quickshell
import qs
import qs.services

// Night shift (hyprsunset). Click toggles it, right click opens a popup with a
// temperature slider.
BarItem {
  id: root

  readonly property int minimum: 1000
  readonly property int maximum: 6500

  text: Hyprsunset.on ? "\uf186" : "\uf185"
  baseColor: popup.open ? Theme.accent : Theme.foreground
  onClicked: Quickshell.execDetached(["/etc/hypr/scripts/sunset.sh", "--toggle"])
  onRightClicked: popup.open = !popup.open

  BarPopup {
    id: popup
    item: root

    PopupText {
      text: "Night shift"
      highlighted: true
    }

    PopupText {
      text: Hyprsunset.on ? "Turn off" : "Turn on"
      clickable: true
      onClicked: Quickshell.execDetached(["/etc/hypr/scripts/sunset.sh", "--toggle"])
    }

    Row {
      spacing: 10

      PopupText {
        width: 20
        text: Hyprsunset.on ? "\uf186" : "\uf185"
      }

      // Steps of 100K; scrolling moves by 100K too.
      Slider {
        anchors.verticalCenter: parent.verticalCenter
        value: (Hyprsunset.temperature - root.minimum) / (root.maximum - root.minimum)
        step: 100 / (root.maximum - root.minimum)
        dimmed: !Hyprsunset.on
        onMoved: value => Hyprsunset.set(Math.round((root.minimum + value * (root.maximum - root.minimum)) / 100) * 100)
      }

      PopupText {
        width: 50
        horizontalAlignment: Text.AlignRight
        text: `${Hyprsunset.temperature}K`
      }
    }
  }
}
