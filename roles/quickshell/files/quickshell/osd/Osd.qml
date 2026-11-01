import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import qs

// On-screen display for volume, mic mute and brightness, bottom center of the
// focused monitor. Volume and mic follow PipeWire directly, so changes from any
// app or key show up; brightness comes from brightness.sh:
//
//   qs ipc call osd brightness 42
Scope {
  id: root

  readonly property PwNode sink: Pipewire.defaultAudioSink
  readonly property PwNode source: Pipewire.defaultAudioSource

  property string icon
  property int value
  property bool muted
  property bool shown: false
  // PipeWire reports volume changes when a device is (re)bound, e.g. on startup
  // or when switching outputs; ignore those for a moment.
  property bool armed: false

  function show(icon, value, muted) {
    if (!armed) return;
    root.icon = icon;
    root.value = value;
    root.muted = muted;
    shown = true;
    hideTimer.restart();
  }

  function showVolume() {
    const audio = sink.audio;
    show(audio.muted ? "" : "", Math.round(audio.volume * 100), audio.muted);
  }

  function showMic() {
    const audio = source.audio;
    show(audio.muted ? "" : "", Math.round(audio.volume * 100), audio.muted);
  }

  onSinkChanged: rearm()
  onSourceChanged: rearm()

  function rearm() {
    armed = false;
    armTimer.restart();
  }

  Timer {
    id: armTimer
    interval: 500
    onTriggered: root.armed = true
  }

  Timer {
    id: hideTimer
    interval: 1500
    onTriggered: root.shown = false
  }

  PwObjectTracker {
    objects: [root.sink, root.source]
  }

  Connections {
    target: root.sink ? root.sink.audio : null
    function onVolumeChanged() { root.showVolume(); }
    function onMutedChanged() { root.showVolume(); }
  }

  // Only mute: apps with auto gain (browsers, Teams) keep changing mic volume.
  Connections {
    target: root.source ? root.source.audio : null
    function onMutedChanged() { root.showMic(); }
  }

  IpcHandler {
    target: "osd"

    function brightness(value: int): void {
      root.show("", value, false);
    }
  }

  PanelWindow {
    visible: root.shown
    anchors.bottom: true
    margins.bottom: 100
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-osd"
    color: "transparent"
    implicitWidth: 300
    implicitHeight: 50
    // Click-through.
    mask: Region {}

    Rectangle {
      anchors.fill: parent
      radius: 5
      color: Theme.background
      border.width: 2
      border.color: Theme.accent

      RowLayout {
        anchors {
          fill: parent
          leftMargin: 15
          rightMargin: 15
        }
        spacing: 12

        Text {
          Layout.preferredWidth: 24
          horizontalAlignment: Text.AlignHCenter
          text: root.icon
          color: Theme.foreground
          font.family: Theme.monoFont
          font.pixelSize: 20
        }

        Rectangle {
          Layout.fillWidth: true
          implicitHeight: 6
          radius: 3
          color: Qt.alpha(Theme.foreground, 0.2)

          Rectangle {
            width: parent.width * Math.min(Math.max(root.value, 0), 100) / 100
            height: parent.height
            radius: parent.radius
            color: root.muted ? Qt.alpha(Theme.foreground, 0.4) : Theme.accent
          }
        }

        Text {
          Layout.preferredWidth: 40
          horizontalAlignment: Text.AlignRight
          text: root.muted ? "mute" : root.value + "%"
          color: Theme.foreground
          font.family: Theme.font
          font.pixelSize: 14
        }
      }
    }
