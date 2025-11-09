#!/usr/bin/env python3
import json
import os
import shutil
import subprocess
import sys

SCREENSAVER_CONFIG = os.path.expanduser("~/.config/ghostty/screensaver")
SCREENSAVER_SCRIPT = os.path.expanduser("~/.local/bin/screensaver.py")

if not os.path.exists(SCREENSAVER_CONFIG):
    print(
        f"Screensaver config not found at {SCREENSAVER_CONFIG}.",
        file=sys.stderr,
    )
    exit(1)

if shutil.which("tte") is None:
    print("tte command not found. Please install tte.", file=sys.stderr)
    exit(1)


if (
    subprocess.run(
        ["pgrep", "-f", "ghostty --class=Screensaver"],
        capture_output=True,
        text=True,
    ).returncode
    == 0
):
    print("Screensaver is already running.", file=sys.stderr)
    exit(0)


def get_focused_monitor() -> str:
    result = subprocess.run(
        ["hyprctl", "monitors", "-j"],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        print("Failed to get monitors from hyprctl.", file=sys.stderr)
        exit(1)

    monitors = json.loads(result.stdout)
    for monitor in monitors:
        if monitor.get("focused"):
            return monitor.get("name", "HDMI-A-1")
    return "HDMI-A-1"


focused_monitor = get_focused_monitor()


for m in [focused_monitor]:
    subprocess.run(["hyprctl", "dispatch", "focusmonitor", m])

    subprocess.run(
        [
            "hyprctl",
            "dispatch",
            "exec",
            "--",
            "ghostty",
            "--title=Screensaver",
            "--config-default-files=false",
            f"--config-file={SCREENSAVER_CONFIG}",
            "-e",
            "python3",
            SCREENSAVER_SCRIPT,
        ]
    )

subprocess.run(["hyprctl", "dispatch", "focusmonitor", focused_monitor])
