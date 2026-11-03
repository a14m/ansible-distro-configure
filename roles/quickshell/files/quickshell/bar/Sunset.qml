import Quickshell
import qs.services

// Night shift (hyprsunset). Click toggles it.
BarItem {
  text: Hyprsunset.on ? "\uf186" : "\uf185"
  tooltip: `Nightshift ${Hyprsunset.on ? "On" : "Off"} (temp: ${Hyprsunset.temperature})`
  onClicked: Quickshell.execDetached(["/etc/hypr/scripts/sunset.sh", "--toggle"])
}
