import QtQuick
import Quickshell
import Quickshell.Wayland

// Top bar on every monitor: three floating groups.
Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: bar

      required property ShellScreen modelData

      screen: modelData
      anchors {
        top: true
        left: true
        right: true
      }
      margins {
        top: 5
        left: 10
        right: 10
      }
      implicitHeight: 30
      color: "transparent"
      WlrLayershell.namespace: "quickshell-bar"

      Group {
        anchors.left: parent.left
        Workspaces {
          screen: bar.modelData
        }
      }

      Group {
        anchors.horizontalCenter: parent.horizontalCenter
        Clock {}
      }

      Group {
        anchors.right: parent.right
        Network {}
        Bluetooth {}
        Volume {}
        Backlight {}
        Sunset {}
        Language {}
        CapsLock {}
        Battery {}
        Power {}
      }
    }
  }
}
