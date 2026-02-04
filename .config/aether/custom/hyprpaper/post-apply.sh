#!/bin/bash
if pgrep -x hyprpaper > /dev/null; then
    # hyprpaper requires preloading before setting
    # use the symlink path
    BG="$HOME/.config/omarchy/current/background"
    hyprctl hyprpaper preload "$BG"
    hyprctl hyprpaper wallpaper ", $BG"
    # unload all other preloaded wallpapers to save memory
    hyprctl hyprpaper unload all
fi
