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
$ git clone git@github.com/noahpro99/dotfiles.git
$ cd dotfiles
```

then use GNU stow to create symlinks

```bash
$ stow .
```

For the `/root` you have to manually copy after any change

Nixos config for example

```bash
sudo cp ~/dotfiles/root/etc/nixos/configuration.nix /etc/nixos/configuration.nix
```

## Video Tutorial

[Dreams of Code Tutorial](https://www.youtube.com/watch?v=y6XCebnB9gs)