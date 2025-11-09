if [ -z "${1:-}" ]; then
	echo "Usage: $0 <omen-16, envy-15>"
	exit 1
fi
cd ~/dotfiles || exit 1
sudo nix flake update --extra-experimental-features nix-command --extra-experimental-features flakes
sudo nixos-rebuild switch --flake .#"$1" --upgrade-all
stow . --no-folding