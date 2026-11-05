#!/bin/bash
# Point hyprpaper at the wallpaper aether just applied.
#
# Aether's standalone mode copies the wallpaper into
# ~/.config/aether/theme/backgrounds/ but never sets it on the desktop - the
# Go rewrite delegates that to `omarchy theme bg set`, and omarchy is not
# installed here. The old GJS build used to maintain the symlink below, so
# ~/.config/hypr/hyprpaper.conf still points at it; this hook restores it.

set -u

bg_dir="$HOME/.config/aether/theme/backgrounds"
link="$HOME/.config/omarchy/current/background"

[ -d "$bg_dir" ] || exit 0

# Newest file in backgrounds/. Aether restages the whole directory on every
# apply, so with a single wallpaper this is unambiguous. If you ever export
# additional images alongside the wallpaper, the newest one still wins.
wallpaper=$(find "$bg_dir" -maxdepth 1 -type f -printf '%T@ %p\n' 2>/dev/null \
    | sort -rn | head -1 | cut -d' ' -f2-)

[ -n "$wallpaper" ] || exit 0

# Keeps hyprpaper.conf's `path = ~/.config/omarchy/current/background` correct
# across restarts, independent of the IPC call below.
mkdir -p "$(dirname "$link")"
ln -sfn "$wallpaper" "$link"

if pgrep hyprpaper >/dev/null 2>&1; then
    # hyprpaper 0.8 removed `preload`/`unload`/`listloaded` - it loads on
    # demand now, and `wallpaper` is the only setter left. hyprctl wants the
    # whole request as one argument.
    hyprctl hyprpaper "wallpaper ,$wallpaper" >/dev/null
else
    setsid -f hyprpaper >/dev/null 2>&1
fi
