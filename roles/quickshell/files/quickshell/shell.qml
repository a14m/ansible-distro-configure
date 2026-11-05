import QtQuick
import Quickshell
import qs.bar
import qs.launcher
import qs.notifications
import qs.osd

ShellRoot {
  // Singletons start on first use; read them here so the notification daemon
  // and the launcher's IPC commands are up with the shell.
  Component.onCompleted: [Notifications.dnd, Launcher.open]

  Bar {}
  Osd {}
}
