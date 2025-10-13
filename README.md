# Noah's dotfiles

<img width="2561" height="1443" alt="desktop" src="https://github.com/user-attachments/assets/2412edc3-df57-4efd-b11d-3500c75f7dac" />

These are my dotfiles and NixOS configs. You can:

- Stow the shell/editor configs on any Linux distro
- Install packages
  - Either reuse the NixOS config as a module inside your own flake
  - or install all packages manually via your distro's package manager see `nixos/configuration.nix`

## Quick start

### Use dotfiles with GNU Stow (any Linux)

Requires: git, stow

```bash
sudo apt install git stow # or your distro equivalent
git clone https://github.com/noahpro99/dotfiles.git
cd dotfiles
stow . --no-folding
```

Tip: `--no-folding` avoids symlinking entire folders and links individual files instead.

### Use the shared NixOS module in your own flake (recommended)

2. In your own flake, add this repo as an input and import the module:

Example `flake.nix` (in your system repo):

```nix
{
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
		noah-dotfiles.url = "github:noahpro99/dotfiles";
	};

	outputs = { self, nixpkgs, noah-dotfiles, ... }:
		{
			nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				modules = [
					noah-dotfiles.nixosModules.default
					/etc/nixos/hardware-configuration.nix
					# Optionally include Omen-16 hardware module if you have the same laptop
					# noah-dotfiles.nixosModules.omen-16
				];
			};
		};
}
```

Note: If you enable the optional `omen-16` module, also add the `omenix` input and module to your flake:

```nix
	inputs = {
		omenix.url = "github:noahpro99/omenix";
	};

	outputs = { self, nixpkgs, noah-dotfiles, omenix, ... }: {
		nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
			system = "x86_64-linux";
			modules = [
				noah-dotfiles.nixosModules.default
				noah-dotfiles.nixosModules.omen-16
				omenix.nixosModules.default
				/etc/nixos/hardware-configuration.nix
			];
		};
	};
```

## Notes

- If you don’t use NixOS, you can still use the dotfiles via stow and install packages manually or via your distro’s package manager.
- The `omenix` module and HP WMI patch are specific to my Omen 16; omit those if you’re on different hardware.
