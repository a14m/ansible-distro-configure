pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications

// Notification daemon (replaces mako): popups stacked in the top-right corner,
// newest first, with do-not-disturb and a history of closed notifications.
//
//   qs ipc call notifications toggleDnd
//   qs ipc call notifications restore      # re-show the last closed notification
//   qs ipc call notifications dismissAll
//
// A singleton so the bar's notification center can show the history.
Singleton {
  id: root

  readonly property int popupWidth: 300
  readonly property int historySize: 50
  readonly property string syncHint: "x-canonical-private-synchronous"

  property bool dnd: false
  // Popups hide while the notification center (same corner) is open; they
  // keep timing out into history meanwhile.
  property bool centerOpen: false
  // Entries copy what a popup needs, so they outlive their Notification and
  // can be restored from history. Both lists are newest first.
  property var popups: []
  property var history: []

  component Entry: QtObject {
    property Notification notification
    property string tag
    property string summary
    property string body
    property string icon
    property string appName
    property date time
    property bool critical
    property bool isTransient
  }

  Component {
    id: entryComponent
    Entry {}
  }

  function iconFor(notification) {
    if (notification.image) return notification.image;
    const appIcon = notification.appIcon;
    if (!appIcon) return "";
    if (appIcon.startsWith("/") || appIcon.includes("://")) return appIcon;
    return Quickshell.iconPath(appIcon, true);
  }

  // Shows an entry on top, replacing popups with the same sync tag in one step
  // (volume, brightness, ...), so the window never empties in between.
  function show(entry) {
    const stale = entry.tag ? popups.filter(e => e !== entry && e.tag === entry.tag) : [];
    popups = [entry, ...popups.filter(e => e !== entry && !stale.includes(e))];
    stale.forEach(e => {
      if (e.notification) e.notification.expire();
      retire(e);
    });
  }

  // Removes a popup. Called once the sender knows it closed (or it never had one).
  function hide(entry) {
    if (!popups.includes(entry)) return;
    popups = popups.filter(e => e !== entry);
    retire(entry);
  }

  // Closed entries go to history, except transient ones (-e in notify-send).
  function retire(entry) {
    if (entry.isTransient) {
      entry.destroy();
      return;
    }
    const kept = [entry, ...history.filter(e => e !== entry)];
    kept.slice(historySize).forEach(e => e.destroy());
    history = kept.slice(0, historySize);
  }

  // Closing the Notification emits `closed`, which hides the popup. Restored
  // entries have no Notification left, so they are hidden directly.
  function expire(entry) {
    if (entry.notification) entry.notification.expire();
    else hide(entry);
  }

  // Removes closed notifications from history (the notification center).
  function forget(entry) {
    history = history.filter(e => e !== entry);
    entry.destroy();
  }

  function clearHistory() {
    history.forEach(entry => entry.destroy());
    history = [];
  }

  function dismiss(entry) {
    if (entry.notification) entry.notification.dismiss();
    else hide(entry);
  }

  NotificationServer {
    id: server
    keepOnReload: true
    actionsSupported: true
    bodySupported: true
    bodyMarkupSupported: true
    imageSupported: true

    onNotification: notification => {
      notification.tracked = true;
      const entry = entryComponent.createObject(root, {
        notification: notification,
        tag: notification.hints[root.syncHint] ?? "",
        summary: notification.summary,
        body: notification.body,
        icon: root.iconFor(notification),
        appName: notification.appName,
        time: new Date(),
        critical: notification.urgency === NotificationUrgency.Critical,
        isTransient: notification.transient
      });
      notification.closed.connect(() => root.hide(entry));

      // Do-not-disturb only lets critical notifications through.
      if (root.dnd && !entry.critical) {
        notification.expire();
        root.retire(entry);
      } else {
        root.show(entry);
      }
    }
  }

  IpcHandler {
    target: "notifications"

    function toggleDnd(): bool {
      root.dnd = !root.dnd;
      return root.dnd;
    }

    function setDnd(enabled: bool): void {
      root.dnd = enabled;
    }

    function isDnd(): bool {
      return root.dnd;
    }

    function restore(): void {
      const entry = root.history[0];
      if (!entry) return;
      root.history = root.history.slice(1);
      root.show(entry);
    }

    function dismissAll(): void {
      root.popups.forEach(entry => root.dismiss(entry));
    }
  }

  PanelWindow {
    visible: root.popups.length > 0 && !root.centerOpen
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
    implicitHeight: column.implicitHeight

    Column {
      id: column
      width: root.popupWidth
      spacing: 10

      Repeater {
        // ScriptModel keeps existing delegates (and their timers) when the list changes.
        model: ScriptModel {
          values: root.popups
        }

        NotificationPopup {
          required property var modelData
          entry: modelData
          width: root.popupWidth
          onTimedOut: root.expire(entry)
          onDismissed: root.dismiss(entry)
        }
      }
    }
  }
}
