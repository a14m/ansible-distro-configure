import Quickshell
import qs
import qs.lock
import qs.power

// Click locks the session, right click opens the power menu.
BarItem {
  text: ""
  onClicked: Lock.lock()
  baseColor: PowerMenu.open ? Theme.accent : Theme.foreground
  onRightClicked: PowerMenu.toggle()
}
