#!/bin/bash

# Default temperature values
TEMP_ON=4000
TEMP_OFF=6000
# hyprsunset supported range
TEMP_MIN=1000
TEMP_MAX=20000

get_temp() {
    local temp="$(hyprctl hyprsunset temperature 2>/dev/null | grep -oE '[0-9]+')"
    echo "$temp"
}

get_status() {
    read -r temp <<< "$(get_temp)"
    local waybar_status=""
    if [[ -n "$temp" && "$temp" -lt "$TEMP_OFF" ]]; then
        waybar_status=$(printf '{"alt": "on", "tooltip": "Nightshift On (temp: %s)"}' "$temp")
    else
        waybar_status=$(printf '{"alt": "off", "tooltip": "Nightshift Off (temp: %s)"}' "$temp")
    fi
    echo "${waybar_status}"
}

set_temp() {
    local temp=$1
    hyprctl hyprsunset temperature $temp 2>/dev/null 1>&2
    notify "" "" "$temp"
    pkill -x -SIGRTMIN+6 waybar
}

step_temp() {
    local step=$1
    read -r temp <<< "$(get_temp)"
    [[ -z "$temp" ]] && return
    temp=$((temp + step))
    (( temp < TEMP_MIN )) && temp=$TEMP_MIN
    (( temp > TEMP_MAX )) && temp=$TEMP_MAX
    set_temp "$temp"
}

toggle_nightshift() {
    read -r temp <<< "$(get_temp)"
    if [[ -n "$temp" && "$temp" -lt "$TEMP_OFF" ]]; then
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
    "--inc")
        step_temp "${2:-250}"
        ;;
    "--dec")
        step_temp "-${2:-250}"
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
        echo -e "  --inc [arg]    to increment current screen temprature by [arg]K"
        echo -e "  --dec [arg]    to decrement current screen temprature by [arg]K"
        echo -e "  --toggle       to toggle sunset/nightshift"
        echo -e " --staus         to get the (waybar) JSON staus"
        exit 0
        ;;
esac
