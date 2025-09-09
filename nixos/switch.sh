nixos-generate-config --dir /etc/nixos
cd ~/dotfiles/nixos
sudo nix flake update --extra-experimental-features nix-command --extra-experimental-features flakes
sudo nixos-rebuild switch --flake .#nixos --upgrade-all --impure
