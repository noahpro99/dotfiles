-- This file is not a full hyprland configuration.
-- It is intended to be require()d from your main hyprland.lua.

local activeBorderColor = "rgb({accent.strip})"

hl.config({
    general = { col = { active_border = activeBorderColor } },
    group   = { col = { border_active = activeBorderColor } },
})
