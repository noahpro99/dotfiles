#!/usr/bin/env python3
import subprocess
import sys
from pathlib import Path

THEMES_DIR = Path.home() / ".config" / "omarchy" / "themes"
CURRENT_THEME_DIR = Path.home() / ".config" / "omarchy" / "current" / "theme"

THEME_NAME = sys.argv[1] if len(sys.argv) > 1 else "aether"
THEME_PATH = THEMES_DIR / THEME_NAME
CURRENT_BG_PATH = Path.home() / ".config" / "omarchy" / "current" / "background"

# if theme exists
if not THEME_PATH.exists():
    print(f"Theme '{THEME_NAME}' does not exist.")
    sys.exit(1)

# update symlink point current theme to selected theme
if CURRENT_THEME_DIR.exists() or CURRENT_THEME_DIR.is_symlink():
    CURRENT_THEME_DIR.unlink()
CURRENT_THEME_DIR.parent.mkdir(parents=True, exist_ok=True)
CURRENT_THEME_DIR.symlink_to(THEME_PATH, target_is_directory=True)

# update bg
# get first file in theme directory /backgrounds
background_path = next((CURRENT_THEME_DIR / "backgrounds").glob("*.jpg"), None)
print(f"Background path: {background_path}")
if background_path:
    subprocess.run(
        ["hyprctl", "hyprpaper", "wallpaper", f", {background_path}, cover"],
        check=False,
    )
    if CURRENT_BG_PATH.exists() or CURRENT_BG_PATH.is_symlink():
        CURRENT_BG_PATH.unlink()
    CURRENT_BG_PATH.symlink_to(background_path)

# restart waybar
subprocess.run(["pkill", "waybar"])
subprocess.run(["hyprctl", "dispatch", "exec", "waybar"])

# restart hyprland
subprocess.run(["hyprctl", "reload"])

# refresh btop
BTOP_THEME_PATH = CURRENT_THEME_DIR / "btop.theme"
BTOP_CONFIG_PATH = Path.home() / ".config" / "btop" / "themes" / "btop.theme"
if BTOP_CONFIG_PATH.exists() or BTOP_CONFIG_PATH.is_symlink():
    BTOP_CONFIG_PATH.unlink()
BTOP_CONFIG_PATH.symlink_to(BTOP_THEME_PATH)
subprocess.run(["pkill", "-SIGUSR2", "btop"])

# vesktop symlink
# ~/.config/omarchy/themes/aether/vencord.theme.css
VENCORD_THEME_PATH = CURRENT_THEME_DIR / "vencord.theme.css"
VESKTOP_CONFIG_PATH = (
    Path.home() / ".config" / "vesktop" / "themes" / "vencord.theme.css"
)
VESKTOP_CONFIG_PATH.parent.mkdir(parents=True, exist_ok=True)
if VESKTOP_CONFIG_PATH.exists() or VESKTOP_CONFIG_PATH.is_symlink():
    VESKTOP_CONFIG_PATH.unlink()
VESKTOP_CONFIG_PATH.symlink_to(VENCORD_THEME_PATH)

# symlink starship.toml
STARSHIP_THEME_PATH = CURRENT_THEME_DIR / "starship.toml"
STARSHIP_CONFIG_PATH = Path.home() / ".config" / "starship.toml"
if STARSHIP_CONFIG_PATH.exists() or STARSHIP_CONFIG_PATH.is_symlink():
    STARSHIP_CONFIG_PATH.unlink()
STARSHIP_CONFIG_PATH.symlink_to(STARSHIP_THEME_PATH)

# tofi dir symlinks
TOFIA_DIR_PATH = CURRENT_THEME_DIR / "tofiA"
TOFIA_CONFIG_DIR = Path.home() / ".config" / "tofi" / "configA"
TOFIV_DIR_PATH = CURRENT_THEME_DIR / "tofiV"
TOFIV_CONFIG_DIR = Path.home() / ".config" / "tofi" / "configV"
TOFIA_CONFIG_DIR.parent.mkdir(parents=True, exist_ok=True)
if TOFIA_CONFIG_DIR.exists() or TOFIA_CONFIG_DIR.is_symlink():
    TOFIA_CONFIG_DIR.unlink()
if TOFIV_CONFIG_DIR.exists() or TOFIV_CONFIG_DIR.is_symlink():
    TOFIV_CONFIG_DIR.unlink()
TOFIA_CONFIG_DIR.symlink_to(TOFIA_DIR_PATH)
TOFIV_CONFIG_DIR.symlink_to(TOFIV_DIR_PATH)
