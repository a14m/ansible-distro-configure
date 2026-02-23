#!/bin/bash

shutdown() {
  hyprshutdown -t "Shutting down..." --post-cmd "systemctl poweroff"
}

reboot() {
  hyprshutdown -t "Restarting..." --post-cmd "systemctl reboot"
}

hibernate() {
  systemctl suspend
}

lock_screen() {
  loginctl lock-session
}

interactive() {
  # Use the commented styling to get tofi fullscreen theme instead of
  # using the hpyrland windowrule workaround to get the dimming effect
  # --width 100% \
  # --height 120% \
  # --font-size 20 \
  # --anchor center \
  # --border-width 0 \
  # --outline-width 0 \
  # --padding-top 50% \
  # --padding-left 42% \
  # --result-spacing 10 \
  # --placeholder-text "" \
  # --prompt-text "Power:" \
  # --background-color "#000B"
  ACTION=$(printf ' Shutdown\n󰑙 Reboot\n󰤄 Suspend\n Lock Session' | tofi \
    --width 450 \
    --height 300 \
    --font-size 20 \
    --anchor center \
    --prompt-text "Power:" \
    --placeholder-text "" \
    --result-spacing 10
  )


  case "$ACTION" in
    *Shutdown*)
      shutdown
      ;;
    *Reboot*)
      reboot
      ;;
    *Suspend*)
      lock_screen
      hibernate
      ;;
    *Lock*)
      lock_screen
      ;;
  esac
}

case "$1" in
    "--shutdown")
        shutdown
        ;;
    "--reboot")
        reboot
        ;;
    "--hibernate")
        lock_screen
        hibernate
        ;;
    "--lock")
        lock_screen
        ;;
    *)
        interactive
        ;;
esac
