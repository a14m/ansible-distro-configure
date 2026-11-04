import QtQuick
import Quickshell
import qs.services

// Keyboard layout. Click switches to the next one, right click opens a popup
// to pick one.
BarItem {
  id: root

  text: `\uf11c ${Keyboard.shortLayout}`
  onClicked: Quickshell.execDetached(["hyprctl", "switchxkblayout", "all", "next"])
  popup: popup

  BarPopup {
    id: popup
    item: root
    title: "Keyboard layout"

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
