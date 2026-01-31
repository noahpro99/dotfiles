# Placeholder hardware configuration for omen-16.
#
# This repo’s flake references this path, but the real hardware config is usually
# generated per-machine (e.g., /etc/nixos/hardware-configuration.nix) and may not
# be checked into dotfiles.
#
# Keeping this file prevents `nix flake check` from failing on machines that
# don’t have the omen-16 hardware config present.

{ ... }:
{
}
