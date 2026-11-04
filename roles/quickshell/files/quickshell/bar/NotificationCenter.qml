import QtQuick
import qs
import qs.notifications

// Bell with the number of past notifications (crossed out while do-not-disturb
// is on). Click toggles do-not-disturb, right click opens the notification
// center: past notifications, newest first, each with a trash icon to remove it.
BarItem {
  id: root

  readonly property int count: Notifications.history.length

  text: (Notifications.dnd ? "" : "") + (count ? ` ${count}` : "")
  baseColor: popup.open ? Theme.accent : Theme.foreground
  onClicked: Notifications.dnd = !Notifications.dnd
  onRightClicked: popup.open = !popup.open

  BarPopup {
    id: popup
    item: root
    onOpenChanged: Notifications.centerOpen = open

    PopupText {
      text: "Notifications"
      highlighted: true
    }

    PopupText {
      text: `Do not disturb: ${Notifications.dnd ? "on" : "off"}`
      clickable: true
      onClicked: Notifications.dnd = !Notifications.dnd
    }

    PopupText {
      visible: root.count === 0
      text: "No notifications"
    }

    Repeater {
      model: Notifications.history.slice(0, 10)

      Column {
        required property var modelData

        width: 300
        spacing: 2

        Row {
          width: parent.width

          PopupText {
            width: parent.width - trash.width
            text: modelData.summary
            font.bold: true
          }

          PopupText {
            id: trash
            text: "\uf1f8"
            clickable: true
            onClicked: Notifications.forget(modelData)
          }
        }

        PopupText {
          visible: text !== ""
          width: parent.width
          text: modelData.body.replace(/<[^>]*>/g, "").replace(/\s+/g, " ")
        }

        PopupText {
          width: parent.width
          text: `${modelData.appName} · ${Qt.formatTime(modelData.time, "HH:mm")}`
          color: Theme.inactive
        }
      }
    }

    PopupText {
      visible: root.count > 10
      text: `and ${root.count - 10} more`
      color: Theme.inactive
    }

    PopupText {
      visible: root.count > 0
      text: "Clear all"
      clickable: true
      onClicked: Notifications.clearHistory()
    }
  }
}
