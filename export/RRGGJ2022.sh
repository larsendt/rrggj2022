#!/bin/sh
echo -ne '\033c\033]0;RRGGJ2022\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/RRGGJ2022.x86_64" "$@"
