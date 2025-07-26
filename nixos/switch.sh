cd ~/dotfiles/nixos
sudo nix flake update --extra-experimental-features nix-command --extra-experimental-features flakes
sudo nixos-rebuild switch --upgrade-all
