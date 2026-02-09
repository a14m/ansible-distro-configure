#!/bin/bash

# Original Inspiration:
#  - https://github.com/basecamp/omarchy/issues/2509
#  - https://albert.nz/hyprland-brightness
# ---------------------

# Get focused monitor name
get_focused_display_name() {
    hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name'
}

# Get focused monitor serial
get_focused_display_serial() {
    hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .serial'
}

set_brightness_ddcutil() {
    local display_serial="$1"
    local step="$2"
    local direction="$3"
    ddcutil \
        --noconfig \
        --skip-ddc-checks \
        --sleep-multiplier=0.1 \
        --sn="$display_serial" \
        setvcp 10 $direction "$step"
}

set_brightness_brightnessctl() {
    local step="$1"
    local direction="$2"
    brightnessctl set "${step}%${direction}"
}

get_brightness_ddcutil() {
    local display_serial="$1"
    ddcutil \
        --noconfig \
        --skip-ddc-checks \
        --sleep-multiplier=0.1 \
        --sn="$display_serial" \
        --terse getvcp 10 \
        | awk '{print $4}'
}

get_brightness_brightnessctl() {
    brightnessctl -m | cut -d, -f4 | sed 's/%//'
}


# Get current brightness for a specific monitor
get_current_brightness() {
    local display_name=$(get_focused_display_name)
    local display_serial=$(get_focused_display_serial)
    if [ "$display_name" = "eDP-1" ]; then
        echo "$(get_brightness_brightnessctl)"
    elif [ -n "$display_serial" ]; then
        echo "$(get_brightness_ddcutil $display_serial)"
    else
        echo "N/A"
    fi
}

# Set brightness for a specific monitor
set_brightness() {
    local step="$1"
    local direction="$2"
    local display_name=$(get_focused_display_name)
    local display_serial=$(get_focused_display_serial)

    if [ "$display_name" = "eDP-1" ]; then
        set_brighntess_brightnessctl $step $direction
    elif [ -n "$display_serial" ]; then
        set_brightness_ddcutil $display_serial $step $direction
    else
        return
    fi

    notify $display_serial $display_name $(get_current_brightness)
}

notify() {
    serial="$1"
    name="$2"
    value="$3"
    notify-send -e \
        -h string:x-canonical-private-synchronous:brightness-$serial \
        -u low \
        "Brightness" \
        "   $name: $value%"
}

STEP="${2:-1}"
case "$1" in
    "--get")
        value=$(get_current_brightness)
        echo "${value}%"
        ;;
    "--set")
        set_brightness $STEP
        ;;
    "--inc")
        set_brightness $STEP +
        ;;
    "--dec")
        set_brightness $STEP -
        ;;
    *)
        echo -e "Usage:"
        echo -e "  --get          to get current brightness value"
        echo -e "  --set [arg]    to set current brightness value to [arg]%"
        echo -e "  --inc [arg]    to increment current brightness value by [arg]%"
        echo -e "  --dec [arg]    to decrement current brightness value by [arg]%"
        exit 0
        ;;
esac
