import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// Wallpaper on every monitor, cropped to fill like `swaybg -m fill`. New
// wallpapers fade in over the old one; wallpaper.sh switches it:
//
//   qs ipc call wallpaper set <file>
Scope {
  id: root

  // hyprtheme's current wallpaper link at start; wallpaper.sh then sets the
  // file itself (reloading the same link path would just hit Qt's cache).
  property string path: Quickshell.env("HOME") + "/.config/hyprtheme/current/wallpaper"

  IpcHandler {
    target: "wallpaper"
    function set(file: string): void { root.path = file; }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: window

      required property ShellScreen modelData
      readonly property string path: root.path
      // Decode at the monitor's resolution.
      readonly property real ratio: modelData.devicePixelRatio
      readonly property size imageSize: Qt.size(width * ratio, height * ratio)

      // Crossfade: the old wallpaper moves to `previous` (instant, from Qt's
      // cache) and the new one fades in over it once loaded.
      function show(path) {
        fadeIn.stop();
        previous.source = current.source;
        current.opacity = 0;
        current.source = `file://${path}`;
        // A cached image can be ready at once, without a status change.
        if (current.status === Image.Ready) fadeIn.restart();
      }

      screen: modelData
      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Background
      WlrLayershell.namespace: "quickshell-wallpaper"
      color: "black"
      // Also for monitors plugged in after the wallpaper was set.
      Component.onCompleted: show(path)
      onPathChanged: show(path)

      Image {
        id: previous
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        sourceSize: window.imageSize
      }

      Image {
        id: current
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        sourceSize: window.imageSize
        asynchronous: true
        opacity: 0
        onStatusChanged: if (status === Image.Ready) fadeIn.restart()
      }

      NumberAnimation {
        id: fadeIn
        target: current
        property: "opacity"
        to: 1
        duration: 600
        easing.type: Easing.InOutQuad
      }
    }
  }
}
