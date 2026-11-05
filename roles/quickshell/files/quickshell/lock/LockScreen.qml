import QtQuick
import Quickshell
import qs
import qs.services

// What the lock shows on one monitor: clock, date, password field, keyboard
// layout and power actions on the theme background.
Rectangle {
  color: Theme.background

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  Column {
    anchors.centerIn: parent
    anchors.verticalCenterOffset: -60
    spacing: 16

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: Qt.formatTime(clock.date, "HH:mm")
      color: Theme.foreground
      font.family: Theme.monoFont
      font.pixelSize: 120
      // Monospace digits are spaced wide at this size; pull them together.
      font.letterSpacing: -10
    }

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: Qt.locale().toString(clock.date, "dddd, dd MMMM yyyy")
      color: Theme.foreground
      font.family: Theme.monoFont
      font.pixelSize: 24
      bottomPadding: 40
    }

    // Password field; typing goes to Lock.input, shared by every monitor.
    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      width: 360
      height: 52
      radius: height / 2
      color: "transparent"
      border.width: 2
      border.color: Lock.checking ? Theme.inactive : Lock.failures ? Theme.critical : Theme.accent

      TextInput {
        anchors.fill: parent
        anchors.margins: 16
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignHCenter
        focus: true
        enabled: !Lock.checking
        echoMode: TextInput.Password
        passwordCharacter: "•"
        text: Lock.input
        color: Theme.foreground
        font.family: Theme.monoFont
        font.pixelSize: 20
        onTextEdited: Lock.input = text
        Keys.onReturnPressed: Lock.submit()
        Keys.onEnterPressed: Lock.submit()
        Keys.onEscapePressed: Lock.input = ""
      }

      // Caps lock indicator, at the end of the field.
      Text {
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        visible: Keyboard.capsLock
        text: "󰘲"
        color: Theme.foreground
        font.family: Theme.monoFont
        font.pixelSize: 20
      }

      Text {
        anchors.centerIn: parent
        visible: !Lock.input
        text: Lock.checking ? "Checking..." : "Enter Password"
        color: Qt.alpha(Theme.foreground, 0.5)
        font.family: Theme.monoFont
        font.pixelSize: 18
      }
    }

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: Lock.failures ? `Wrong password (${Lock.failures})` : " "
      color: Theme.critical
      font.family: Theme.monoFont
      font.pixelSize: 16
    }
  }

  // Keyboard layout, click to switch.
  LockButton {
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    anchors.margins: 24
    text: ` ${Keyboard.shortLayout}`
    font.pixelSize: 18
    onClicked: Quickshell.execDetached(["hyprctl", "switchxkblayout", "all", "next"])
  }

  // Power actions, like the old hyprlock screen.
  Row {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 48
    spacing: 48

    Repeater {
      model: [
        { icon: "", flag: "--shutdown" },
        { icon: "󰑙", flag: "--reboot" },
        { icon: "󰤄", flag: "--hibernate" },
      ]

      LockButton {
        required property var modelData
        text: modelData.icon
        font.pixelSize: 32
        onClicked: Quickshell.execDetached(["/etc/hypr/scripts/power.sh", modelData.flag])
      }
    }
  }
}
