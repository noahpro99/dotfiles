#!/bin/bash
# GTK side of an aether apply.
#
# 1. GTK3 has no destination of its own (a custom app gets one), so link its
#    gtk.css to the file aether just rendered for GTK4.
# 2. Tell GTK whether the palette is light or dark, and select adw-gtk3, the
#    GTK3 theme that actually reads the named colours in gtk.css.
#
# dconf, not gsettings: gsettings is not on PATH on this system.
# GTK reads gtk.css once at startup, so apps that are already open keep their
# old colours until they are restarted.

set -u

theme_dir="$HOME/.config/aether/theme"

mkdir -p "$HOME/.config/gtk-3.0"
ln -sfn "$theme_dir/gtk-gtk.css" "$HOME/.config/gtk-3.0/gtk.css"

mode="$(sed -n 's/^mode = "\(.*\)"$/\1/p' "$theme_dir/colors.toml" 2>/dev/null)"
if [ "$mode" = "light" ]; then
    scheme="prefer-light"
    gtk_theme="adw-gtk3"
else
    scheme="prefer-dark"
    gtk_theme="adw-gtk3-dark"
fi

dconf write /org/gnome/desktop/interface/color-scheme "'$scheme'"
dconf write /org/gnome/desktop/interface/gtk-theme "'$gtk_theme'"
