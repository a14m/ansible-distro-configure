#!/bin/bash

turn_on() {
    rfkill unblock wifi
    nmcli radio wifi on
    notify "on"
}

turn_off() {
    nmcli radio wifi off
    rfkill unblock wifi
    notify "off"
}

toggle() {
    if nmcli radio wifi | grep -q "enabled"; then
        turn_off
    else
        turn_on
    fi
}

notify() {
    local class="$1"
    notify-send -e \
        -h string:x-canonical-private-synchronous:wifi \
        -u low \
        "Wifi" \
        "󰖩  ${class}"
}

case "$1" in
    "--on")
        turn_on
        ;;
    "--off")
        turn_off
        ;;
    "--toggle")
        toggle
        ;;
    *)
        echo -e "Usage:"
        echo -e "  --on      to turn wifi on"
        echo -e "  --off     to turn wifi off"
        echo -e "  --toggle  to toggle wifi state"
        exit 0
        ;;
esac
