pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs

// Launcher: apps, hyprtheme themes or wallpapers in a search box
// on the focused monitor, with every monitor dimmed. Type to filter, arrows to
// pick, Enter to run, Esc or a click outside to close.
//
//   qs ipc call launcher apps
//   qs ipc call launcher themes
//   qs ipc call launcher wallpapers
Singleton {
  id: root

  readonly property string hyprtheme: Quickshell.env("HOME") + "/.config/hyprtheme"

  property bool open: false
  property string mode: "apps"
  property ShellScreen screen
  property string query: ""
  property int selected: 0
  // Filled when the themes or wallpapers mode opens; `current` is the active one.
  property var themes: []
  property var wallpapers: []
  property string current: ""

  readonly property var prompts: ({ apps: "Run:", themes: "Theme:", wallpapers: "Wallpaper:" })
  readonly property int columns: 3
  readonly property int rowHeight: 48

  // Rows of the active mode, filtered by the query; names starting with it first.
  readonly property var items: {
    const text = query.toLowerCase();
    let list = [];
    if (mode === "apps") {
      list = [...DesktopEntries.applications.values].map(app => ({
        title: app.name,
        detail: app.genericName,
        icon: app.icon,
        value: app.id,
        search: [app.name, app.genericName, app.id, ...app.keywords].join(" ").toLowerCase(),
      }));
    } else if (mode === "themes") {
      list = themes.map(theme => ({ title: theme.name, colors: theme.colors, value: theme.name }));
    } else {
      list = wallpapers.map(file => ({ title: file, image: `${hyprtheme}/current/wallpapers/${file}`, value: file }));
    }
    const prefixed = item => item.title.toLowerCase().startsWith(text);
    return list
      .filter(item => (item.search ?? item.title.toLowerCase()).includes(text))
      .sort((a, b) => prefixed(b) - prefixed(a) || a.title.localeCompare(b.title));
  }

  function show(newMode) {
    if (open && mode === newMode) {
      open = false;
      return;
    }
    mode = newMode;
    query = "";
    selected = 0;
    screen = Quickshell.screens.find(screen => screen.name === Hyprland.focusedMonitor?.name) ?? null;
    if (mode === "themes") themeQuery.running = true;
    if (mode === "wallpapers") wallpaperQuery.running = true;
    open = true;
  }

  // Icon names go through the icon theme; some entries give a file path instead.
  function iconSource(icon) {
    return icon.startsWith("/") ? `file://${icon}` : Quickshell.iconPath(icon, true);
  }

  function move(delta) {
    selected = Math.max(0, Math.min(items.length - 1, selected + delta));
  }

  // Like move(), but wraps around at the ends (Tab and Shift+Tab).
  function cycle(delta) {
    if (items.length) selected = (selected + delta + items.length) % items.length;
  }

  function run(item) {
    if (!item) return;
    open = false;
    if (mode === "apps") Quickshell.execDetached(["uwsm", "app", "--", `${item.value}.desktop`]);
    if (mode === "themes") Quickshell.execDetached([`${hyprtheme}/scripts/theme.sh`, item.value]);
    if (mode === "wallpapers") Quickshell.execDetached([`${hyprtheme}/scripts/wallpaper.sh`, item.image]);
  }

  IpcHandler {
    target: "launcher"
    function apps(): void { root.show("apps"); }
    function themes(): void { root.show("themes"); }
    function wallpapers(): void { root.show("wallpapers"); }
  }

  // First line: the active theme; then "<name>\t<quickshell.json>" per theme.
  Process {
    id: themeQuery
    command: ["sh", "-c", 'cd "$1" && basename "$(readlink current)" && for d in themes/*/; do '
      + 'printf "%s\\t%s\\n" "$(basename "$d")" "$(tr -d "\\n" < "$d/quickshell.json")"; done', "sh", root.hyprtheme]
    stdout: StdioCollector {
      onStreamFinished: {
        const lines = text.trim().split("\n");
        root.current = lines.shift();
        root.themes = lines.map(line => {
          const [name, json] = line.split("\t");
          const theme = JSON.parse(json || "{}");
          return { name: name, colors: [theme.background, theme.foreground, theme.accent] };
        });
      }
    }
  }

  // First line: the active wallpaper; then the theme's wallpapers.
  Process {
    id: wallpaperQuery
    command: ["sh", "-c", 'cd "$1/current" && basename "$(readlink wallpaper)" && ls wallpapers', "sh", root.hyprtheme]
    stdout: StdioCollector {
      onStreamFinished: {
        const lines = text.trim().split("\n");
        root.current = lines.shift();
        root.wallpapers = lines;
      }
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: window

      required property ShellScreen modelData
      readonly property bool hasMenu: modelData === root.screen

      screen: modelData
      visible: root.open
      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: hasMenu ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
      WlrLayershell.namespace: "quickshell-launcher"
      color: Qt.rgba(0, 0, 0, 0.5)

      MouseArea {
        anchors.fill: parent
        onClicked: root.open = false
      }

      Panel {
        visible: window.hasMenu
        anchors.centerIn: parent
        width: 600
        height: content.implicitHeight + 28

        // Keeps clicks inside the box from closing it.
        MouseArea {
          anchors.fill: parent
        }

        Column {
          id: content
          x: 14
          y: 14
          width: parent.width - 28
          spacing: 14

          Row {
            spacing: 10

            Text {
              text: root.prompts[root.mode]
              color: Theme.accent
              font.family: Theme.monoFont
              font.pixelSize: 16
            }

            TextInput {
              width: content.width - 120
              focus: window.hasMenu && root.open
              text: root.query
              color: Theme.foreground
              font.family: Theme.monoFont
              font.pixelSize: 16
              onTextEdited: {
                root.query = text;
                root.selected = 0;
              }
              Keys.onEscapePressed: root.open = false
              Keys.onReturnPressed: root.run(root.items[root.selected])
              Keys.onEnterPressed: root.run(root.items[root.selected])
              Keys.onUpPressed: root.move(root.mode === "wallpapers" ? -root.columns : -1)
              Keys.onDownPressed: root.move(root.mode === "wallpapers" ? root.columns : 1)
              Keys.onTabPressed: root.cycle(1)
              Keys.onBacktabPressed: root.cycle(-1)
            }
          }

          // Apps and themes: one row each.
          ListView {
            visible: root.mode !== "wallpapers"
            width: content.width
            height: Math.min(count, 10) * root.rowHeight
            clip: true
            model: root.mode !== "wallpapers" ? root.items : []
            currentIndex: root.selected

            delegate: Item {
              required property var modelData
              required property int index
              readonly property bool selected: index === root.selected

              width: ListView.view.width
              height: root.rowHeight

              Row {
                anchors.verticalCenter: parent.verticalCenter
                x: 10
                spacing: 10

                IconImage {
                  visible: root.mode === "apps"
                  anchors.verticalCenter: parent.verticalCenter
                  implicitSize: 28
                  source: root.iconSource(modelData.icon ?? "")
                }

                // Theme colors: background, foreground, accent.
                Repeater {
                  model: modelData.colors ?? []

                  Rectangle {
                    required property string modelData
                    anchors.verticalCenter: parent.verticalCenter
                    width: 16
                    height: 16
                    radius: 3
                    color: modelData
                    border.width: 1
                    border.color: Theme.inactive
                  }
                }

                Text {
                  anchors.verticalCenter: parent.verticalCenter
                  text: modelData.title
                    + (root.mode === "themes" && modelData.value === root.current ? "  (current)" : "")
                  color: selected ? Theme.accent : Theme.foreground
                  font.family: Theme.monoFont
                  font.pixelSize: 17
                }

                Text {
                  visible: !!modelData.detail
                  anchors.verticalCenter: parent.verticalCenter
                  text: modelData.detail ?? ""
                  color: Theme.inactive
                  font.family: Theme.monoFont
                  font.pixelSize: 14
                }
              }

              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: root.selected = index
                onClicked: root.run(modelData)
              }
            }
          }

          // Wallpapers: thumbnails.
          GridView {
            visible: root.mode === "wallpapers"
            width: content.width
            height: Math.min(Math.ceil(count / root.columns), 3) * cellHeight
            clip: true
            cellWidth: width / root.columns
            cellHeight: 120
            model: root.mode === "wallpapers" ? root.items : []
            currentIndex: root.selected

            delegate: Item {
              required property var modelData
              required property int index
              readonly property bool selected: index === root.selected

              width: GridView.view.cellWidth
              height: GridView.view.cellHeight

              Rectangle {
                anchors.fill: parent
                anchors.margins: 8
                radius: 5
                color: "transparent"
                border.width: 2
                border.color: selected ? Theme.accent
                  : modelData.value === root.current ? Theme.foreground
                  : "transparent"

                Image {
                  anchors.fill: parent
                  anchors.margins: 4
                  source: modelData.image ?? ""
                  sourceSize.width: 360
                  fillMode: Image.PreserveAspectCrop
                  asynchronous: true
                }
              }

              MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: root.selected = index
                onClicked: root.run(modelData)
              }
            }
          }
        }
      }
    }
  }
}
