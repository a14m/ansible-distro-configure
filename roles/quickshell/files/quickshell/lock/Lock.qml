pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland

// Session lock (replaces hyprlock), checking the password with PAM's "login"
// service. If the shell dies while locked, Hyprland keeps the session locked.
// There is deliberately no unlock command.
//
//   qs ipc call lock lock      (hypridle's lock_cmd)
Singleton {
  id: root

  readonly property bool locked: session.locked
  // Shared by every monitor's password field.
  property string input: ""
  property int failures: 0
  readonly property bool checking: pam.active

  function lock() {
    session.locked = true;
  }

  function submit() {
    if (input && !pam.active) pam.start();
  }

  IpcHandler {
    target: "lock"
    function lock(): void { root.lock(); }
  }

  PamContext {
    id: pam

    // PAM asks for the password; answer with what was typed.
    onPamMessage: if (responseRequired) respond(root.input)
    onCompleted: result => {
      if (result === PamResult.Success) {
        root.failures = 0;
        session.locked = false;
      } else {
        root.failures++;
      }
      root.input = "";
    }
    onError: root.input = ""
  }

  WlSessionLock {
    id: session

    WlSessionLockSurface {
      LockScreen {
        anchors.fill: parent
      }
    }
  }
}
