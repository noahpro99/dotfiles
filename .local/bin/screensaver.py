#!/usr/bin/env python3

import atexit
import json
import os
import select
import signal
import subprocess
import sys
import termios
import tty

subprocess.run(
    [
        "hyprctl",
        "dispatch",
        "fullscreen",
    ],
    stdout=subprocess.DEVNULL,
    stderr=subprocess.DEVNULL,
)

SCREENSAVER_TEXT = os.path.expanduser("~/.config/screensaver.txt")

if not os.path.exists(SCREENSAVER_TEXT):
    with open(SCREENSAVER_TEXT, "w") as f:
        f.write("NixOS is the best!\n")
        f.write("customize ~/.config/screensaver.txt to change this text.\n")
        f.write("https://textpaint.com/ is great for generating utf8 art!\n")


def screensaver_in_focus() -> bool:
    result = subprocess.run(
        ["hyprctl", "activewindow", "-j"],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return False

    data = json.loads(result.stdout)
    return data.get("title") == "Screensaver"


def exit_screensaver() -> None:
    restore_terminal()
    subprocess.run(["hyprctl", "keyword", "cursor:invisible", "false"])
    subprocess.run(
        ["pkill", "-x", "tte"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
    )
    subprocess.run(
        ["pkill", "-f", "ghostty --title=Screensaver"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


for sig in (signal.SIGINT, signal.SIGTERM, signal.SIGHUP, signal.SIGQUIT):
    signal.signal(sig, lambda signum, frame: exit_screensaver() or sys.exit(0))

subprocess.run(
    ["hyprctl", "keyword", "cursor:invisible", "true"], stdout=subprocess.DEVNULL
)

STDIN_FD = sys.stdin.fileno()
ORIGINAL_TERMIOS = termios.tcgetattr(STDIN_FD)


def restore_terminal() -> None:
    termios.tcsetattr(STDIN_FD, termios.TCSADRAIN, ORIGINAL_TERMIOS)


tty.setcbreak(STDIN_FD)
atexit.register(restore_terminal)


def get_random_effect() -> str:
    result = subprocess.run(
        ["tte"],
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    effects = set()
    for line in result.stdout.splitlines():
        if "{" in line and "}" in line:
            effect_str = line.split("{")[1].split("}")[0]
            effect_list = effect_str.split(",")
            for effect in effect_list:
                effect = effect.strip()
                if len(effect) <= 2:
                    continue
                effects.add(effect)
    if not effects:
        print(
            "Failed to discover tte effects; defaulting to randomsequence.",
            file=sys.stderr,
        )
        return "randomsequence"
    return subprocess.run(
        ["shuf", "-n1"],
        input="\n".join(effects),
        capture_output=True,
        text=True,
    ).stdout.strip()


while True:
    effect = get_random_effect()
    tte_process = subprocess.Popen(
        [
            "tte",
            "-i",
            SCREENSAVER_TEXT,
            "--frame-rate",
            "240",
            "--canvas-width",
            "0",
            "--canvas-height",
            str(
                int(
                    subprocess.run(
                        ["tput", "lines"], capture_output=True, text=True
                    ).stdout.strip()
                )
            ),
            "--anchor-canvas",
            "c",
            "--anchor-text",
            "c",
            effect,
        ],
        stdin=subprocess.DEVNULL,
    )

    while tte_process.poll() is None:
        dr, _, _ = select.select([sys.stdin], [], [], 3)
        if dr:
            sys.stdin.read(1)
            exit_screensaver()
            sys.exit(0)
        if not screensaver_in_focus():
            print("Screensaver no longer in focus; exiting.", file=sys.stderr)
            exit_screensaver()
            sys.exit(0)
