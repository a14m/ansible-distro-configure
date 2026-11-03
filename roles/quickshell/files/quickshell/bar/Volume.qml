import QtQuick
import Quickshell.Services.Pipewire

// Output volume. Click toggles mute, scroll changes it by 5%, right click
// opens wiremix.
BarItem {
  id: root

  readonly property PwNode sink: Pipewire.defaultAudioSink
  readonly property real volume: sink?.audio?.volume ?? 0
  readonly property bool muted: sink?.audio?.muted ?? false

  readonly property string levelIcon: ["", "", ""][Math.min(2, Math.floor(volume * 3))]

  text: muted ? "\ueee8" : levelIcon
  tooltip: `Volume: ${Math.round(volume * 100)}% ${levelIcon}`
  onClicked: sink.audio.muted = !muted
  onRightClicked: tui("wiremix")

  PwObjectTracker {
    objects: [root.sink]
  }

  WheelHandler {
    onWheel: event => {
      const step = event.angleDelta.y > 0 ? 0.05 : -0.05;
      root.sink.audio.volume = Math.max(0, Math.min(1, root.volume + step));
    }
  }
}
