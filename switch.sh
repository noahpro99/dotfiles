sudo cp ~/dotfiles/root/etc/nixos/* /etc/nixos -r && cd /etc/nixos && sudo nix flake update --extra-experimental-features nix-command --extra-experimental-features flakes && sudo nixos-rebuild switch --upgrade-all

