#!/bin/bash

show_wallpapers() {
  local wallpapers_path="$HOME/.config/hyprtheme/current/wallpapers"
  local wallpapers=$(ls -1p "$wallpapers_path" 2>/dev/null)

  if [[ -z $wallpapers ]]; then
    notify-send -e \
        -h string:x-canonical-private-synchronous:wallpapers \
        -u normal \
        "Wallpapers" \
        "No wallpapers found for current theme"
    pkill -x swaybg
    setsid uwsm-app -- swaybg --color '#000000' >/dev/null 2>&1 &
    exit 0
  fi

  local selected_wallpaper=$(printf "$wallpapers" | tofi \
    --prompt-text "Select: " \
    --placeholder-text "Wallpaper"
  )
  if [[ -n $selected_wallpaper ]]; then
    select_wallpaper "$wallpapers_path/$selected_wallpaper"
  fi
}

select_wallpaper() {
  local selected_wallpaper="$1"
  if [[ ! -f "$selected_wallpaper" ]]; then
    notify-send -e \
        -h string:x-canonical-private-synchronous:wallpapers \
        -u critical \
        "Wallpapers" \
        "Wallpaper '$selected_wallpaper' doesn't exist"
    pkill -x swaybg
    setsid uwsm-app -- swaybg --color '#000000' >/dev/null 2>&1 &
    exit 0
  fi

  pkill -x swaybg
  setsid uwsm-app -- swaybg -i "$selected_wallpaper" -m fill >/dev/null 2>&1 &
}

if [[ -z "$1" ]]; then
  show_wallpapers
else
  select_wallpaper "$1"
fi
