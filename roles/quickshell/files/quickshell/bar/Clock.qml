import QtQuick
import Quickshell

// Date (in the LC_TIME locale) and time. Click for the long date, right click
// opens the calendar.
BarItem {
  property bool long: false

  // ISO week: the week of this week's Thursday, counted from January 1st.
  function week(date) {
    const thursday = new Date(date);
    thursday.setDate(date.getDate() + 4 - (date.getDay() || 7));
    const days = Math.round((thursday - new Date(thursday.getFullYear(), 0, 1)) / 864e5);
    return Math.floor(days / 7) + 1;
  }

  // Qt abbreviates with dots ("Di. Nov."), waybar didn't.
  readonly property string day: long
    ? `${Qt.locale().toString(clock.date, "dddd dd MMMM yyyy")} (W${week(clock.date)})`
    : Qt.locale().toString(clock.date, "ddd MMM dd")

  padding: 5
  text: `󰸘 ${day} - \uf017 ${Qt.formatTime(clock.date, "HH:mm")}`
  onClicked: long = !long
  onRightClicked: Quickshell.execDetached(["uwsm-app", "--", "gnome-calendar"])

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }
}
