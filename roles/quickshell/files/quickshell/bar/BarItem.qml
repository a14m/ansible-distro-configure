import QtQuick
import Quickshell
import qs

// Bar text with an optional tooltip. Unless `interactive` is false, it is
// clickable and highlighted on hover. Setting `popup` makes right click toggle
// that BarPopup; the item stays highlighted and its tooltip hidden while open.
Text {
  id: root

  property int padding: 10
  property bool interactive: true
  property color baseColor: Theme.foreground
  property string tooltip: ""
  property var popup: null
  readonly property bool tooltipShown: tooltipWindow.visible

  signal clicked
  signal rightClicked

  // Opens a terminal app (wlctl, bluetui, ...) in its own floating window.
  function tui(app) {
    Quickshell.execDetached(["/etc/hypr/scripts/launch-tui", app]);
  }

  height: parent.height
  leftPadding: padding
  rightPadding: padding
  verticalAlignment: Text.AlignVCenter
  color: interactive && hover.hovered || popup?.open ? Theme.accent : baseColor
  font.family: Theme.monoFont
  font.pixelSize: 14

  HoverHandler {
    id: hover
    cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
  }

  TapHandler {
    enabled: root.interactive
    acceptedButtons: Qt.LeftButton
    onTapped: root.clicked()
  }

  TapHandler {
    enabled: root.interactive
    acceptedButtons: Qt.RightButton
    onTapped: {
      if (root.popup) root.popup.open = !root.popup.open;
      root.rightClicked();
    }
  }

  // Shown below the item after hovering for a moment.
  Timer {
    id: tooltipDelay
    running: hover.hovered
    interval: 500
  }

  PopupWindow {
    id: tooltipWindow
    visible: hover.hovered && !tooltipDelay.running && root.tooltip !== "" && !root.popup?.open
    anchor.item: root
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.bottom: -5
    implicitWidth: label.implicitWidth + 20
    implicitHeight: label.implicitHeight + 12
    color: "transparent"
    mask: Region {}

    Panel {
      anchors.fill: parent
      border.width: 1

      Text {
        id: label
        anchors.centerIn: parent
        text: root.tooltip
        color: Theme.foreground
        font.family: Theme.monoFont
        font.pixelSize: 13
      }
    }
  }
}
