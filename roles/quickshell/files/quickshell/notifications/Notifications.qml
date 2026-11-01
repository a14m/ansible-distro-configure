import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

// Notification daemon (replaces mako): popups stacked in the top-right corner.
Scope {
  id: root

  readonly property int popupWidth: 300

  NotificationServer {
    id: server
    keepOnReload: true
    actionsSupported: true
    bodySupported: true
    bodyMarkupSupported: true
    imageSupported: true

    onNotification: notification => {
      // Scripts (volume, brightness, ...) send this hint to replace their previous popup.
      const tag = notification.hints["x-canonical-private-synchronous"];
      if (tag) {
        const replaced = [];
        for (const old of server.trackedNotifications.values)
          if (old.hints["x-canonical-private-synchronous"] === tag) replaced.push(old);
        replaced.forEach(old => old.expire());
      }
      notification.tracked = true;
    }
  }

  PanelWindow {
    visible: server.trackedNotifications.values.length > 0
    anchors {
      top: true
      right: true
    }
    margins {
      top: 10
      right: 10
    }
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-notifications"
    color: "transparent"
    implicitWidth: root.popupWidth
    implicitHeight: popups.implicitHeight

    Column {
      id: popups
      width: root.popupWidth
      spacing: 10

      Repeater {
        model: server.trackedNotifications

        NotificationPopup {
          required property Notification modelData
          notification: modelData
          width: root.popupWidth
        }
      }
    }
  }
}
