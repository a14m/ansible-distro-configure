#!/bin/bash

# Seconds between checks for active (incoming) ssh connections
INTERVAL=60

# sshd forks one sshd-session process per incoming connection
ssh_active() {
    pgrep -x sshd-session >/dev/null
}

# Suspend once there are no active ssh connections
suspend() {
    while ssh_active; do
        sleep "$INTERVAL"
    done
    systemctl suspend
}

# Stop a suspend still waiting on ssh connections
cancel() {
    pkill -f "$(basename "$0") --suspend"
}

case "$1" in
    "--suspend")
        suspend
        ;;
    "--cancel")
        cancel
        ;;
    "--status")
        ssh_active && echo "ssh active" || echo "ssh inactive"
        ;;
    *)
        echo -e "Usage:"
        echo -e "  --suspend      to suspend when no ssh connection is active"
        echo -e "  --cancel       to cancel a suspend waiting on ssh connections"
        echo -e "  --status       to get the ssh connection status"
        exit 0
        ;;
esac
