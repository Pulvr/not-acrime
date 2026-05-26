#!/bin/sh
printf '\033c\033]0;%s\a' notAcrime
base_path="$(dirname "$(realpath "$0")")"
"$base_path/notAcrime.x86_64" "$@"
