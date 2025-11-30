if [ -z "${1:-}" ]; then
	echo "Usage: $0 <omen-16, envy-15>"
	exit 1
fi
cd ~/dotfiles || exit 1
sudo nix flake update
sudo nixos-rebuild switch --flake .#"$1" --upgrade-all
sudo chmod +x ~/.local/bin/*
stow . --no-folding