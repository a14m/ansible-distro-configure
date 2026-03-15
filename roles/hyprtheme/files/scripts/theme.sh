#!/bin/bash

show_themes() {
  local available_themes=$(ls -1p $HOME/.config/hyprtheme/themes/ | grep "/" | cut -f1 -d'/')
  local selected_theme=$(printf "$available_themes" | tofi \
    --prompt-text "Select: " \
    --placeholder-text "Theme"
  )

  if [[ -n "$selected_theme" ]]; then
    select_theme "$selected_theme"
  fi
}

select_theme() {
  local theme_name="$1"
  local themes_path="$HOME/.config/hyprtheme/themes"
  local current_theme_path="$HOME/.config/hyprtheme/current"

  if [[ ! -d "$themes_path/$theme_name" ]]; then
    notify-send -e \
        -h string:x-canonical-private-synchronous:themes \
        -u critical \
        "Theme" \
        "Theme '$theme_name' doesn't exist"
    exit 1
  fi

  # Get close to as atomic as possible.
  ln -sfn "$themes_path/$theme_name" "$current_theme_path.new"
  rm -rf "$current_theme_path"
  mv "$current_theme_path.new" "$current_theme_path"

  # Prompt wallpaper selection
  "$HOME/.config/hyprtheme/scripts/wallpaper.sh" #$(find "$current_theme_path/wallpapers" -type f | head -1)

  pkill -x waybar || true
  setsid uwsm-app -- waybar >/dev/null 2>&1 &

  hyprctl reload >/dev/null 2>&1

  pkill -SIGUSR2 btop || true

  makoctl reload

  if [[ -f ~/.config/alacritty/alacritty.toml ]]; then
    touch ~/.config/alacritty/alacritty.toml
  fi
  killall -SIGUSR1 kitty >/dev/null 2>&1 || true
  killall -SIGUSR2 ghostty >/dev/null 2>&1 || true

  if [[ -f ~/.config/hyprtheme/current/light.mode ]]; then
    gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
    gsettings set org.gnome.desktop.interface gtk-theme "Adwaita"
    gsettings set org.gnome.desktop.interface font-name "Noto Sans"
  else
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
    gsettings set org.gnome.desktop.interface font-name "Noto Sans"
  fi
}

if [[ -z "$1" ]]; then
  show_themes
else
  select_theme "$1"
fi
