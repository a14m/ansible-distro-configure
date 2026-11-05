#!/bin/sh
# Clipboard history for the launcher, on top of cliphist.
#   clipboard.sh list         "<id>\t<preview>\t<image file>" per entry, newest first;
#                             images are decoded to a runtime folder for thumbnails
#   clipboard.sh copy <id>    put the entry back on the clipboard
#   clipboard.sh delete <id>  remove the entry from the history

images="${XDG_RUNTIME_DIR:-/tmp}/quickshell-clipboard"

case "$1" in
  list)
    mkdir -p "$images"
    cliphist list | while IFS="$(printf '\t')" read -r id preview; do
      image=""
      case "$preview" in
        "[[ binary data"*)
          image="$images/$id"
          [ -f "$image" ] || cliphist decode "$id" > "$image"
          ;;
      esac
      printf '%s\t%s\t%s\n' "$id" "$preview" "$image"
    done
    ;;
  copy)
    cliphist decode "$2" | wl-copy
    ;;
  delete)
    printf '%s\t\n' "$2" | cliphist delete
    rm -f "$images/$2"
    ;;
esac
