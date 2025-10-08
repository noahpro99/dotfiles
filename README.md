# Noah's dotfiles

<img width="2561" height="1443" alt="desktop" src="https://github.com/user-attachments/assets/2412edc3-df57-4efd-b11d-3500c75f7dac" />

## Installation

You can install the package configuration for these dotfiles in any linux distribution with stow and git.

```bash
sudo apt install git stow
git clone git@github.com/noahpro99/dotfiles.git
cd dotfiles
stow . --no-folding
```

`no folding` makes it so that the entire folders aren't symlinked only the specific files in the dotfiles

## Nixos

I use nixos which makes the installation of all packages super easy. If you use another distribution you will have to install all packages in the `nixos/configuration.nix` file manually.

```bash
chmod u+x ./nixos/switch.sh
./nixos/switch.sh
# for removing old system generations and unused packages
sudo nix-collect-garbage -d
```
