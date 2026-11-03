import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs

// Output volume. Click toggles mute, right click opens the mixer popup: every
// output and input, plus apps playing audio.
BarItem {
  id: root

  readonly property PwNode sink: Pipewire.defaultAudioSink
  readonly property real volume: sink?.audio?.volume ?? 0
  readonly property bool muted: sink?.audio?.muted ?? false

  readonly property string levelIcon: ["", "", ""][Math.min(2, Math.floor(volume * 3))]

  text: muted ? "\ueee8" : levelIcon
  tooltip: popup.open ? "" : `Volume: ${Math.round(volume * 100)}% ${levelIcon}`
  baseColor: popup.open ? Theme.accent : Theme.foreground
  onClicked: sink.audio.muted = !muted
  onRightClicked: popup.open = !popup.open

  // Audio nodes, split into devices and app streams.
  readonly property var nodes: [...Pipewire.nodes.values].filter(node => node.audio)
  readonly property var outputs: nodes.filter(node => !node.isStream && node.isSink)
  readonly property var inputs: nodes.filter(node => !node.isStream && !node.isSink)
  // Playback streams count as sinks too.
  readonly property var apps: nodes.filter(node => node.isStream && node.isSink)

  PwObjectTracker {
    objects: popup.open ? root.nodes : [root.sink]
  }

  BarPopup {
    id: popup
    item: root

    PopupText {
      text: "Output"
      highlighted: true
    }

    Repeater {
      model: root.outputs

      VolumeSlider {
        required property PwNode modelData
        node: modelData
        current: modelData === Pipewire.defaultAudioSink
        onSelected: Pipewire.preferredDefaultAudioSink = modelData
      }
    }

    PopupText {
      text: "Input"
      highlighted: true
    }

    Repeater {
      model: root.inputs

      VolumeSlider {
        required property PwNode modelData
        node: modelData
        current: modelData === Pipewire.defaultAudioSource
        icon: "\ued03"
        mutedIcon: "\uefc6"
        onSelected: Pipewire.preferredDefaultAudioSource = modelData
      }
    }

    PopupText {
      visible: root.apps.length > 0
      text: "Apps"
      highlighted: true
    }

    Repeater {
      model: root.apps

      VolumeSlider {
        required property PwNode modelData
        node: modelData
      }
    }

    PopupText {
      text: "Open wiremix"
      clickable: true
      onClicked: {
        popup.open = false;
        root.tui("wiremix");
      }
    }
  }
}
