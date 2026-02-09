#!/bin/bash

get_volume() {
    local status=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
    local vol=$(echo "$status" | cut -d' ' -f2 | awk '{printf "%d\n", $1 * 100}')
    local muted=false
    [[ "$status" == *"MUTED"* ]] && muted=true
    echo "$muted $vol"
}

get_mic() {
    local status=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)
    local vol=$(echo "$status" | cut -d' ' -f2 | awk '{printf "%d\n", $1 * 100}')
    local muted=false
    [[ "$status" == *"MUTED"* ]] && muted=true
    echo "$muted $vol"
}

set_volume() {
    wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ "$1"
}

mute_volume() {
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
}

mute_mic() {
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
}

notify() {
    local label="$1"
    local muted="$2"
    local value="$3"
    if [[ "$label" == "Volume" ]]; then
        local mute_icon=" "
        local icon=" "
    elif [[ "$label" == "Mic" ]]; then
        local mute_icon=" "
        local icon=""
    fi
    if [[ "$muted" == true ]]; then
        notify-send -e \
            -h string:x-canonical-private-synchronous:volume \
            -u low \
            "$label" \
            "$mute_icon\tmute"
    else
        notify-send -e \
            -h string:x-canonical-private-synchronous:volume \
            -u low \
            "$label" \
            "$icon\t${value}%"
    fi
}


STEP="${2:-1}"
case "$1" in
    "--get")
        read -r muted volume <<< "$(get_volume)"
        notify "Volume" "$muted" "$volume"
        ;;
    "--set")
        set_volume "${STEP}%"
        read -r muted volume <<< "$(get_volume)"
        notify "Volume" "$muted" "$volume"
        ;;
    "--inc")
        set_volume "${STEP}%+"
        read -r muted volume <<< "$(get_volume)"
        notify "Volume" "$muted" "$volume"
        ;;
    "--dec")
        set_volume "${STEP}%-"
        read -r muted volume <<< "$(get_volume)"
        notify "Volume" "$muted" "$volume"
        ;;
    "--toggle-mute-vol")
        mute_volume
        read -r muted volume <<< "$(get_volume)"
        notify "Volume" "$muted" "$volume"
        ;;
    "--toggle-mute-mic")
        mute_mic
        read -r muted volume <<< "$(get_mic)"
        notify "Mic" "$muted" "$volume"
        ;;
    *)
        echo -e "Usage:"
        echo -e "  --get                 to get current volume value"
        echo -e "  --toggle-mute-vol     to toggle mute output volume"
        echo -e "  --toggle-mute-mic     to toggle mute input mic"
        echo -e "  --set [arg]           to set current volume value to [arg]%"
        echo -e "  --inc [arg]           to increment current volume value by [arg]%"
        echo -e "  --dec [arg]           to decrement current volume value by [arg]%"
        exit 0
        ;;
esac
