import Quickshell
import qs
import qs.power

// Click locks the session, right click opens the power menu.
BarItem {
  text: ""
  onClicked: Quickshell.execDetached(["hyprlock"])
  baseColor: PowerMenu.open ? Theme.accent : Theme.foreground
  onRightClicked: PowerMenu.toggle()
}
