#!/bin/bash

turn_on() {
    rfkill unblock bluetooth
    bluetoothctl power on
    notify "on"
}

turn_off() {
    rfkill unblock bluetooth
    bluetoothctl power off
    notify "off"
}

toggle() {
    if bluetoothctl <<< show | grep -q "Powered: yes"; then
        turn_off
    else
        turn_on
    fi
}

notify() {
    local class="$1"
    notify-send -e \
        -h string:x-canonical-private-synchronous:bluetooth \
        -u low \
        "Bluetooth" \
        "   ${class}"
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
        echo -e "  --on      to turn bluetooth on"
        echo -e "  --off     to turn bluetooth off"
        echo -e "  --toggle  to toggle bluetooth state"
        exit 0
        ;;
esac
