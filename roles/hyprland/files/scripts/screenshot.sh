#!/bin/bash
set -euo pipefail

MODE="${1:-"--region"}"

case "${MODE}" in
    "--region")
        hyprshot -m region -r -
        ;;
    "--window")
        hyprshot -m window -r -
        ;;
    *)
        echo -e "Usage:"
        echo -e "  --window       to screenshot a window application"
        echo -e "  --region       to screenshot a screen region"
        exit 0
        ;;

esac | satty --filename - --disable-notifications --output-filename "$(xdg-user-dir PICTURES)/screenshot-%Y%m%d_%H%M%S.png"
