pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs

// Power menu: dims every monitor and shows the actions on the focused one.
// Arrows to pick, Enter to run, Esc or a click outside to close.
//
//   qs ipc call power toggle
Singleton {
  id: root

  property bool open: false
  property ShellScreen screen
  property int selected: 0

  readonly property var actions: [
    { icon: "\uf011", name: "Shutdown", flag: "--shutdown" },
    { icon: "󰑙", name: "Reboot", flag: "--reboot" },
    { icon: "󰤄", name: "Suspend", flag: "--hibernate" },
    { icon: "\uf023", name: "Lock Session", flag: "--lock" },
  ]

  function toggle() {
    selected = 0;
    screen = Quickshell.screens.find(screen => screen.name === Hyprland.focusedMonitor?.name) ?? null;
    open = !open;
  }

  function run(action) {
    open = false;
    Quickshell.execDetached(["/etc/hypr/scripts/power.sh", action.flag]);
  }

  IpcHandler {
    target: "power"
    function toggle(): void { root.toggle(); }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: window

      required property ShellScreen modelData
      readonly property bool hasMenu: modelData === root.screen

      screen: modelData
      visible: root.open
      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: hasMenu ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
      WlrLayershell.namespace: "quickshell-power"
      color: Qt.rgba(0, 0, 0, 0.5)

      MouseArea {
        anchors.fill: parent
        onClicked: root.open = false
      }

      Rectangle {
        visible: window.hasMenu
        anchors.centerIn: parent
        width: 450
        height: 300
        radius: 5
        color: Theme.background
        border.width: 2
        border.color: Theme.accent

        // Keeps clicks inside the box from closing the menu.
        MouseArea {
          anchors.fill: parent
        }

        Column {
          anchors.centerIn: parent
          spacing: 10

          Repeater {
            model: root.actions

            Text {
              required property var modelData
              required property int index

              text: `${modelData.icon} ${modelData.name}`
              color: index === root.selected ? Theme.accent : Theme.foreground
              font.family: Theme.monoFont
              font.pointSize: 20

              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: root.selected = parent.index
                onClicked: root.run(parent.modelData)
              }
            }
          }
        }
      }

      Item {
        focus: window.hasMenu
        Keys.onEscapePressed: root.open = false
        Keys.onReturnPressed: root.run(root.actions[root.selected])
        Keys.onEnterPressed: root.run(root.actions[root.selected])
        Keys.onUpPressed: root.selected = Math.max(0, root.selected - 1)
        Keys.onDownPressed: root.selected = Math.min(root.actions.length - 1, root.selected + 1)
      }
    }
  }
}
