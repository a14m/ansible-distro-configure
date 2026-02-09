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

set_volume() {
    local volume=$1
    wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ $volume
}

mute_volume() {
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
}

mute_mic() {
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
}

notify() {
    value="$1"
    if $muted; then
        notify-send -e \
            -h string:x-canonical-private-synchronous:volume \
            -u low \
            "Volume" \
            " \tmute"
    else
        notify-send -e \
            -h string:x-canonical-private-synchronous:volume \
            -u low \
            "Volume" \
            " \t$value%"
    fi
}


STEP="${2:-1}"
case "$1" in
    "--get")
        get_volume
        notify $volume
        ;;
    "--set")
        set_volume $STEP%
        get_volume
        notify $volume
        ;;
    "--inc")
        set_volume $STEP%+
        get_volume
        notify $volume
        ;;
    "--dec")
        set_volume $STEP%-
        get_volume
        notify $volume
        ;;
    "--toggle-mute-vol")
        mute_volume
        get_volume
        notify $volume
        ;;
    "--toggle-mute-mic")
        mute_mic
        get_volume
        notify $volume
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
