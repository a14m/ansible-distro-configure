#!/bin/bash

# Quickshell shows the volume OSD by watching PipeWire, so nothing to notify here.

get_volume() {
    local status=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
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

STEP="${2:-1}"
case "$1" in
    "--get")
        read -r muted volume <<< "$(get_volume)"
        [[ "$muted" == true ]] && echo "mute" || echo "${volume}%"
        ;;
    "--set")
        set_volume "${STEP}%"
        ;;
    "--inc")
        set_volume "${STEP}%+"
        ;;
    "--dec")
        set_volume "${STEP}%-"
        ;;
    "--toggle-mute-vol")
        mute_volume
        ;;
    "--toggle-mute-mic")
        mute_mic
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
