import Quickshell
import qs.services

// Keyboard layout. Click switches to the next one.
BarItem {
  text: `\uf11c ${Keyboard.shortLayout}`
  onClicked: Quickshell.execDetached(["hyprctl", "switchxkblayout", "all", "next"])
}
