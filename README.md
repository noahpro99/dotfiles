# Noah's dotfiles

This directory contains the dotfiles for my system

## Requirements

Ensure you have the following installed on your system

### Git

```bash
sudo apt install git
```

### Stow

```bash
sudo apt install stow
```

## Installation

First, check out the dotfiles repo in your $HOME directory using git

```bash
git clone git@github.com/noahpro99/dotfiles.git
cd dotfiles
```

then use GNU stow to create symlinks

```bash
stow . --no-folding
```

no folding makes it so that the entire folders aren't symlinked only the specific files in the dotfiles

## Nixos

```bash
chmod u+x switch.sh
./switch.sh
```
