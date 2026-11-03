import QtQuick
import Quickshell
import qs
import qs.services

// Keyboard layout. Click switches to the next one, right click opens a popup
// to pick one.
BarItem {
  id: root

  text: `\uf11c ${Keyboard.shortLayout}`
  baseColor: popup.open ? Theme.accent : Theme.foreground
  onClicked: Quickshell.execDetached(["hyprctl", "switchxkblayout", "all", "next"])
  onRightClicked: popup.open = !popup.open

  BarPopup {
    id: popup
    item: root

    PopupText {
      text: "Keyboard layout"
      highlighted: true
    }

    Repeater {
      model: Keyboard.layouts

      PopupText {
        required property string modelData
        required property int index
        readonly property var info: Keyboard.describe(modelData)

        text: `${info.short}  ${info.name}`
        highlighted: index === Keyboard.active
        clickable: true
        onClicked: {
          Keyboard.select(index);
          popup.open = false;
        }
      }
    }
  }
}
