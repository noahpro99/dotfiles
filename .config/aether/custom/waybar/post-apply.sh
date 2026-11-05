#!/bin/bash
# Restart waybar so it picks up the regenerated ~/.config/aether/theme/waybar.css.
#
# Do NOT use `hyprctl dispatch exec waybar` here: since the hyprlang -> Lua config
# migration (Hyprland 0.55+), hyprctl parses the dispatch argument as Lua, so
# `dispatch exec waybar` fails with "')' expected near 'waybar'" and the bar never
# comes back. There is no `dispatch exec` equivalent in the Lua API (it is
# hl.exec_cmd, which is config-side only), so launch it directly instead.
#
# Plain `pkill waybar` (no -x) is deliberate: under Nix the binary is wrapped and
# the process comm is ".waybar-wrapped", which `pkill -x waybar` would not match.

pkill waybar

# Wait for the old instance to release its layer-shell surface before respawning.
for _ in $(seq 1 30); do
    pgrep waybar >/dev/null || break
    sleep 0.1
done

# setsid -f detaches waybar from aether so it survives aether exiting.
# env -u LD_PRELOAD: aether may run with gtk4-layer-shell preloaded, which
# conflicts with waybar's own layer-shell usage.
setsid -f env -u LD_PRELOAD waybar >/dev/null 2>&1
