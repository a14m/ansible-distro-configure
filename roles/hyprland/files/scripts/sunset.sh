#!/bin/bash

# Default temperature values
TEMP_ON=4000
TEMP_OFF=6000

get_temp() {
    local temp="$(hyprctl hyprsunset temperature 2>/dev/null | grep -oE '[0-9]+')"
    echo "$temp"
}

get_status() {
    read -r temp <<< "$(get_temp)"
    local waybar_status=""
    if [[ "$temp" == "$TEMP_ON" ]]; then
        waybar_status=$(printf '{"alt": "on", "tooltip": "Nightshift On (temp: %s)"}' "$temp")
    else
        waybar_status=$(printf '{"alt": "off", "tooltip": "Nightshift Off (temp: %s)"}' "$temp")
    fi
    echo "${waybar_status}"
}

set_temp() {
    local temp=$1
    hyprctl hyprsunset temperature $temp 2>/dev/null 1>&2
    notify "" "" "$TEMP"
    pkill -x -SIGRTMIN+6 waybar
}

toggle_nightshift() {
    read -r temp <<< "$(get_temp)"
    if [[ "$temp" == "$TEMP_ON" ]]; then
        set_temp $TEMP_OFF
        temp=$TEMP_OFF
        class="off"
        icon=""
    else
        set_temp $TEMP_ON
        temp=$TEMP_ON
        class="on"
        icon=""
    fi
    notify "$class" "$icon" "$temp"
    pkill -x -SIGRTMIN+6 waybar
}

notify() {
    local class="$1"
    local icon="$2"
    local temp="$3"
    notify-send -e \
        -h string:x-canonical-private-synchronous:sunset \
        -u low \
        "Nightshift ${class}" \
        "${icon}   Temprature: ${temp}"
}

TEMP="${2:-$TEMP_ON}"
case "$1" in
    "--get")
        read -r temp <<< "$(get_temp)"
        echo "${temp}"
        ;;
    "--set")
        set_temp "$TEMP"
        ;;
    "--status")
        get_status
        ;;
    "--toggle")
        toggle_nightshift
        ;;
    *)
        echo -e "Usage:"
        echo -e "  --get          to get current screen temprature value"
        echo -e "  --set [arg]    to set current screen temprature to [arg]"
        echo -e "  --toggle       to toggle sunset/nightshift"
        echo -e " --staus         to get the (waybar) JSON staus"
        exit 0
        ;;
esac
