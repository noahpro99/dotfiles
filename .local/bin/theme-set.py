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
    subprocess.run(["hyprctl", "hyprpaper", "reload", ",", str(background_path)])
    if CURRENT_BG_PATH.exists() or CURRENT_BG_PATH.is_symlink():
        CURRENT_BG_PATH.unlink()
    CURRENT_BG_PATH.symlink_to(background_path)

# restart waybar
subprocess.run(["pkill", "waybar"])
subprocess.run(["hyprctl", "dispatch", "exec", "waybar"])

# refresh btop
subprocess.run(["pkill", "-SIGUSR2", "btop"])
