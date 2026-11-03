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
        echo -e "Usage:"
        echo -e "  --shutdown    to shut down"
        echo -e "  --reboot      to reboot"
        echo -e "  --hibernate   to lock and suspend"
        echo -e "  --lock        to lock the session"
        exit 0
        ;;
esac
