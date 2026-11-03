import Quickshell

// Click locks the session, right click opens the power menu.
BarItem {
  text: ""
  onClicked: Quickshell.execDetached(["hyprlock"])
  onRightClicked: Quickshell.execDetached(["/etc/hypr/scripts/power-menu"])
}
