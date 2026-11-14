#!/usr/bin/env bash
set -euo pipefail

cd ~/dotfiles || exit 1

UPDATE=false
HOST=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -u|--update)
      UPDATE=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [-u|--update] [hostname]"
      echo ""
      echo "Options:"
      echo "  -u, --update    Update flake inputs before switching"
      echo "  -h, --help      Show this help message"
      echo ""
      echo "If hostname is omitted, defaults to current machine: '$(hostname)'"
      exit 0
      ;;
    *)
      HOST="$1"
      shift
      ;;
  esac
done

if [ -z "$HOST" ]; then
  HOST="$(hostname)"
fi

if [ "$UPDATE" = true ]; then
  echo ":: Updating flake inputs..."
  nix flake update
fi

echo ":: Switching NixOS configuration for '$HOST'..."
if command -v nh >/dev/null 2>&1; then
  nh os switch . --hostname "$HOST"
else
  sudo nixos-rebuild switch --flake .#"$HOST"
fi

if [ -d "$HOME/.local/bin" ]; then
  chmod +x "$HOME"/.local/bin/* 2>/dev/null || true
fi

echo ":: Restowing dotfiles..."
stow . --no-folding
