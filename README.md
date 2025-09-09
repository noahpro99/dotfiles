# Noah's dotfiles

This directory contains the dotfiles for my system

## Installation

```bash
sudo apt install git stow
git clone git@github.com/noahpro99/dotfiles.git
cd dotfiles
stow . --no-folding
```

`no folding` makes it so that the entire folders aren't symlinked only the specific files in the dotfiles

## Nixos

```bash
chmod u+x switch.sh
./switch.sh
# for removing old system generations and unused packages
sudo nix-collect-garbage -d
```
