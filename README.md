# Noah's dotfiles

<img width="2561" height="1443" alt="desktop" src="https://github.com/user-attachments/assets/2412edc3-df57-4efd-b11d-3500c75f7dac" />

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
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
		noah-dotfiles.url = "github:noahpro99/dotfiles";
		# Optional: only needed if you enable the HP Omen module below
		# omenix.url = "github:noahpro99/omenix";
	};

	outputs = { self, nixpkgs, noah-dotfiles, omenix, ... }: {
		nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
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
