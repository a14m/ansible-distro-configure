import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs

Panel {
  id: root

  // An Entry from Notifications.qml; `entry.notification` is null once closed.
  required property var entry

  signal timedOut
  signal dismissed

  implicitHeight: Math.min(content.implicitHeight + 20, 110)
  clip: true
  border.color: root.entry.critical ? Theme.critical : Theme.accent

  // Critical notifications stay until dismissed; hovering pauses the timeout.
  Timer {
    running: !root.entry.critical && !hover.hovered
    interval: 5000
    onTriggered: root.timedOut()
  }

  HoverHandler {
    id: hover
  }

  // Left click runs the default action (or dismisses), right click dismisses.
  TapHandler {
    acceptedButtons: Qt.LeftButton
    onTapped: {
      const notification = root.entry.notification;
      if (notification) {
        for (const action of notification.actions) {
          if (action.identifier === "default") {
            action.invoke();
            return;
          }
        }
      }
      root.dismissed();
    }
  }

  TapHandler {
    acceptedButtons: Qt.RightButton
    onTapped: root.dismissed()
  }

  RowLayout {
    id: content
    anchors {
      left: parent.left
      right: parent.right
      top: parent.top
      leftMargin: 15
      rightMargin: 15
      topMargin: 10
    }
    spacing: 10

    IconImage {
      visible: root.entry.icon !== ""
      source: root.entry.icon
      implicitSize: 32
      Layout.alignment: Qt.AlignTop
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: 2

      Text {
        Layout.fillWidth: true
        text: root.entry.summary
        color: Theme.foreground
        font.family: Theme.font
        font.pixelSize: 14
        font.bold: true
        elide: Text.ElideRight
      }

      Text {
        Layout.fillWidth: true
        visible: text !== ""
        // StyledText collapses whitespace like HTML; keep spaces and newlines
        // as sent (scripts pad nerd font icons with spaces).
        text: root.entry.body
          .replace(/\n/g, "<br>")
          .replace(/ {2,}/g, spaces => "&nbsp;".repeat(spaces.length))
        textFormat: Text.StyledText
        color: Theme.foreground
        font.family: Theme.font
        font.pixelSize: 14
        wrapMode: Text.Wrap
        maximumLineCount: 3
        elide: Text.ElideRight
      }
    }
  }
}
