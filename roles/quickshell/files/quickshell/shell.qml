import QtQuick
import Quickshell
import qs.bar
import qs.notifications
import qs.osd

ShellRoot {
  // The notification daemon is a singleton (the bar shows its history);
  // reading it here starts it with the shell.
  Component.onCompleted: Notifications.dnd

  Bar {}
  Osd {}
}
