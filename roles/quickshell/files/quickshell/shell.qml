import QtQuick
import Quickshell
import qs.bar
import qs.launcher
import qs.lock
import qs.notifications
import qs.osd
import qs.wallpaper

ShellRoot {
  // Singletons start on first use; read them here so the notification daemon
  // and the launcher's and lock's IPC commands are up with the shell.
  Component.onCompleted: [Notifications.dnd, Launcher.open, Lock.locked]

  Bar {}
  Osd {}
  Wallpaper {}
}
