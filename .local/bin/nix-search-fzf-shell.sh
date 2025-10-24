#!/usr/bin/env bash
set -euo pipefail

sel=$(
  nix search nixpkgs --json "${1:-}" \
  | jq -r 'to_entries[] | [.key, (.value.pname//.value.name//""), (.value.description//"")] | @tsv' \
  | fzf --ansi --with-nth 2,3 --delimiter '\t' \
        --tiebreak=begin,length \
        --preview 'printf "%s\n\n%s" {2} {3}'
)

pkg="$(printf '%s' "$sel" | cut -f1 | sed -E 's/^nixpkgs[.]//; s/^.*[.]//')"
[ -n "$pkg" ] && exec nix shell "nixpkgs#$pkg"
