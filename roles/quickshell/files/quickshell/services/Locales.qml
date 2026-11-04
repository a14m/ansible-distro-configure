pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// System locale. /etc/locale.conf comes from the ansible locales role; select()
// writes ~/.config/locale.conf (read by /etc/profile.d/locale.sh at login) with
// every value that isn't C switched to the picked locale, reset() deletes it.
// Either applies after logging in again.
Singleton {
  id: root

  readonly property string configDir: Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config"
  readonly property string userPath: configDir + "/locale.conf"
  readonly property bool overridden: userFile.loaded
  readonly property string session: name(Quickshell.env("LANG") ?? "")
  readonly property string configured: lang(overridden ? userFile.text() : systemFile.text())
  property var available: []

  // Locale without the encoding: "en_US.UTF-8" -> "en_US".
  function name(locale) {
    return locale.split(".")[0];
  }

  // The LANG value of a locale.conf.
  function lang(text) {
    const line = text.split("\n").find(line => line.startsWith("LANG="));
    return line ? name(line.slice(5)) : "";
  }

  function select(locale) {
    const lines = systemFile.text().split("\n").map(line => {
      const [key, value] = line.split("=");
      return value && !value.startsWith("C") ? `${key}=${locale}.UTF-8` : line;
    });
    userFile.setText(lines.join("\n"));
  }

  function reset() {
    Quickshell.execDetached(["rm", "-f", userPath]);
  }

  FileView {
    id: systemFile
    path: "/etc/locale.conf"
    blockLoading: true
  }

  FileView {
    id: userFile
    path: root.userPath
    blockLoading: true
    printErrors: false
    watchChanges: true
    onFileChanged: reload()
  }

  // Generated locales, without C.
  Process {
    running: true
    command: ["localectl", "list-locales"]
    stdout: StdioCollector {
      onStreamFinished: root.available = text.split("\n")
        .filter(locale => locale && !locale.startsWith("C"))
        .map(locale => root.name(locale))
    }
  }
}
