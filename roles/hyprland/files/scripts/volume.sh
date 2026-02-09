#!/bin/bash

get_volume() {
    local volume_status=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
    if [[ "$volume_status" == *"MUTED"* ]]; then
        muted=true
    else
        muted=false
    fi
    volume=$(echo "$volume_status" | cut -d' ' -f2 | awk '{printf "%d\n", $1 * 100}')
}

get_mic() {
    local mic_status=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)
    if [[ "$mic_status" == *"MUTED"* ]]; then
        muted=true
    else
        muted=false
    fi
    volume=$(echo "$mic_status" | cut -d' ' -f2 | awk '{printf "%d\n", $1 * 100}')
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
    if [[ "$label" == "Volume" ]]; then
        local mute_icon=" "
        local icon=" "
    elif [[ "$label" == "Mic" ]]; then
        local mute_icon=" "
        local icon=""
    fi
    local value="$2"
    if $muted; then
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
        get_volume
        notify "Volume" "$volume"
        ;;
    "--set")
        set_volume "${STEP}%"
        get_volume
        notify "Volume" "$volume"
        ;;
    "--inc")
        set_volume "${STEP}%+"
        get_volume
        notify "Volume" "$volume"
        ;;
    "--dec")
        set_volume "${STEP}%-"
        get_volume
        notify "Volume" "$volume"
        ;;
    "--toggle-mute-vol")
        mute_volume
        get_volume
        notify "Volume" "$volume"
        ;;
    "--toggle-mute-mic")
        mute_mic
        get_mic
        notify "Mic" "$volume"
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
