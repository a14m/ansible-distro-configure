import QtQuick
import qs.services

// System locale of this session. Right click opens a popup to pick the locale
// for the next login.
BarItem {
  id: root

  function describe(locale) {
    const qtLocale = Qt.locale(locale);
    return `${locale}  ${qtLocale.nativeLanguageName} (${qtLocale.nativeTerritoryName})`;
  }

  text: ` ${Locales.session}`
  popup: popup

  BarPopup {
    id: popup
    item: root
    title: "System locale"

    Repeater {
      model: Locales.available

      PopupText {
        required property string modelData

        text: root.describe(modelData)
        highlighted: Locales.overridden && modelData === Locales.configured
        clickable: true
        onClicked: Locales.select(modelData)
      }
    }

    PopupText {
      text: "System default"
      highlighted: !Locales.overridden
      clickable: true
      onClicked: Locales.reset()
    }

    PopupText {
      visible: Locales.configured !== Locales.session
      text: `${Locales.configured} applies after logging in again`
    }
  }
}
