import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs

Rectangle {
  id: root

  required property Notification notification
  readonly property bool critical: notification.urgency === NotificationUrgency.Critical
  readonly property string icon: {
    if (notification.image) return notification.image;
    const appIcon = notification.appIcon;
    if (!appIcon) return "";
    if (appIcon.startsWith("/") || appIcon.includes("://")) return appIcon;
    return Quickshell.iconPath(appIcon, true);
  }

  implicitHeight: Math.min(content.implicitHeight + 20, 110)
  clip: true
  radius: 5
  color: Theme.background
  border.width: 2
  border.color: root.critical ? Theme.critical : Theme.accent

  // Critical notifications stay until dismissed; hovering pauses the timeout.
  Timer {
    running: !root.critical && !hover.hovered
    interval: 5000
    onTriggered: root.notification.expire()
  }

  HoverHandler {
    id: hover
  }

  // Left click runs the default action (or dismisses), right click dismisses.
  TapHandler {
    acceptedButtons: Qt.LeftButton
    onTapped: {
      for (const action of root.notification.actions) {
        if (action.identifier === "default") {
          action.invoke();
          return;
        }
      }
      root.notification.dismiss();
    }
  }

  TapHandler {
    acceptedButtons: Qt.RightButton
    onTapped: root.notification.dismiss()
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
      visible: root.icon !== ""
      source: root.icon
      implicitSize: 32
      Layout.alignment: Qt.AlignTop
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: 2

      Text {
        Layout.fillWidth: true
        text: root.notification.summary
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
        text: root.notification.body
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
