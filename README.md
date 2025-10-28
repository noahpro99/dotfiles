# Noah's dotfiles

<img alt="desktop" src="https://github.com/user-attachments/assets/2412edc3-df57-4efd-b11d-3500c75f7dac" />

These are my dotfiles and NixOS configs. You can:

- Stow the shell/editor configs on any Linux distro.
- Reuse the NixOS modules inside your own flake, or copy the package list for non-Nix setups.

## Quick start

### Dotfiles and packages on any distro

Requires: git, stow

```bash
sudo apt install git stow # or your distro equivalent
git clone https://github.com/noahpro99/dotfiles.git
cd dotfiles
stow . --no-folding
```

Tip: `--no-folding` avoids symlinking entire folders and links individual files instead.

After stowing, install the packages listed in `nixos/configuration.nix` manually or via your distro’s package manager.

### Reuse the NixOS module (recommended on NixOS)

Add the repo to your flake and import the module:

Example `flake.nix` (in your system repo):

```nix
{
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
		noah-dotfiles.url = "github:noahpro99/dotfiles";
		# Optional: only needed if you enable the HP Omen module below
		# omenix.url = "github:noahpro99/omenix";
	};

	outputs = { self, nixpkgs, noah-dotfiles, omenix, ... }: {
		nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";
			modules = [
				noah-dotfiles.nixosModules.default
				/etc/nixos/hardware-configuration.nix

				# Optional: HP Omen 16 hardware tweaks
				# noah-dotfiles.nixosModules.omen-16
				# omenix.nixosModules.default
			];
		};
	};
}
```

## Vscode Speech Extension Fix

Vscode speech extension on nixos

```bash
nix-shell -p patchelf
cd ~/.vscode/extensions/ms-vscode.vscode-speech-0.16.0-linux-x64/node_modules/\@vscode/node-speech/build/Release/
sudo chmod u+w ./*
for f in libMicrosoft.CognitiveServices.Speech.*.so speechapi.node; do patchelf "$f" --add-rpath "$NIX_LD_LIBRARY_PATH"; done
sudo chmod u-w ./*
```

This works because vscode loads dynamic libraries from it's node modules folder in the /build/Release/ folder. The libraries are compiled with the rpath set to the $LD_LIBRARY_PATH and others by default. But since we are using nix-ld we need it to look in $NIX_LD_LIBRARY_PATH which is where alsa-lib and other ones that it needs are located.
