#!/usr/bin/env sh

# font size
rofiScale="10"

# window width / board
width=2
border=4

# rofi config path
confDir="${HOME}/.config"

roconf="${confDir}/rofi/styles/style.rasi"

case "${1}" in
    d|--drun) r_mode="drun" ;;
    w|--window) r_mode="window" ;;
    f|--filebrowser) r_mode="filebrowser" ;;
    h|--help)
        echo -e "$(basename "${0}") [action]"
        echo "d :  drun mode"
        echo "w :  window mode"
        echo "f :  filebrowser mode"
        exit 0
        ;;
    *) r_mode="drun" ;;
esac

wind_border=$(( border * 3 ))
[ "${border}" -eq 0 ] && elem_border=10 || elem_border=$(( border * 2 ))

r_override="window {border: ${width}px; border-radius: ${wind_border}px;} element {border-radius: ${elem_border}px;}"
r_scale="configuration {font: \"JetBrainsMono Nerd Font ${rofiScale}\";}"

# get genome icon style
if command -v gsettings >/dev/null; then
    i_theme="$(gsettings get org.gnome.desktop.interface icon-theme | sed "s/'//g")"
    i_override="configuration {icon-theme: \"${i_theme}\";}"
else
    i_override=""
fi

# ===== 🚀 launch rofi =====

rofi -show "${r_mode}" \
     -theme-str "${r_scale}" \
     -theme-str "${r_override}" \
     -theme-str "${i_override}" \
     -config "${roconf}"